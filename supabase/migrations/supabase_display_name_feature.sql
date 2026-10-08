-- ==============================================================================
-- SNAPS MIGRATION: Fitur Display Name (SNAPS-59)
-- Menambahkan kolom display_name pada public.profiles & backfill dari auth metadata
-- Dijalankan langsung melalui Supabase SQL Editor
-- ==============================================================================

-- 1. Tambahkan kolom display_name pada tabel public.profiles jika belum ada
alter table public.profiles
  add column if not exists display_name text;

-- 2. Buat index pencarian untuk display_name jika ada pencarian pengguna
create index if not exists idx_profiles_display_name
  on public.profiles (display_name);

-- 3. Backfill otomatis: sinkronkan display_name dari metadata auth.users yang sudah ada
update public.profiles p
set display_name = (u.raw_user_meta_data->>'display_name')
from auth.users u
where p.id = u.id
  and u.raw_user_meta_data->>'display_name' is not null
  and (p.display_name is null or p.display_name = '');

-- 4. Notifikasi schema reload untuk PostgREST cache
notify pgrst, 'reload schema';
