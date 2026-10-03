-- =========================================================================
-- MIGRATION: C2C Peer-to-Peer Unified User Roles (SNAPS-22)
-- Deskripsi: Menyatukan role 'buyer' dan 'seller' menjadi 'user' (warga sekolah)
--           sehingga setiap siswa dapat bebas membeli dan menjual tanpa friksi.
-- =========================================================================

-- 1. Perbarui Constraint Role pada Tabel profiles
DO $$
BEGIN
  -- Lepas constraint lama jika ada
  ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_role_check;

  -- Pasang constraint baru: role utama 'user' dan 'admin' (kompatibel dgn 'buyer'/'seller' legacy)
  ALTER TABLE public.profiles ADD CONSTRAINT profiles_role_check 
    CHECK (role IN ('user', 'admin', 'buyer', 'seller'));

  -- Ubah default role akun baru menjadi 'user'
  ALTER TABLE public.profiles ALTER COLUMN role SET DEFAULT 'user';

  -- Migrasikan akun siswa lama ('buyer' / 'seller') menjadi 'user'
  UPDATE public.profiles SET role = 'user' WHERE role IN ('buyer', 'seller');
END $$;

-- 2. Pastikan RLS public.market_posts mengizinkan seluruh user terautentikasi membuat & mengelola listing produknya
DROP POLICY IF EXISTS "Sellers can insert own posts" ON public.market_posts;
DROP POLICY IF EXISTS "Users can insert own posts" ON public.market_posts;
CREATE POLICY "Users can insert own posts" ON public.market_posts 
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = seller_id);

DROP POLICY IF EXISTS "Sellers can update own posts" ON public.market_posts;
DROP POLICY IF EXISTS "Users can update own posts" ON public.market_posts;
CREATE POLICY "Users can update own posts" ON public.market_posts 
  FOR UPDATE TO authenticated USING (auth.uid() = seller_id);

DROP POLICY IF EXISTS "Sellers can delete own posts" ON public.market_posts;
DROP POLICY IF EXISTS "Users can delete own posts" ON public.market_posts;
CREATE POLICY "Users can delete own posts" ON public.market_posts 
  FOR DELETE TO authenticated USING (auth.uid() = seller_id);

-- 3. Perbarui fungsi admin_update_profile_role untuk mendukung role 'user' & 'admin'
CREATE OR REPLACE FUNCTION public.admin_update_profile_role(target_user_id UUID, new_role TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Unauthorized: Hanya admin yang dapat mengubah role akun.';
  END IF;

  IF new_role NOT IN ('user', 'admin', 'buyer', 'seller') THEN
    RAISE EXCEPTION 'Invalid role. Role harus bernilai user atau admin.';
  END IF;

  UPDATE public.profiles SET role = new_role WHERE id = target_user_id;
END;
$$;
