-- ==============================================================================
-- SNAPS MIGRATION: [SNAPS-63] Sistem Analisa & Keamanan Device Login NIS Siswa
-- Fitur:
-- 1. Tabel konfigurasi global app_security_settings (Self-contained)
-- 2. Pencatatan log autentikasi (login_success, login_failed, register) per NIS & Perangkat
-- 3. Binding perangkat aktif per NIS (Default Max 3 Perangkat)
-- 4. Deteksi anomali: Percobaan login gagal > 3x & Penggunaan > 3 perangkat per NIS
-- 5. Fitur Unlink Device manual oleh Admin jika siswa melapor ganti/hilang HP
-- ==============================================================================

-- 0. TABEL GLOBAL SECURITY SETTINGS (Memastikan tabel tersedia)
create table if not exists public.app_security_settings (
  key text primary key,
  value jsonb not null default '{}'::jsonb,
  description text,
  updated_at timestamptz default timezone('utc'::text, now()),
  updated_by uuid
);

alter table public.app_security_settings enable row level security;

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

drop policy if exists "Public read app_security_settings" on public.app_security_settings;
create policy "Public read app_security_settings"
  on public.app_security_settings
  for select
  to public
  using (true);

-- 1. TABEL DEVICE AUTH LOGS (Riwayat Setiap Aktivitas Login & Percobaan Masuk)
create table if not exists public.device_auth_logs (
  id uuid primary key default gen_random_uuid(),
  nis text not null,
  user_id uuid references auth.users(id) on delete set null,
  device_id text not null,
  device_model text default 'Unknown Device',
  event_type text not null check (event_type in ('login_success', 'login_failed', 'register')),
  created_at timestamptz not null default timezone('utc'::text, now())
);

create index if not exists idx_device_auth_logs_nis on public.device_auth_logs(nis);
create index if not exists idx_device_auth_logs_device_id on public.device_auth_logs(device_id);
create index if not exists idx_device_auth_logs_created_at on public.device_auth_logs(created_at desc);
create index if not exists idx_device_auth_logs_event_type on public.device_auth_logs(event_type);

alter table public.device_auth_logs enable row level security;

-- Policy Admin: Akses penuh untuk pemantauan
drop policy if exists "Admin read device_auth_logs" on public.device_auth_logs;
create policy "Admin read device_auth_logs"
  on public.device_auth_logs
  for select
  to authenticated
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role = 'admin'
    )
  );

-- 2. TABEL NIS DEVICE BINDINGS (Daftar Perangkat Terhubung per NIS Siswa)
create table if not exists public.nis_device_bindings (
  id uuid primary key default gen_random_uuid(),
  nis text not null,
  device_id text not null,
  device_model text default 'Unknown Device',
  first_used_at timestamptz not null default timezone('utc'::text, now()),
  last_used_at timestamptz not null default timezone('utc'::text, now()),
  is_unlinked boolean not null default false,
  unlinked_at timestamptz,
  unlinked_by uuid references auth.users(id) on delete set null,
  constraint unique_nis_device unique (nis, device_id)
);

create index if not exists idx_nis_device_bindings_nis on public.nis_device_bindings(nis);
create index if not exists idx_nis_device_bindings_device_id on public.nis_device_bindings(device_id);
create index if not exists idx_nis_device_bindings_unlinked on public.nis_device_bindings(is_unlinked);

alter table public.nis_device_bindings enable row level security;

drop policy if exists "Admin manage nis_device_bindings" on public.nis_device_bindings;
create policy "Admin manage nis_device_bindings"
  on public.nis_device_bindings
  for all
  to authenticated
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role = 'admin'
    )
  );

-- 3. INITIAL SETTING (Batasan Perangkat per NIS & Ambang Batas Login Gagal)
insert into public.app_security_settings (key, value, description)
values (
  'device_nis_security_policy',
  '{"max_devices_per_nis": 3, "failed_threshold": 3}'::jsonb,
  'Pengaturan batas perangkat per NIS dan ambang batas percobaan login gagal'
)
on conflict (key) do nothing;


