-- ========================================================
-- 📲 RILIS PENTING OTA SNAPS v1.0.18 (MANDATORY UPDATE)
-- ========================================================
-- Jalankan query ini di: Supabase Dashboard -> SQL Editor -> Run

-- 1. Nonaktifkan versi sebelumnya agar v1.0.18 menjadi versi aktif utama
update public.app_versions
set is_active = false
where version_code < 20;

-- 2. Daftarkan Rilis v1.0.18 sebagai update penting / mandatory (is_mandatory: true)
insert into public.app_versions (
  version_code,
  version_name,
  download_url,
  title,
  changelog,
  is_mandatory,
  is_active
) values (
  20,
  '1.0.18',
  'https://github.com/HelloRayy/snapan-market-mobile/releases/download/v1.0.18/app-release.apk',
  'Pembaruan Penting Snaps v1.0.18',
  '• Perbaikan sistem: Like komentar kini tersimpan permanen dan sinkron otomatis dengan detail feed.\n• Optimalisasi penyimpanan HP: Pembersihan otomatis cache berkas APK sisa update lama (menghemat ruang hingga ~0.9 GB).',
  true,
  true
);
