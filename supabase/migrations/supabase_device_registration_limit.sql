-- ==============================================================================
-- SNAPS MIGRATION: Fitur Pembatasan Pendaftaran Perangkat (1 HP Max 3 Akun)
-- Terintegrasi Dashboard Admin: Saklar On/Off, Atur Limit, Whitelist & Reset Kuota
-- ==============================================================================

-- 1. TABEL APP SECURITY SETTINGS (Pengaturan Keamanan & Konfigurasi Global)
create table if not exists public.app_security_settings (
  key text primary key,
  value jsonb not null,
  description text,
  updated_at timestamptz not null default timezone('utc'::text, now()),
  updated_by uuid references auth.users(id) on delete set null
);

alter table public.app_security_settings enable row level security;

-- Policy: Admin dapat melihat dan mengedit pengaturan
drop policy if exists "Admin manage app_security_settings" on public.app_security_settings;
create policy "Admin manage app_security_settings"
  on public.app_security_settings
  for all
  to authenticated
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role = 'admin'
    )
  );

-- Policy: Publik / Anon dapat membaca setting untuk validasi client
drop policy if exists "Public read app_security_settings" on public.app_security_settings;
create policy "Public read app_security_settings"
  on public.app_security_settings
  for select
  using (true);

-- Seed default setting pembatasan pendaftaran perangkat
insert into public.app_security_settings (key, value, description)
values
  ('device_registration_limit', '{"enabled": true, "max_accounts": 3}'::jsonb, 'Konfigurasi batas pendaftaran akun per perangkat fisik')
on conflict (key) do nothing;


-- 2. TABEL DEVICE REGISTRATIONS (Pencatatan Pendaftaran Perangkat HP Siswa)
create table if not exists public.device_registrations (
  id uuid primary key default gen_random_uuid(),
  device_id text not null,
  user_id uuid references auth.users(id) on delete cascade,
  username text,
  device_model text,
  created_at timestamptz not null default timezone('utc'::text, now()),
  is_whitelisted boolean not null default false,
  is_blocked boolean not null default false,
  notes text
);

-- Kolom pelengkap jika tabel sudah ada sebelumnya
alter table public.device_registrations
  add column if not exists is_whitelisted boolean not null default false,
  add column if not exists is_blocked boolean not null default false,
  add column if not exists notes text;

create index if not exists idx_device_registrations_device_id 
  on public.device_registrations(device_id);

create index if not exists idx_device_registrations_user_id 
  on public.device_registrations(user_id);

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


-- 3. FUNGSI CEK KUOTA PENDAFTARAN PERANGKAT (Security Definer)
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
  v_settings jsonb;
  v_enabled boolean := true;
  v_effective_max int := max_allowed;
  v_count int;
  v_is_whitelisted boolean := false;
  v_is_blocked boolean := false;
begin
  if check_device_id is null or trim(check_device_id) = '' then
    return jsonb_build_object(
      'allowed', true,
      'registered_count', 0,
      'max_allowed', v_effective_max,
      'message', 'Valid'
    );
  end if;

  -- 1. Baca konfigurasi global dari app_security_settings
  select value into v_settings
  from public.app_security_settings
  where key = 'device_registration_limit';

  if v_settings is not null then
    v_enabled := coalesce((v_settings->>'enabled')::boolean, true);
    v_effective_max := coalesce((v_settings->>'max_accounts')::int, max_allowed);
  end if;

  -- Jika fitur dinonaktifkan secara global (misal saat hari pertama MPLS)
  if not v_enabled then
    return jsonb_build_object(
      'allowed', true,
      'registered_count', 0,
      'max_allowed', v_effective_max,
      'is_global_disabled', true,
      'message', 'Pembatasan perangkat sedang dinonaktifkan secara global.'
    );
  end if;

  -- 2. Cek status khusus perangkat (Whitelist atau Blocked)
  select 
    coalesce(bool_or(is_whitelisted), false),
    coalesce(bool_or(is_blocked), false)
  into v_is_whitelisted, v_is_blocked
  from public.device_registrations
  where device_id = check_device_id;

  -- Jika perangkat terdaftar dalam whitelist (HP Panitia / Lab / VIP)
  if v_is_whitelisted then
    return jsonb_build_object(
      'allowed', true,
      'registered_count', 0,
      'max_allowed', v_effective_max,
      'is_whitelisted', true,
      'message', 'Perangkat terdaftar dalam daftar khusus (whitelist).'
    );
  end if;

  -- Jika perangkat diblokir secara manual oleh admin
  if v_is_blocked then
    return jsonb_build_object(
      'allowed', false,
      'registered_count', 999,
      'max_allowed', v_effective_max,
      'is_blocked', true,
      'message', 'Perangkat ini telah diblokir dari pendaftaran akun baru.'
    );
  end if;

  -- 3. Hitung jumlah akun unik terdaftar pada perangkat ini
  select count(distinct user_id)
  into v_count
  from public.device_registrations
  where device_id = check_device_id;

  if v_count >= v_effective_max then
    return jsonb_build_object(
      'allowed', false,
      'registered_count', v_count,
      'max_allowed', v_effective_max,
      'message', 'Perangkat ini sudah mencapai batas maksimal pendaftaran (' || v_effective_max || ' akun). Silakan gunakan akun yang sudah ada.'
    );
  else
    return jsonb_build_object(
      'allowed', true,
      'registered_count', v_count,
      'max_allowed', v_effective_max,
      'message', 'Kuota pendaftaran tersedia'
    );
  end if;
