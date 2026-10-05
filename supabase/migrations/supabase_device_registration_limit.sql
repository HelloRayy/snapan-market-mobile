-- ==============================================================================
-- SNAPS MIGRATION: Fitur Pembatasan Pendaftaran Perangkat (1 HP Max 3 Akun)
-- Mencegah pembuatan akun spam / tuyul berulang dari satu perangkat fisik
-- ==============================================================================

-- 1. Buat tabel pencatatan pendaftaran perangkat
create table if not exists public.device_registrations (
  id uuid primary key default gen_random_uuid(),
  device_id text not null,
  user_id uuid references auth.users(id) on delete cascade,
  username text,
  device_model text,
  created_at timestamptz not null default timezone('utc'::text, now()),
  is_blocked boolean not null default false
);

-- 2. Index untuk pencarian cepat berdasarkan device_id
create index if not exists idx_device_registrations_device_id 
  on public.device_registrations(device_id);

create index if not exists idx_device_registrations_user_id 
  on public.device_registrations(user_id);

-- 3. Aktifkan Row Level Security (RLS)
alter table public.device_registrations enable row level security;

-- Policy: Admin dapat mengelola semua data device registrations
drop policy if exists "Admin manage device_registrations" on public.device_registrations;
create policy "Admin manage device_registrations"
  on public.device_registrations
  for all
  to authenticated
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role = 'admin'
    )
  );

-- Policy: Pengguna yang sudah login dapat melihat riwayat pendaftaran perangkatnya sendiri
drop policy if exists "Users view own device_registrations" on public.device_registrations;
create policy "Users view own device_registrations"
  on public.device_registrations
  for select
  to authenticated
  using (user_id = auth.uid());

-- Policy: Pengguna dapat mencatat perangkatnya saat pendaftaran berhasil
drop policy if exists "Users insert own device_registration" on public.device_registrations;
create policy "Users insert own device_registration"
  on public.device_registrations
  for insert
  to authenticated
  with check (user_id = auth.uid());

-- 4. Fungsi Security Definer: Pengecekan Kuota Pendaftaran Perangkat
-- Mengembalikan format json: { "allowed": boolean, "registered_count": int, "max_allowed": int, "message": text }
create or replace function public.check_device_registration_quota(
  check_device_id text,
  max_allowed int default 3
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count int;
  v_is_blocked boolean;
begin
  if check_device_id is null or trim(check_device_id) = '' then
    return jsonb_build_object(
      'allowed', true,
      'registered_count', 0,
      'max_allowed', max_allowed,
      'message', 'Valid'
    );
  end if;

  -- Cek apakah device diblokir secara manual oleh admin
  select exists (
    select 1 from public.device_registrations 
    where device_id = check_device_id and is_blocked = true
  ) into v_is_blocked;

  if v_is_blocked then
    return jsonb_build_object(
      'allowed', false,
      'registered_count', 999,
      'max_allowed', max_allowed,
      'message', 'Perangkat ini telah diblokir dari pendaftaran akun baru.'
    );
  end if;

  -- Hitung jumlah akun unik terdaftar pada perangkat ini
  select count(distinct user_id)
  into v_count
  from public.device_registrations
  where device_id = check_device_id;

  if v_count >= max_allowed then
    return jsonb_build_object(
      'allowed', false,
      'registered_count', v_count,
      'max_allowed', max_allowed,
      'message', 'Perangkat ini sudah mencapai batas maksimal pendaftaran (' || max_allowed || ' akun). Silakan gunakan akun yang sudah ada.'
    );
  else
    return jsonb_build_object(
      'allowed', true,
      'registered_count', v_count,
      'max_allowed', max_allowed,
      'message', 'Kuota pendaftaran tersedia'
    );
  end if;
end;
$$;

grant execute on function public.check_device_registration_quota(text, int) to anon, authenticated;

-- 5. RPC Helper: Catat Pendaftaran Perangkat setelah Sign-Up Berhasil
create or replace function public.record_device_registration(
  p_device_id text,
  p_device_model text default 'Unknown Device'
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_uname text;
begin
  if v_uid is null then
    return;
  end if;

  select username into v_uname from public.profiles where id = v_uid;

  insert into public.device_registrations (device_id, user_id, username, device_model)
  values (p_device_id, v_uid, v_uname, p_device_model);
end;
$$;

grant execute on function public.record_device_registration(text, text) to authenticated;

-- 6. RPC Khusus Admin: Reset Kuota Pendaftaran Perangkat (Darurat / HP Pindahan)
create or replace function public.admin_reset_device_quota(
  target_device_id text
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  ) then
    raise exception 'Unauthorized: Hanya Admin yang berhak mereset kuota pendaftaran perangkat.';
  end if;

  delete from public.device_registrations
  where device_id = target_device_id;

  return true;
end;
$$;

grant execute on function public.admin_reset_device_quota(text) to authenticated;
