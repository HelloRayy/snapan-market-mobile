-- ==============================================================================
-- 🚀 SNAPS-66 ONLY: Integration of Location Dashboard with Mobile App
-- Murni Tabel & Policy RLS untuk sinkronisasi Peta Titik Temu COD (Tanpa INSERT)
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

create index if not exists idx_school_meeting_points_floor on public.school_meeting_points(floor);
create index if not exists idx_school_meeting_points_is_active on public.school_meeting_points(is_active);

-- 2. Aktifkan Row Level Security (RLS)
alter table public.school_meeting_points enable row level security;

-- 3. Kebijakan Baca (SELECT): Mobile app & publik dapat membaca seluruh titik aktif
drop policy if exists "Public read meeting points" on public.school_meeting_points;
drop policy if exists "Public meeting points readable by everyone" on public.school_meeting_points;
create policy "Public read meeting points"
  on public.school_meeting_points
  for select
  using (true);

-- 4. Kebijakan Tulis (INSERT): Dashboard Admin
drop policy if exists "Admins can insert meeting points" on public.school_meeting_points;
create policy "Admins can insert meeting points"
  on public.school_meeting_points
  for insert
  to authenticated
  with check (public.is_admin());

-- 5. Kebijakan Ubah (UPDATE): Dashboard Admin
drop policy if exists "Admins can update meeting points" on public.school_meeting_points;
create policy "Admins can update meeting points"
  on public.school_meeting_points
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- 6. Kebijakan Hapus (DELETE): Dashboard Admin
drop policy if exists "Admins can delete meeting points" on public.school_meeting_points;
create policy "Admins can delete meeting points"
  on public.school_meeting_points
  for delete
  to authenticated
  using (public.is_admin());
