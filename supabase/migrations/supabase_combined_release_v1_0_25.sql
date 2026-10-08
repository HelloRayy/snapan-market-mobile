-- ==============================================================================
-- 🚀 SNAPAN MARKET COMBINED PRODUCTION MIGRATION
-- Tiket Tergabung:
--   1. SNAPS-64: Fix Username Change Auth Sync & Secure NIS Login Lookup
--   2. SNAPS-65: Fix Admin Role Toggle RPC (Admin <-> Siswa switch)
--   3. SNAPS-62: School Meeting Points (Titik Temu COD Kampus SMKN 8)
-- ==============================================================================
-- Salin dan jalankan seluruh query ini di:
-- Supabase Dashboard -> SQL Editor -> New Query -> Run
-- URL: https://supabase.com/dashboard/project/lcwsxldnoqjdfqxqcqja/sql
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- BAGIAN 0: Helper Function Role Admin
-- ------------------------------------------------------------------------------
create or replace function public.is_admin()
returns boolean
language sql
security definer
stable
set search_path = public, auth
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- ------------------------------------------------------------------------------
-- BAGIAN 1 (SNAPS-64): Loket Resmi Pencarian Kredensial Login (NIS & Username)
-- ------------------------------------------------------------------------------
create or replace function public.lookup_login_email(identifier text)
returns jsonb
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_clean text;
  v_username text;
  v_nis text;
begin
  v_clean := lower(trim(regexp_replace(identifier, '^@', '')));
  if v_clean = '' then
    return jsonb_build_object('found', false, 'email', null);
  end if;

  -- A. Jika input adalah NIS (deretan angka murni)
  if v_clean ~ '^\d+$' then
    select p.username, p.nis into v_username, v_nis
    from public.profiles p
    where p.nis = v_clean
    limit 1;

    if v_username is not null and v_username <> '' then
      return jsonb_build_object(
        'found', true,
        'type', 'nis',
        'email', lower(v_username) || '@snapan.id',
        'username', v_username,
        'nis', v_nis
      );
    end if;
  else
    -- B. Jika input adalah username
    select p.username, p.nis into v_username, v_nis
    from public.profiles p
    where lower(p.username) = v_clean
    limit 1;

    if v_username is not null and v_username <> '' then
      return jsonb_build_object(
        'found', true,
        'type', 'username',
        'email', lower(v_username) || '@snapan.id',
        'username', v_username,
        'nis', v_nis
      );
    end if;
  end if;

  -- Default fallback jika belum ditemukan di tabel profiles
  return jsonb_build_object(
    'found', false,
    'type', 'unknown',
    'email', v_clean || '@snapan.id'
  );
end;
$$;

grant execute on function public.lookup_login_email(text) to anon, authenticated;

-- ------------------------------------------------------------------------------
-- BAGIAN 2 (SNAPS-64): Fungsi Atomis Ganti Username & Sinkronisasi Email Auth
-- ------------------------------------------------------------------------------
create or replace function public.change_user_username(new_username text)
returns jsonb
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_user_id uuid;
  v_clean_username text;
  v_existing_id uuid;
begin
  v_user_id := auth.uid();
  if v_user_id is null then
    return jsonb_build_object('success', false, 'error', 'Sesi autentikasi tidak valid.');
  end if;

  v_clean_username := lower(trim(regexp_replace(new_username, '^@', '')));

  -- Validasi panjang karakter (3-20 karakter)
  if length(v_clean_username) < 3 or length(v_clean_username) > 20 then
    return jsonb_build_object('success', false, 'error', 'Username harus antara 3 hingga 20 karakter.');
  end if;

  -- Validasi format karakter (hanya huruf kecil, angka, underscore)
  if not (v_clean_username ~ '^[a-z0-9_]+$') then
    return jsonb_build_object('success', false, 'error', 'Username hanya boleh memuat huruf, angka, dan garis bawah (_).');
  end if;

  -- Validasi keunikan username di public.profiles
  select id into v_existing_id
  from public.profiles
  where lower(username) = v_clean_username and id <> v_user_id
  limit 1;

  if v_existing_id is not null then
    return jsonb_build_object('success', false, 'error', 'Username @' || v_clean_username || ' sudah digunakan oleh akun lain.');
  end if;

  -- A. Perbarui public.profiles
  update public.profiles
  set username = v_clean_username
  where id = v_user_id;

  -- B. Perbarui auth.users email & metadata secara atomis
  update auth.users
  set email = v_clean_username || '@snapan.id',
      email_confirmed_at = coalesce(email_confirmed_at, now()),
      raw_user_meta_data = jsonb_set(
        coalesce(raw_user_meta_data, '{}'::jsonb),
        '{username}',
        to_jsonb(v_clean_username)
      )
  where id = v_user_id;

  return jsonb_build_object(
    'success', true,
    'username', v_clean_username,
    'email', v_clean_username || '@snapan.id'
  );
end;
$$;

grant execute on function public.change_user_username(text) to authenticated;

-- ------------------------------------------------------------------------------
-- BAGIAN 3 (SNAPS-64): Data Repair Akun yang Sempat Tidak Sinkron
-- ------------------------------------------------------------------------------
update auth.users u
set email = lower(p.username) || '@snapan.id',
    raw_user_meta_data = jsonb_set(
      coalesce(u.raw_user_meta_data, '{}'::jsonb),
      '{username}',
      to_jsonb(lower(p.username))
    )
