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

-- Data contoh versi terbaru (bisa diubah URL download APK-nya)
insert into public.app_versions (version_code, version_name, download_url, title, changelog, is_mandatory, is_active)
values (
  2,
  '1.0.1',
  'https://raw.githubusercontent.com/HelloRayy/snapan-market-mobile/main/build/app/outputs/flutter-apk/app-release.apk',
  'Pembaruan Snaps v1.0.1',
  '• Fitur hapus postingan sendiri & moderasi admin\n• Perbaikan sinkronisasi edit profil ke database\n• Peningkatan kecepatan loading dan animasi',
  false,
  true
);
