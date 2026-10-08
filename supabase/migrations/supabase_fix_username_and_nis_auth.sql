-- ==============================================================================
-- MIGRATION: SNAPS-64 - Fix Username Change Auth Sync & Secure NIS Login Lookup
-- ==============================================================================
-- Salin dan jalankan seluruh SQL ini di Supabase Dashboard -> SQL Editor:
-- https://supabase.com/dashboard/project/lcwsxldnoqjdfqxqcqja/sql
-- ==============================================================================

-- 1. Fungsi Loket Resmi Pencarian Kredensial Login (NIS & Username)
-- Aman untuk diakses oleh anon (pengguna di layar login sebelum terautentikasi)
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

-- 2. Fungsi Atomis Ganti Username & Sinkronisasi Email Auth (SNAPS-64)
-- Memperbarui public.profiles.username dan auth.users.email secara bersamaan
-- tanpa memerlukan konfirmasi email link atau pemutusan sesi login.
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

  -- Validasi format karakter (huruf kecil, angka, underscore)
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

-- 3. Data Repair: Perbaiki seluruh data auth.users yang sempat tidak sinkron dengan profiles
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
