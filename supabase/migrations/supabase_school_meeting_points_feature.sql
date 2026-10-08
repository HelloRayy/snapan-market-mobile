-- ==============================================================================
-- 🏫 SNAPAN MARKET MOBILE — SCHOOL MEETING POINTS (TITIK TEMU COD) MIGRATION
-- Tiket: SNAPS-62 (Manajemen Titik Temu COD Kampus SMKN 8 Semarang)
-- Jalankan skrip ini langsung di Supabase Dashboard -> SQL Editor
-- ==============================================================================

-- 0. Helper Function Cek Role Admin (Security Definer untuk menghindari infinite recursion)
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

-- 1. Buat Tabel school_meeting_points jika belum ada
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

-- Indeks performa pencarian spot berdasarkan lantai dan status aktif
create index if not exists idx_school_meeting_points_floor on public.school_meeting_points(floor);
create index if not exists idx_school_meeting_points_is_active on public.school_meeting_points(is_active);

-- 2. Aktifkan Row Level Security (RLS)
alter table public.school_meeting_points enable row level security;

-- 3. Kebijakan Akses Baca (SELECT): Publik dan Siswa bebas melihat seluruh titik temu COD
drop policy if exists "Public read meeting points" on public.school_meeting_points;
drop policy if exists "Public meeting points readable by everyone" on public.school_meeting_points;
create policy "Public read meeting points"
  on public.school_meeting_points
  for select
  using (true);

-- 4. Kebijakan Akses Tulis (INSERT): Hanya Admin yang berhak menambahkan titik temu COD baru
drop policy if exists "Admins can insert meeting points" on public.school_meeting_points;
create policy "Admins can insert meeting points"
  on public.school_meeting_points
  for insert
  to authenticated
  with check (public.is_admin());

-- 5. Kebijakan Akses Ubah (UPDATE): Hanya Admin yang berhak memperbarui nama, koordinat, atau status titik COD
drop policy if exists "Admins can update meeting points" on public.school_meeting_points;
create policy "Admins can update meeting points"
  on public.school_meeting_points
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- 6. Kebijakan Akses Hapus (DELETE): Hanya Admin yang berhak menghapus titik temu COD
drop policy if exists "Admins can delete meeting points" on public.school_meeting_points;
create policy "Admins can delete meeting points"
  on public.school_meeting_points
  for delete
  to authenticated
  using (public.is_admin());

-- 7. Seed Data Titik Temu Resmi SMKN 8 Semarang (Jika tabel masih kosong)
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
