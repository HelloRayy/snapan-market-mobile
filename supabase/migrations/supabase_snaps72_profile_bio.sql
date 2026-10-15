-- ============================================================================
-- SNAPS-72: Public Bio, Link, & Interests Support for User Profiles
-- Fix: Bug bio tidak ditampilkan ketika user lain mengunjungi profil
-- ============================================================================

-- 1. Tambah kolom profil publik ke tabel public.profiles jika belum ada
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS bio text;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS link text;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS interests text;

-- 2. Backfill bio & link yang tersimpan di auth.users.raw_user_meta_data ke public.profiles
UPDATE public.profiles p
SET 
  bio = COALESCE(p.bio, NULLIF(TRIM(u.raw_user_meta_data->>'bio'), '')),
  link = COALESCE(p.link, NULLIF(TRIM(u.raw_user_meta_data->>'link'), ''))
FROM auth.users u
WHERE p.id = u.id 
  AND (u.raw_user_meta_data->>'bio' IS NOT NULL OR u.raw_user_meta_data->>'link' IS NOT NULL);

-- 3. Update handle_new_user() trigger function agar sinkron sejak pertama kali sign-up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
DECLARE
  v_nis text;
  v_class text;
  v_full_name text;
  v_display_name text;
  v_username text;
  v_avatar text;
  v_bio text;
  v_link text;
BEGIN
  v_nis := nullif(trim(coalesce(new.raw_user_meta_data->>'nis', '')), '');
  v_class := nullif(trim(coalesce(new.raw_user_meta_data->>'class_group', '')), '');
  v_full_name := coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name', 'Pengguna Baru');
  v_display_name := nullif(trim(coalesce(new.raw_user_meta_data->>'display_name', '')), '');
  v_username := coalesce(new.raw_user_meta_data->>'username', lower(replace(v_full_name, ' ', '')));
  v_avatar := coalesce(new.raw_user_meta_data->>'avatar_url', new.raw_user_meta_data->>'picture', '');
  v_bio := nullif(trim(coalesce(new.raw_user_meta_data->>'bio', '')), '');
  v_link := nullif(trim(coalesce(new.raw_user_meta_data->>'link', '')), '');

  IF v_nis IS NOT NULL AND EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name = 'student_registry'
  ) THEN
    SELECT class_group, full_name INTO v_class, v_full_name
    FROM public.student_registry
    WHERE nis = v_nis
    LIMIT 1;
  END IF;

  INSERT INTO public.profiles (
    id, full_name, display_name, username, class_group, nis, avatar_url, bio, link, is_verified, role
  ) VALUES (
    new.id,
    coalesce(v_full_name, 'Pengguna Baru'),
    v_display_name,
    v_username,
    coalesce(v_class, 'Siswa Snapan'),
    v_nis,
    v_avatar,
    v_bio,
    v_link,
    false,
    'user'
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    display_name = coalesce(EXCLUDED.display_name, profiles.display_name),
    username = coalesce(EXCLUDED.username, profiles.username),
    class_group = coalesce(EXCLUDED.class_group, profiles.class_group),
    nis = coalesce(EXCLUDED.nis, profiles.nis),
    avatar_url = coalesce(EXCLUDED.avatar_url, profiles.avatar_url),
    bio = coalesce(EXCLUDED.bio, profiles.bio),
    link = coalesce(EXCLUDED.link, profiles.link);

  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
