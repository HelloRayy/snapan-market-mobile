-- ========================================================
-- 🏫 SNAPAN MARKET MOBILE — AUTO SYNC KELAS DENGAN NIS (SNAPS-58)
-- Sinkronisasi otomatis class_group dan nis saat registrasi akun baru
-- Jalankan di Supabase Dashboard -> SQL Editor
-- ========================================================

-- 1. Pastikan kolom 'nis' dan 'display_name' tersedia di tabel profiles
alter table public.profiles add column if not exists nis text unique;
alter table public.profiles add column if not exists display_name text;
create index if not exists idx_profiles_nis on public.profiles(nis);

-- 2. Trigger Otomatis saat Pengguna Mendaftar (handle_new_user)
-- Mengambil data NIS, mengecek ke master student_registry jika ada,
-- dan memasang kelas yang sesuai langsung ke profiles.
create or replace function public.handle_new_user()
returns trigger as $$
declare
  v_nis text;
  v_class text;
  v_full_name text;
  v_display_name text;
  v_username text;
  v_avatar text;
begin
  -- Ekstraksi metadata dari raw_user_meta_data
  v_nis := nullif(trim(coalesce(new.raw_user_meta_data->>'nis', '')), '');
  v_class := nullif(trim(coalesce(new.raw_user_meta_data->>'class_group', '')), '');
  v_full_name := coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name', 'Pengguna Baru');
  v_display_name := nullif(trim(coalesce(new.raw_user_meta_data->>'display_name', '')), '');
  v_username := coalesce(new.raw_user_meta_data->>'username', lower(replace(v_full_name, ' ', '')));
  v_avatar := coalesce(new.raw_user_meta_data->>'avatar_url', new.raw_user_meta_data->>'picture', '');

  -- 2.1. Jika NIS disertakan, utamakan pencarian kelas dan nama resmi dari student_registry
  if v_nis is not null and exists (
    select 1 from information_schema.tables 
    where table_schema = 'public' and table_name = 'student_registry'
  ) then
    select class_group, full_name into v_class, v_full_name
    from public.student_registry
    where nis = v_nis
    limit 1;

    -- Tandai NIS telah diklaim di student_registry
    update public.student_registry
    set is_claimed = true,
        claimed_by = new.id,
        claimed_at = timezone('utc'::text, now())
    where nis = v_nis;
  end if;

  -- 2.2. Fallback kelas jika masih kosong atau bernilai 'Siswa Snapan'
  if v_class is null or v_class = '' or lower(v_class) = 'siswa snapan' then
    v_class := coalesce(nullif(trim(new.raw_user_meta_data->>'class_group'), ''), 'Siswa Snapan');
  end if;

  -- 2.3. Simpan ke public.profiles
  insert into public.profiles (
    id,
    full_name,
    display_name,
    username,
    avatar_url,
    class_group,
    nis
  )
  values (
    new.id,
    v_full_name,
    v_display_name,
    v_username,
    v_avatar,
    v_class,
    v_nis
  )
  on conflict (id) do update set
    full_name = case 
      when public.profiles.full_name is null or public.profiles.full_name = 'Pengguna Baru' 
      then excluded.full_name else public.profiles.full_name end,
    class_group = case 
      when public.profiles.class_group is null or public.profiles.class_group = 'Siswa Snapan' or public.profiles.class_group = ''
      then excluded.class_group else public.profiles.class_group end,
    nis = coalesce(public.profiles.nis, excluded.nis),
    display_name = coalesce(public.profiles.display_name, excluded.display_name);

  return new;
end;
$$ language plpgsql security definer;

-- 3. Pastikan trigger on_auth_user_created terpasang aktif
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 4. Sinkronisasi Data Lama (Self-healing migration untuk user yang terdaftar namun kelasnya masih 'Siswa Snapan')
do $$
begin
  if exists (
    select 1 from information_schema.tables 
    where table_schema = 'public' and table_name = 'student_registry'
  ) then
    -- Perbarui profiles yang memiliki NIS dan cocok dengan student_registry
    update public.profiles p
    set class_group = sr.class_group
    from public.student_registry sr
    where p.nis = sr.nis
      and (p.class_group is null or p.class_group = 'Siswa Snapan' or p.class_group = '')
      and sr.class_group is not null;
  end if;
end $$;
