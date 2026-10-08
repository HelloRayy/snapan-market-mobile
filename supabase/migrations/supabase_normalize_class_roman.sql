-- ==============================================================================
-- SNAPS MIGRATION: Standarisasi Format Penamaan Kelas Siswa (SNAPS-61)
-- Mengubah format angka arab (10, 11, 12) menjadi Romawi baku (X, XI, XII)
-- Dijalankan langsung melalui Supabase SQL Editor
-- ==============================================================================

-- 1. Normalisasi awalan angka tingkat ke Romawi pada tabel public.profiles
update public.profiles
set class_group = regexp_replace(
  regexp_replace(
    regexp_replace(
      trim(class_group),
      '^10[\s\-_/]+', 'X '
    ),
    '^11[\s\-_/]+', 'XI '
  ),
  '^12[\s\-_/]+', 'XII '
)
where class_group ~ '^(10|11|12)[\s\-_/]';

-- 2. Standarisasi kapitalisasi singkatan jurusan
update public.profiles
set class_group = regexp_replace(class_group, 'pplg', 'PPLG', 'i')
where class_group ~* 'pplg' and class_group !~ 'PPLG';

update public.profiles
set class_group = regexp_replace(class_group, 'tjkt', 'TJKT', 'i')
where class_group ~* 'tjkt' and class_group !~ 'TJKT';

update public.profiles
set class_group = regexp_replace(class_group, 'dkv', 'DKV', 'i')
where class_group ~* 'dkv' and class_group !~ 'DKV';

update public.profiles
set class_group = regexp_replace(class_group, 'ps', 'PS', 'i')
where class_group ~* 'ps' and class_group !~ 'PS';

update public.profiles
set class_group = regexp_replace(class_group, 'lk', 'LK', 'i')
where class_group ~* 'lk' and class_group !~ 'LK';

-- 3. Notifikasi reload schema PostgREST
notify pgrst, 'reload schema';