-- 4. RPC: PENCATATAN EVENT PERANGKAT (Dipanggil dari Aplikasi Siswa)
create or replace function public.record_device_auth_event(
  p_nis text,
  p_device_id text,
  p_device_model text default 'Unknown Device',
  p_event_type text default 'login_success',
  p_user_id uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_clean_nis text;
  v_clean_device_id text;
  v_clean_model text;
begin
  v_clean_nis := trim(p_nis);
  v_clean_device_id := trim(p_device_id);
  v_clean_model := coalesce(nullif(trim(p_device_model), ''), 'Unknown Device');

  if v_clean_nis = '' or v_clean_device_id = '' then
    return jsonb_build_object('success', false, 'message', 'NIS atau Device ID kosong');
  end if;

  -- 1. Catat ke log histori
  insert into public.device_auth_logs (
    nis,
    user_id,
    device_id,
    device_model,
    event_type
  ) values (
    v_clean_nis,
    p_user_id,
    v_clean_device_id,
    v_clean_model,
    p_event_type
  );

  -- 2. Jika event login_success atau register, perbarui / masukkan ke daftar binding perangkat aktif
  if p_event_type in ('login_success', 'register') then
    insert into public.nis_device_bindings (
      nis,
      device_id,
      device_model,
      first_used_at,
      last_used_at,
      is_unlinked
    ) values (
      v_clean_nis,
      v_clean_device_id,
      v_clean_model,
      timezone('utc'::text, now()),
      timezone('utc'::text, now()),
      false
    )
    on conflict (nis, device_id) do update
    set
      device_model = excluded.device_model,
      last_used_at = timezone('utc'::text, now()),
      is_unlinked = false,
      unlinked_at = null,
      unlinked_by = null;
  end if;

  return jsonb_build_object('success', true);
end;
$$;

grant execute on function public.record_device_auth_event(text, text, text, text, uuid) to anon, authenticated;


-- 5. RPC ADMIN: AMBIL PERINGATAN ANOMALI KEAMANAN (ALERTS)
-- Mendeteksi:
-- A. NIS dengan > max_devices (default 3) aktif
-- B. NIS yang mengalami > 3 kali login_failed dalam 24 jam terakhir
create or replace function public.admin_get_security_alerts()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_settings jsonb;
  v_max_devices int := 3;
  v_failed_threshold int := 3;
  v_alerts jsonb := '[]'::jsonb;
begin
  if not exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  ) then
    raise exception 'Unauthorized: Akses khusus Admin';
  end if;

  -- Baca konfigurasi
  select value into v_settings
  from public.app_security_settings
  where key = 'device_nis_security_policy';

  if v_settings is not null then
    v_max_devices := coalesce((v_settings->>'max_devices_per_nis')::int, 3);
    v_failed_threshold := coalesce((v_settings->>'failed_threshold')::int, 3);
  end if;

  -- Kumpulkan alert
  with multi_device_alerts as (
    select
      b.nis,
      'excess_devices' as alert_type,
      count(b.device_id) as active_device_count,
      array_agg(distinct b.device_model) as device_models,
      max(b.last_used_at) as last_activity,
      (
        'NIS ' || b.nis || ' terhubung dengan ' || count(b.device_id) ||
        ' perangkat aktif (Batas: ' || v_max_devices || ').'
      ) as message
    from public.nis_device_bindings b
    where b.is_unlinked = false
    group by b.nis
    having count(b.device_id) > v_max_devices
  ),
  failed_login_alerts as (
    select
      l.nis,
      'excessive_failed_attempts' as alert_type,
      count(l.id) as failed_attempts,
      array_agg(distinct l.device_model) as device_models,
      max(l.created_at) as last_activity,
      (
        'Terdeteksi ' || count(l.id) || ' kali percobaan login gagal pada NIS ' ||
        l.nis || ' dalam 24 jam terakhir.'
      ) as message
    from public.device_auth_logs l
    where l.event_type = 'login_failed'
      and l.created_at >= (timezone('utc'::text, now()) - interval '24 hours')
    group by l.nis
    having count(l.id) >= v_failed_threshold
  ),
  all_alerts as (
    select * from multi_device_alerts
    union all
    select
      nis,
      alert_type,
      failed_attempts as active_device_count,
      device_models,
      last_activity,
      message
    from failed_login_alerts
  )
  select coalesce(jsonb_agg(
    jsonb_build_object(
      'nis', nis,
      'alert_type', alert_type,
      'count', active_device_count,
      'device_models', device_models,
      'last_activity', last_activity,
      'message', message
    ) order by last_activity desc
  ), '[]'::jsonb)
  into v_alerts
  from all_alerts;

  return jsonb_build_object(
    'total_alerts', jsonb_array_length(v_alerts),
    'alerts', v_alerts,
    'policy', jsonb_build_object(
      'max_devices_per_nis', v_max_devices,
      'failed_threshold', v_failed_threshold
    )
  );
