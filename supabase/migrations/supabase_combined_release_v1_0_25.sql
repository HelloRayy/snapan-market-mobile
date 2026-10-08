-- ==============================================================================
-- 🚀 SNAPAN MARKET PRODUCTION MIGRATION (v1.0.25) — TANPA SEED/INSERT
-- Tiket:
--   1. SNAPS-64: Auth Sync & Secure NIS Login Lookup
--   2. SNAPS-65: Fix Admin Role Toggle RPC (Admin <-> Siswa)
--   3. SNAPS-62 & SNAPS-66: Tabel school_meeting_points & RLS Policies
-- ==============================================================================

-- 0. Helper Function Cek Role Admin (SECURITY DEFINER)
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

-- 1. SNAPS-64: Loket Resmi Pencarian Kredensial Login (NIS & Username)
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

  return jsonb_build_object(
    'found', false,
    'type', 'unknown',
    'email', v_clean || '@snapan.id'
  );
end;
$$;

grant execute on function public.lookup_login_email(text) to anon, authenticated;

-- 2. SNAPS-64: Fungsi Ganti Username Atomis & Sinkronisasi Email Auth
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

  if length(v_clean_username) < 3 or length(v_clean_username) > 20 then
    return jsonb_build_object('success', false, 'error', 'Username harus antara 3 hingga 20 karakter.');
  end if;

  if not (v_clean_username ~ '^[a-z0-9_]+$') then
    return jsonb_build_object('success', false, 'error', 'Username hanya boleh memuat huruf, angka, dan garis bawah (_).');
  end if;

  select id into v_existing_id
  from public.profiles
  where lower(username) = v_clean_username and id <> v_user_id
  limit 1;

  if v_existing_id is not null then
    return jsonb_build_object('success', false, 'error', 'Username @' || v_clean_username || ' sudah digunakan oleh akun lain.');
  end if;

  update public.profiles
  set username = v_clean_username
  where id = v_user_id;

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

-- 3. SNAPS-64: Data Repair Akun yang Sempat Tidak Sinkron
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

-- 4. SNAPS-65: RPC Switch Role Admin <-> Siswa (Bypass RLS Recursion)
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

-- 5. SNAPS-62 & SNAPS-66: Tabel school_meeting_points & Kebijakan Keamanan RLS
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

-- Public / Mobile Siswa READ (SELECT)
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
