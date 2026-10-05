-- ========================================================
-- 📲 TABEL APP VERSIONS & IN-APP UPDATE SNAPAN MARKET
-- ========================================================
-- Jalankan query ini di: Supabase Dashboard -> SQL Editor -> Run

create table if not exists public.app_versions (
  id uuid primary key default gen_random_uuid(),
  version_code integer not null,
  version_name text not null,
  download_url text not null,
  title text default 'Pembaruan Tersedia',
  changelog text default 'Pembaruan sistem dan perbaikan performa aplikasi.',
  is_mandatory boolean default false,
  is_active boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS
alter table public.app_versions enable row level security;

-- Policy: Semua pengguna (authenticated & anonim) dapat membaca versi terbaru
drop policy if exists "App versions viewable by everyone" on public.app_versions;
create policy "App versions viewable by everyone"
on public.app_versions for select
using (true);

-- Policy: Hanya Admin yang dapat menambah/mengubah versi aplikasi
drop policy if exists "Admins can manage app versions" on public.app_versions;
create policy "Admins can manage app versions"
on public.app_versions for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- Index untuk query versi aktif terbaru dengan cepat
create index if not exists idx_app_versions_active_code on public.app_versions (is_active, version_code desc);

-- Data versi terbaru untuk rilis OTA v1.0.2
insert into public.app_versions (version_code, version_name, download_url, title, changelog, is_mandatory, is_active)
values (
  3,
  '1.0.2',
  'https://github.com/HelloRayy/snapan-market-mobile/releases/download/v1.0.2/app-release.apk',
  'Pembaruan Snaps v1.0.2',
  '• Sidebar drawer navigasi baru dari sisi kiri ke kanan\n• Navigasi langsung ke profil saat mengetuk akun rekomendasi di pencarian\n• Peningkatan kecepatan dan perbaikan sistem',
  false,
  true
);
