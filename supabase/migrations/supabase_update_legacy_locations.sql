-- ========================================================
-- SUPABASE MIGRATION: NORMALIZE LEGACY LOCATION TAGS
-- ========================================================
-- Salin dan jalankan seluruh SQL ini di:
-- Supabase Dashboard -> SQL Editor -> New Query -> Run

-- Perbarui semua postingan terdahulu yang masih menggunakan
-- label lokasi lama / parsial menjadi standar resmi: "SMKN 8 Semarang".
-- Query ini menjaga titik temu COD spesifik (seperti 'Lab PPLG 1', 'Kantin Belakang', dll).

UPDATE public.market_posts
SET location_tag = 'SMKN 8 Semarang'
WHERE location_tag IN (
  'SMKN 8',
  'SMKN8',
  'SMKN 8 Jakarta',
  'SMKN8 Jakarta',
  'SMKN 8 Jakarta - Snapan',
  'SMKN8 Jakarta - Snapan',
  'SMKN 8 Semarang - Snapan',
  'SMKN8 Semarang - Snapan',
  'SMKN8 Semarang',
  'Snapan',
  ''
)
OR location_tag IS NULL;

-- Verifikasi hasil pembaruan:
SELECT id, title, location_tag, created_at 
FROM public.market_posts 
ORDER BY created_at DESC;
