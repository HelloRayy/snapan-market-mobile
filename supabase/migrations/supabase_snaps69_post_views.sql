-- ==============================================================================
-- SNAPS-69: Migration Post Views Count with Per-Device Deduplication
-- ==============================================================================

-- 1. Tambah kolom views_count pada tabel market_posts
ALTER TABLE public.market_posts 
ADD COLUMN IF NOT EXISTS views_count bigint NOT NULL DEFAULT 0;

-- 2. Buat tabel post_views untuk mencatat riwayat tayangan per device
CREATE TABLE IF NOT EXISTS public.post_views (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid NOT NULL REFERENCES public.market_posts(id) ON DELETE CASCADE,
  device_id text NOT NULL,
  user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_post_device_view UNIQUE (post_id, device_id)
);

-- Index agar lookup post_id cepat
CREATE INDEX IF NOT EXISTS idx_post_views_post_id ON public.post_views(post_id);
CREATE INDEX IF NOT EXISTS idx_post_views_device_id ON public.post_views(device_id);

-- Aktifkan RLS
ALTER TABLE public.post_views ENABLE ROW LEVEL SECURITY;

-- Policy RLS: Siapa saja boleh select/membaca jumlah view
CREATE POLICY "Allow public read post_views"
ON public.post_views FOR SELECT
USING (true);

-- Policy RLS: Authenticated & anon users boleh insert record view
CREATE POLICY "Allow public insert post_views"
ON public.post_views FOR INSERT
WITH CHECK (true);

-- 3. Stored Procedure Atomic: record_post_view
-- Menerima post_id, device_id, dan user_id opsional
-- Mengembalikan views_count terbaru dari postingan
CREATE OR REPLACE FUNCTION public.record_post_view(
  p_post_id uuid,
  p_device_id text,
  p_user_id uuid DEFAULT NULL
)
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_inserted boolean := false;
  v_new_views_count bigint := 0;
BEGIN
  -- Validasi input
  IF p_post_id IS NULL OR p_device_id IS NULL OR trim(p_device_id) = '' THEN
    SELECT COALESCE(views_count, 0) INTO v_new_views_count FROM public.market_posts WHERE id = p_post_id;
    RETURN COALESCE(v_new_views_count, 0);
  END IF;

  -- 1. Coba insert deduplikasi device
  INSERT INTO public.post_views (post_id, device_id, user_id, created_at)
  VALUES (p_post_id, trim(p_device_id), p_user_id, now())
  ON CONFLICT (post_id, device_id) DO NOTHING;

  -- 2. Jika baru pertama kali dilihat oleh device ini (ter-insert), naikkan counter
  IF FOUND THEN
    UPDATE public.market_posts
    SET views_count = views_count + 1
    WHERE id = p_post_id
    RETURNING views_count INTO v_new_views_count;
  ELSE
    -- Device sudah pernah melihat, ambil nilai views_count saat ini tanpa menaikkan
    SELECT COALESCE(views_count, 0) INTO v_new_views_count
    FROM public.market_posts
    WHERE id = p_post_id;
  END IF;

  RETURN COALESCE(v_new_views_count, 0);
END;
$$;

-- Berikan izin akses RPC
GRANT EXECUTE ON FUNCTION public.record_post_view(uuid, text, uuid) TO anon, authenticated, service_role;
