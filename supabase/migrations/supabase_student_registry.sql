-- ========================================================
-- 🏫 SNAPAN MARKET MOBILE — STUDENT REGISTRY SCHEMA (SNAPS)
-- Master data NIS siswa untuk sistem registrasi instan & validasi akun
-- Jalankan di Supabase Dashboard -> SQL Editor
-- ========================================================

-- 1. Tambah kolom NIS pada tabel profiles
alter table public.profiles add column if not exists nis text unique;
create index if not exists idx_profiles_nis on public.profiles(nis);

-- 2. Buat tabel master data siswa (student_registry)
create table if not exists public.student_registry (
  nis text primary key,
  full_name text not null,
  class_group text not null,
  is_claimed boolean default false not null,
  claimed_by uuid references public.profiles(id) on delete set null,
  claimed_at timestamptz,
  created_at timestamptz default timezone('utc'::text, now()) not null
);

-- Index performa pencarian NIS & status klaim
create index if not exists idx_student_registry_nis on public.student_registry(nis);
create index if not exists idx_student_registry_is_claimed on public.student_registry(is_claimed);

-- 3. Row Level Security (RLS)
alter table public.student_registry enable row level security;

-- Publik (termasuk anonim) dapat membaca data untuk lookup NIS saat registrasi
create policy "Allow public read student registry for registration lookup"
on public.student_registry for select
to public
using (true);

-- Pengguna terautentikasi dapat mengklaim NIS mereka saat pendaftaran
create policy "Allow authenticated users to claim unassigned NIS"
on public.student_registry for update
to authenticated
using (is_claimed = false or claimed_by = auth.uid())
with check (claimed_by = auth.uid());

-- Admin memiliki akses penuh untuk kelola master data siswa
create policy "Allow admins full access to student registry"
on public.student_registry for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- 4. Publikasi Realtime untuk tabel student_registry
do $$
begin
  alter publication supabase_realtime add table public.student_registry;
exception when duplicate_object or others then null;
end $$;

-- 5. Seed data 36 siswa demo (11 PPLG 2)
insert into public.student_registry (nis, full_name, class_group)
values
  ('11816', 'AIDA DWI RIANA PUTRI', '11 PPLG 2'),
  ('11817', 'ALAIS LUTFI NAFISAH BILQIS', '11 PPLG 2'),
  ('11818', 'ALFIAN DZAKY RAMADHAN', '11 PPLG 2'),
  ('11819', 'ALYAA KHALISHA PUTRI', '11 PPLG 2'),
  ('11820', 'ANINDIKA NAILA SUJA', '11 PPLG 2'),
  ('11821', 'AQILA DALILATISYA', '11 PPLG 2'),
  ('11822', 'AURORA ZIFARA WULANDARI', '11 PPLG 2'),
  ('11823', 'CINDY CAHYA AMIKA PAMBUDI', '11 PPLG 2'),
  ('11824', 'CLAVINO AR-RAFII PRASETYO', '11 PPLG 2'),
  ('11825', 'CLOUDYA APRILIA ANGGREANI', '11 PPLG 2'),
  ('11826', 'DENIA PRIMISANI SHOFI', '11 PPLG 2'),
  ('11827', 'EKA PUTRA PURANDRITA', '11 PPLG 2'),
  ('11828', 'FASYA ANINDIA PUTRI', '11 PPLG 2'),
  ('11829', 'GENDHIS ROSE PANDANWANGI', '11 PPLG 2'),
  ('11830', 'IBNU ZAKY AHMAD HAIDAR', '11 PPLG 2'),
  ('11831', 'KARTIKA SULISTYOWATI', '11 PPLG 2'),
  ('11832', 'KEISHA PUTRI RATRI', '11 PPLG 2'),
  ('11833', 'MAHARANI ROSYADAH NAJAH', '11 PPLG 2'),
  ('11834', 'MUHAMAD RAMADHAN WAHYU PRATAMA', '11 PPLG 2'),
  ('11835', 'MUHAMMAD AZIS', '11 PPLG 2'),
  ('11836', 'MUHAMMAD TEGAR KURNIAWAN', '11 PPLG 2'),
  ('11837', 'MUHAMMAD YUSUF NARATAMA', '11 PPLG 2'),
  ('11838', 'NAIL AUN FAHD AL ROSYID', '11 PPLG 2'),
  ('11839', 'NAILA APRINZA', '11 PPLG 2'),
  ('11840', 'RADITYA RAYHAN YOGISWARA', '11 PPLG 2'),
  ('11841', 'RAIHAN YUSUF HABIBI', '11 PPLG 2'),
  ('11842', 'RASYA SATRIA WIBAWA', '11 PPLG 2'),
  ('11843', 'RAVIDYA SATRIO ADI', '11 PPLG 2'),
  ('11844', 'SHAFANIRA RISMA MULYA', '11 PPLG 2'),
  ('11845', 'SHESANATA RAF SANJANI', '11 PPLG 2'),
  ('11846', 'SHIFA RAHMA MAYSANI', '11 PPLG 2'),
  ('11847', 'SILA RAMADANI', '11 PPLG 2'),
  ('11848', 'SYAUQI ATHAYA RAMADHANI', '11 PPLG 2'),
  ('11849', 'TANIA CAHYONO', '11 PPLG 2'),
  ('11850', 'TSABITA TERU NABIL GHAZIYAH', '11 PPLG 2'),
  ('11851', 'ZHISKIND TARAKA ABRAR', '11 PPLG 2')
on conflict (nis) do update set
  full_name = excluded.full_name,
  class_group = excluded.class_group;
