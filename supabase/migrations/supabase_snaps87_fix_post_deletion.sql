-- ==============================================================================
-- MIGRATION: SNAPS-87 Permanent Hard Delete & Post Deletion Integrity
-- Purpose:
-- 1. Memberikan izin DELETE RLS policy bagi pemilik postingan (seller_id) dan Admin.
-- 2. Membersihkan postingan lama yang masih tersangkut dalam status soft-delete (deleted_at IS NOT NULL).
-- 3. Memperbaiki SELECT policy agar tidak membocorkan postingan terhapus kembali ke author.
-- ==============================================================================

-- 1. Bersihkan seluruh baris postingan yang sebelumnya tersimpan sebagai soft-delete
DELETE FROM public.market_posts 
WHERE deleted_at IS NOT NULL;

-- 2. Pastikan RLS Policy DELETE mengizinkan pemilik postingan atau admin
DROP POLICY IF EXISTS "Sellers can delete own posts" ON public.market_posts;
DROP POLICY IF EXISTS "Users can delete own posts" ON public.market_posts;
DROP POLICY IF EXISTS "Users or admins can delete posts" ON public.market_posts;

CREATE POLICY "Users or admins can delete posts" 
ON public.market_posts 
FOR DELETE 
TO authenticated 
USING (
  auth.uid() = seller_id 
  OR public.is_admin()
);

-- 3. Perbarui SELECT Policy untuk mencegah author melihat kembali data yang di-soft-delete (jika ada)
DROP POLICY IF EXISTS "Market posts viewable by everyone" ON public.market_posts;

CREATE POLICY "Market posts viewable by everyone" 
ON public.market_posts 
FOR SELECT 
USING (
  deleted_at IS NULL 
  OR public.is_admin()
);
