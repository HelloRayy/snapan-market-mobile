-- ==============================================================================
-- SNAPS MIGRATION: Fitur Suspend Akun (SNAPS-16)
-- Menambahkan fungsionalitas penangguhan akun pengguna/siswa yang melanggar aturan
-- Dijalankan langsung melalui Supabase SQL Editor
-- ==============================================================================

-- 1. Tambahkan kolom status penangguhan pada tabel public.profiles
alter table public.profiles
  add column if not exists is_suspended boolean not null default false,
  add column if not exists suspended_at timestamptz,
  add column if not exists suspended_until timestamptz,
  add column if not exists suspend_reason text;

-- 2. Partial Index untuk akun yang sedang disuspen (Postgres Best Practice)
-- Mempercepat query pengecekan status tanpa membebani indeks seluruh data siswa aktif
create index if not exists idx_profiles_is_suspended
  on public.profiles (is_suspended)
  where is_suspended = true;

-- 3. Fungsi Helper Cek Status Suspen Pengguna (Security Definer & Search Path Aman)
-- Mengembalikan TRUE jika pengguna aktif sedang ditangguhkan dan masa berlakunya belum habis
create or replace function public.is_user_suspended(check_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = check_user_id
      and is_suspended = true
      and (suspended_until is null or suspended_until > timezone('utc'::text, now()))
  );
$$;

-- 4. RPC Helper: Admin Suspend User (Security Definer)
-- Memungkinkan Admin menangguhkan akun pengguna dengan durasi (jam) dan alasan pelanggaran
create or replace function public.admin_suspend_user(
  target_user_id uuid,
  reason text,
  duration_hours integer default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_until timestamptz := null;
begin
  -- 4.1. Verifikasi Otoritas Admin
  if not public.is_admin() then
    raise exception 'Unauthorized: Hanya administrator yang berhak menangguhkan akun pengguna.';
  end if;

  -- 4.2. Mencegah Admin menangguhkan akunnya sendiri
  if target_user_id = auth.uid() then
    raise exception 'Invalid Operation: Administrator tidak diizinkan menangguhkan akun sendiri.';
  end if;

  -- 4.3. Validasi Alasan Penangguhan
  if reason is null or length(trim(reason)) < 3 then
    raise exception 'Invalid Input: Alasan penangguhan akun wajib diisi minimal 3 karakter.';
  end if;

  -- 4.4. Hitung batas waktu penangguhan jika durasi ditentukan (null = permanen)
  if duration_hours is not null and duration_hours > 0 then
    v_until := timezone('utc'::text, now()) + (duration_hours || ' hours')::interval;
  end if;

  -- 4.5. Eksekusi pembaruan status profil siswa
  update public.profiles
  set
    is_suspended = true,
    suspended_at = timezone('utc'::text, now()),
    suspended_until = v_until,
    suspend_reason = trim(reason)
  where id = target_user_id;

  if not found then
    raise exception 'Target pengguna tidak ditemukan dalam direktori siswa.';
  end if;
end;
$$;

-- 5. RPC Helper: Admin Unsuspend User (Security Definer)
-- Memungkinkan Admin memulihkan kembali akun pengguna yang ditangguhkan
create or replace function public.admin_unsuspend_user(target_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  -- 5.1. Verifikasi Otoritas Admin
  if not public.is_admin() then
    raise exception 'Unauthorized: Hanya administrator yang berhak memulihkan akun pengguna.';
  end if;

  -- 5.2. Reset status penangguhan ke normal
  update public.profiles
  set
    is_suspended = false,
    suspended_at = null,
    suspended_until = null,
    suspend_reason = null
  where id = target_user_id;

  if not found then
    raise exception 'Target pengguna tidak ditemukan dalam direktori siswa.';
  end if;
end;
$$;

-- 6. Penguatan RLS Policies: Blokir Akun Tersuspen dari Tindakan Menulis / Transaksi
-- 6.1. Dilarang membuat postingan baru
drop policy if exists "Sellers can insert own posts" on public.market_posts;
create policy "Sellers can insert own posts"
  on public.market_posts
  for insert
  with check (
    auth.uid() = seller_id
    and not public.is_user_suspended(auth.uid())
  );

-- 6.2. Dilarang membuat komentar
drop policy if exists "Users can insert comments" on public.post_comments;
create policy "Users can insert comments"
  on public.post_comments
  for insert
  with check (
    auth.uid() = user_id
    and not public.is_user_suspended(auth.uid())
  );

-- 6.3. Dilarang memberikan like pada postingan
drop policy if exists "Users can like posts" on public.post_likes;
create policy "Users can like posts"
  on public.post_likes
  for insert
  with check (
    auth.uid() = user_id
    and not public.is_user_suspended(auth.uid())
  );

-- 6.4. Dilarang checkout atau membuat pesanan baru
drop policy if exists "Buyers can insert new order" on public.orders;
create policy "Buyers can insert new order"
  on public.orders
  for insert
  with check (
    auth.uid() = buyer_id
    and not public.is_user_suspended(auth.uid())
  );

-- 6.5. Dilarang mengirim direct messages di ruang obrolan
drop policy if exists "Users can send messages" on public.direct_messages;
create policy "Users can send messages"
  on public.direct_messages
  for insert
  with check (
    auth.uid() = sender_id
    and not public.is_user_suspended(auth.uid())
  );

-- Berikan izin eksekusi ke authenticated user (validasi admin dilakukan di dalam fungsi)
grant execute on function public.is_user_suspended(uuid) to anon, authenticated;
grant execute on function public.admin_suspend_user(uuid, text, integer) to authenticated;
grant execute on function public.admin_unsuspend_user(uuid) to authenticated;

-- 7. Tambahkan profiles ke supabase_realtime agar broadcast instan ke mobile app saat disuspen
do $$ begin alter publication supabase_realtime add table public.profiles; exception when duplicate_object or others then null; end $$;
alter table public.profiles replica identity full;