end;
$$;

grant execute on function public.admin_get_security_alerts() to authenticated;


-- 6. RPC ADMIN: AMBIL RIWAYAT PERANGKAT BERDASARKAN NIS
create or replace function public.admin_get_nis_device_details(
  target_nis text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_devices jsonb;
  v_logs jsonb;
  v_student_info jsonb;
begin
  if not exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  ) then
    raise exception 'Unauthorized: Akses khusus Admin';
  end if;

  -- 1. Info siswa dari profiles
  select jsonb_build_object(
    'nis', p.nis,
    'full_name', p.full_name,
    'username', p.username,
    'class_group', p.class_group
  )
  into v_student_info
  from public.profiles p
  where p.nis = target_nis
  limit 1;

  -- Fallback ke student_registry jika tabel ada
  if v_student_info is null and exists (
    select 1 from information_schema.tables
    where table_schema = 'public' and table_name = 'student_registry'
  ) then
    execute $dyn$
      select jsonb_build_object(
        'nis', sr.nis,
        'full_name', sr.full_name,
        'username', null,
        'class_group', sr.class_group
      )
      from public.student_registry sr
      where sr.nis = $1
      limit 1
    $dyn$
    into v_student_info
    using target_nis;
  end if;

  -- 2. Daftar binding perangkat
  select coalesce(jsonb_agg(
    jsonb_build_object(
      'device_id', b.device_id,
      'device_model', b.device_model,
      'first_used_at', b.first_used_at,
      'last_used_at', b.last_used_at,
      'is_unlinked', b.is_unlinked,
      'unlinked_at', b.unlinked_at
    ) order by b.last_used_at desc
  ), '[]'::jsonb)
  into v_devices
  from public.nis_device_bindings b
  where b.nis = target_nis;

  -- 3. 20 log autentikasi terakhir
  select coalesce(jsonb_agg(
    jsonb_build_object(
      'id', l.id,
      'device_id', l.device_id,
      'device_model', l.device_model,
      'event_type', l.event_type,
      'created_at', l.created_at
    ) order by l.created_at desc
  ), '[]'::jsonb)
  into v_logs
  from (
    select * from public.device_auth_logs
    where nis = target_nis
    order by created_at desc
    limit 20
  ) l;

  return jsonb_build_object(
    'student', v_student_info,
    'devices', v_devices,
    'recent_logs', v_logs
  );
end;
$$;

grant execute on function public.admin_get_nis_device_details(text) to authenticated;


-- 7. RPC ADMIN: UNLINK PERANGKAT DARI NIS (Siswa Lapor Ganti HP / Lepas Device)
create or replace function public.admin_unlink_nis_device(
  p_nis text,
  p_device_id text
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

  update public.nis_device_bindings
  set
    is_unlinked = true,
    unlinked_at = timezone('utc'::text, now()),
    unlinked_by = auth.uid()
  where nis = p_nis and device_id = p_device_id;

  return true;
end;
$$;

grant execute on function public.admin_unlink_nis_device(text, text) to authenticated;