from public.profiles p
where u.id = p.id
  and p.username is not null
  and trim(p.username) <> ''
  and u.email <> lower(p.username) || '@snapan.id';

-- ------------------------------------------------------------------------------
-- BAGIAN 4 (SNAPS-65): RPC Switch Role Admin <-> Siswa (Fix Error Log di Dashboard)
-- ------------------------------------------------------------------------------
create or replace function public.admin_update_profile_role(target_user_id uuid, new_role text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_normalized_role text;
begin
  if not public.is_admin() then
    raise exception 'Unauthorized: Hanya admin yang dapat mengubah role akun.';
  end if;

  v_normalized_role := lower(trim(new_role));
  if v_normalized_role not in ('user', 'admin', 'buyer', 'seller') then
    raise exception 'Invalid role: %', new_role;
  end if;

  update public.profiles
  set role = v_normalized_role,
      updated_at = now()
  where id = target_user_id;
end;
$$;

grant execute on function public.admin_update_profile_role(uuid, text) to authenticated;

-- ------------------------------------------------------------------------------
-- BAGIAN 5 (SNAPS-62): Titik Temu COD Kampus SMKN 8 Semarang (school_meeting_points)
-- ------------------------------------------------------------------------------
create table if not exists public.school_meeting_points (
  id varchar(50) primary key,
  floor integer not null check (floor in (1, 2, 3)),
  name varchar(100) not null,
  area_category varchar(50) not null,
  description varchar(255),
  coordinates_x float not null,
  coordinates_y float not null,
  is_active boolean not null default true,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create index if not exists idx_school_meeting_points_floor on public.school_meeting_points(floor);
create index if not exists idx_school_meeting_points_is_active on public.school_meeting_points(is_active);

alter table public.school_meeting_points enable row level security;

-- Public / Siswa read-only
drop policy if exists "Public read meeting points" on public.school_meeting_points;
drop policy if exists "Public meeting points readable by everyone" on public.school_meeting_points;
create policy "Public read meeting points"
  on public.school_meeting_points
  for select
  using (true);

-- Admin INSERT
drop policy if exists "Admins can insert meeting points" on public.school_meeting_points;
create policy "Admins can insert meeting points"
  on public.school_meeting_points
  for insert
  to authenticated
  with check (public.is_admin());

-- Admin UPDATE
drop policy if exists "Admins can update meeting points" on public.school_meeting_points;
create policy "Admins can update meeting points"
  on public.school_meeting_points
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- Admin DELETE
drop policy if exists "Admins can delete meeting points" on public.school_meeting_points;
create policy "Admins can delete meeting points"
  on public.school_meeting_points
  for delete
  to authenticated
  using (public.is_admin());

-- Seed Titik Temu Resmi SMKN 8 Semarang
insert into public.school_meeting_points (id, floor, name, area_category, description, coordinates_x, coordinates_y)
values
  -- Lantai 1
  ('canteen_main',       1, 'Kantin Utama & Pujasera',        'canteen',   'Area meja makan kantin belakang',                35.0, 75.0),
  ('sports_field',       1, 'Lapangan Olahraga Utama',        'sports',    'Depan tiang bendera lapangan tengah',            50.0, 50.0),
  ('gazebo_field',       1, 'Gazebo Pinggir Lapangan',        'lounge',    'Gazebo teduh samping lapangan basket',           68.0, 42.0),
  ('lobby_front',        1, 'Lobby Depan / Pos Satpam',       'corridor',  'Area pintu masuk lobby utama sekolah',           50.0, 90.0),
  ('workshop_otomotif',  1, 'Bengkel Praktik Otomotif',       'workshop',  'Depan ruang alat bengkel TKR/TSM',               20.0, 60.0),
  -- Lantai 2
  ('lab_pplg_1',         2, 'Lab Komputer PPLG 1',            'lab',       'Depan pintu Lab Rekayasa Perangkat Lunak 1',     30.0, 35.0),
  ('lab_pplg_2',         2, 'Lab Komputer PPLG 2',            'lab',       'Depan pintu Lab Rekayasa Perangkat Lunak 2',     45.0, 35.0),
  ('lab_tjkt',           2, 'Lab Jaringan Komputer TJKT',     'lab',       'Area depan rak server Lab Jaringan',             60.0, 35.0),
  ('library_smkn8',      2, 'Perpustakaan Sekolah',           'lounge',    'Area baca depan loker perpustakaan',             75.0, 45.0),
  ('corridor_fl2',       2, 'Koridor Tengah Lantai 2',        'corridor',  'Dekat tangga utama lantai 2',                    50.0, 50.0),
  -- Lantai 3
  ('studio_dkv',         3, 'Studio Desain Komunikasi Visual','lab',       'Depan pintu Lab DKV Multimedia',                 35.0, 30.0),
  ('corridor_fl3',       3, 'Koridor Kelas XII Lantai 3',     'corridor',  'Depan lorong kelas XII PPLG / AKL',              55.0, 30.0)
on conflict (id) do update set
  name = excluded.name,
  area_category = excluded.area_category,
  description = excluded.description,
  coordinates_x = excluded.coordinates_x,
  coordinates_y = excluded.coordinates_y;
