-- ==============================================================================
-- MIGRATION: SNAPS Soft Delete & Storage Cleanup Lifecycle
-- Purpose: 
-- 1. Menambahkan kolom `deleted_at` ke `public.market_posts` untuk soft delete
-- 2. Partial index untuk menjamin query feed & user posts tetap 100% cepat
-- 3. Memperbarui RLS policy agar postingan yang terhapus tidak muncul ke publik
-- 4. Fungsi & Trigger/RPC untuk automasi pembersihan file di Supabase Storage
-- ==============================================================================

-- 1. Tambah kolom `deleted_at` di tabel `market_posts`
ALTER TABLE public.market_posts 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL;

-- 2. Partial Index untuk performa feed & profile tanpa terbebani baris deleted
-- Menjamin scan feed hanya memeriksa baris aktif (deleted_at IS NULL)
CREATE INDEX IF NOT EXISTS idx_market_posts_active_feed 
ON public.market_posts (created_at DESC) 
WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_market_posts_seller_active 
ON public.market_posts (seller_id, created_at DESC) 
WHERE deleted_at IS NULL;

-- 3. Perbarui RLS Policy untuk `SELECT` di `market_posts`
-- Publik hanya dapat melihat postingan yang belum dihapus (deleted_at IS NULL).
-- Pemilik postingan dan Admin tetap dapat melihat untuk kebutuhan audit/moderasi.
DROP POLICY IF EXISTS "Market posts viewable by everyone" ON public.market_posts;

CREATE POLICY "Market posts viewable by everyone" 
ON public.market_posts 
FOR SELECT 
USING (
  deleted_at IS NULL 
  OR auth.uid() = seller_id 
  OR public.is_admin()
);

-- 4. Perbarui Policy UPDATE agar user bisa melakukan soft-delete pada postingan miliknya
-- (dan Admin bisa soft-delete postingan siapapun)
DROP POLICY IF EXISTS "Sellers can update own posts" ON public.market_posts;
CREATE POLICY "Sellers can update own posts" 
ON public.market_posts 
FOR UPDATE 
USING (auth.uid() = seller_id OR public.is_admin());

-- 5. Helper Function: RPC untuk purge / hard-delete postingan yang sudah lewat masa retensi
-- (misal: 30 hari setelah deleted_at) sekaligus mengembalikan daftar image path yang siap dihapus dari Storage.
CREATE OR REPLACE FUNCTION public.get_expired_deleted_posts_media(days_retention integer DEFAULT 30)
RETURNS TABLE (
  post_id uuid,
  images text[]
)
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT id AS post_id, images
  FROM public.market_posts
  WHERE deleted_at IS NOT NULL 
    AND deleted_at < (NOW() - (days_retention || ' days')::interval);
$$;

COMMENT ON COLUMN public.market_posts.deleted_at IS 
'Timestamp penanda soft-delete. NULL berarti aktif, NOT NULL berarti dihapus oleh user/admin.';