end;
$$;

grant execute on function public.check_device_registration_quota(text, int) to anon, authenticated;


-- 4. RPC: CATAT PENDAFTARAN PERANGKAT (Dipanggil saat Registrasi Berhasil)
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


-- 5. RPC KHUSUS ADMIN: AMBIL SEMUA DATA & STATISTIK PERANGKAT
create or replace function public.admin_get_device_security_data()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_settings jsonb;
  v_devices jsonb;
  v_total_devices int;
  v_whitelisted_count int;
  v_blocked_count int;
begin
  if not exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  ) then
    raise exception 'Unauthorized: Akses khusus Admin';
  end if;

  -- Baca settings
  select value into v_settings
  from public.app_security_settings
  where key = 'device_registration_limit';

  if v_settings is null then
    v_settings := '{"enabled": true, "max_accounts": 3}'::jsonb;
  end if;

  -- Agregasi perangkat unik
  select jsonb_agg(d_agg order by last_registered_at desc)
  into v_devices
  from (
    select
      device_id,
      coalesce(max(device_model), 'Unknown Device') as device_model,
      count(distinct user_id) as account_count,
      array_to_json(array_agg(distinct coalesce(username, 'user'))) as accounts,
      bool_or(is_whitelisted) as is_whitelisted,
      bool_or(is_blocked) as is_blocked,
      max(notes) as notes,
      min(created_at) as first_registered_at,
      max(created_at) as last_registered_at
    from public.device_registrations
    group by device_id
  ) d_agg;

  select count(distinct device_id) into v_total_devices from public.device_registrations;
  select count(distinct device_id) into v_whitelisted_count from public.device_registrations where is_whitelisted = true;
  select count(distinct device_id) into v_blocked_count from public.device_registrations where is_blocked = true;

  return jsonb_build_object(
    'settings', v_settings,
    'total_devices', coalesce(v_total_devices, 0),
    'whitelisted_count', coalesce(v_whitelisted_count, 0),
    'blocked_count', coalesce(v_blocked_count, 0),
    'devices', coalesce(v_devices, '[]'::jsonb)
  );
end;
$$;

grant execute on function public.admin_get_device_security_data() to authenticated;


-- 6. RPC KHUSUS ADMIN: UPDATE PENGATURAN GLOBAL (ON/OFF & MAX LIMIT)
create or replace function public.admin_update_device_security_settings(
  p_enabled boolean,
  p_max_accounts int
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
    raise exception 'Unauthorized: Akses khusus Admin';
  end if;

  if p_max_accounts < 1 then
    p_max_accounts := 1;
  end if;

  insert into public.app_security_settings (key, value, description, updated_at, updated_by)
  values (
    'device_registration_limit',
    jsonb_build_object('enabled', p_enabled, 'max_accounts', p_max_accounts),
    'Konfigurasi batas pendaftaran akun per perangkat fisik',
    timezone('utc'::text, now()),
    auth.uid()
  )
  on conflict (key) do update
  set
    value = jsonb_build_object('enabled', p_enabled, 'max_accounts', p_max_accounts),
    updated_at = timezone('utc'::text, now()),
    updated_by = auth.uid();

  return true;
end;
$$;

grant execute on function public.admin_update_device_security_settings(boolean, int) to authenticated;


-- 7. RPC KHUSUS ADMIN: TOGGLE WHITELIST STATUS PERANGKAT
create or replace function public.admin_toggle_device_whitelist(
  target_device_id text,
  target_status boolean
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
    raise exception 'Unauthorized: Akses khusus Admin';
  end if;

  update public.device_registrations
  set is_whitelisted = target_status
  where device_id = target_device_id;

  return true;
end;
$$;

grant execute on function public.admin_toggle_device_whitelist(text, boolean) to authenticated;


-- 8. RPC KHUSUS ADMIN: TOGGLE BLOKIR PERANGKAT
create or replace function public.admin_toggle_device_block(
  target_device_id text,
  target_status boolean
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
    raise exception 'Unauthorized: Akses khusus Admin';
  end if;

  update public.device_registrations
  set is_blocked = target_status
  where device_id = target_device_id;

  return true;
end;
$$;

grant execute on function public.admin_toggle_device_block(text, boolean) to authenticated;


-- 9. RPC KHUSUS ADMIN: RESET KUOTA PERANGKAT (Hapus Riwayat Device)
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
    raise exception 'Unauthorized: Akses khusus Admin';
  end if;

  delete from public.device_registrations
  where device_id = target_device_id;

  return true;
end;
$$;

grant execute on function public.admin_reset_device_quota(text) to authenticated;
