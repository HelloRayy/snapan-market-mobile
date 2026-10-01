-- ========================================================
-- 📊 FITUR POLLING POST FEED - SNAPAN MARKET MOBILE
-- ========================================================
-- Jalankan query ini di: Supabase Dashboard -> SQL Editor -> Run

-- 1. Tambah kolom poll JSONB ke tabel market_posts
ALTER TABLE public.market_posts 
ADD COLUMN IF NOT EXISTS poll JSONB DEFAULT NULL;

-- 2. Buat tabel pencatat suara siswa (mencegah manipulasi/vote ganda)
CREATE TABLE IF NOT EXISTS public.post_poll_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES public.market_posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    option_id TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_user_post_option UNIQUE (post_id, user_id, option_id)
);

-- Index performa pencarian vote user
CREATE INDEX IF NOT EXISTS idx_poll_votes_post_user 
ON public.post_poll_votes(post_id, user_id);

-- RLS Policies
ALTER TABLE public.post_poll_votes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Poll votes viewable by everyone" ON public.post_poll_votes;
CREATE POLICY "Poll votes viewable by everyone" 
ON public.post_poll_votes FOR SELECT USING (true);

DROP POLICY IF EXISTS "Authenticated users can vote" ON public.post_poll_votes;
CREATE POLICY "Authenticated users can vote" 
ON public.post_poll_votes FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can remove vote" ON public.post_poll_votes;
CREATE POLICY "Users can remove vote" 
ON public.post_poll_votes FOR DELETE 
TO authenticated 
USING (auth.uid() = user_id);

-- 3. Fungsi Atomic Voting (vote_poll)
CREATE OR REPLACE FUNCTION public.vote_poll(
    p_post_id UUID,
    p_option_ids TEXT[]
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_post RECORD;
    v_poll JSONB;
    v_options JSONB;
    v_opt JSONB;
    v_opt_id TEXT;
    v_new_options JSONB := '[]'::JSONB;
    v_opt_count INT;
    v_total_votes INT := 0;
    v_opt_idx INT;
    v_is_closed BOOLEAN;
    v_expires_at TIMESTAMPTZ;
    v_allow_change BOOLEAN;
    v_is_multiple BOOLEAN;
    v_existing_votes_count INT;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Pengguna harus login untuk memberikan suara.';
    END IF;

    -- Ambil data post & poll
    SELECT id, poll, seller_id INTO v_post
    FROM public.market_posts
    WHERE id = p_post_id;

    IF NOT FOUND OR v_post.poll IS NULL THEN
        RAISE EXCEPTION 'Polling tidak ditemukan pada postingan ini.';
    END IF;

    v_poll := v_post.poll;
    v_is_closed := COALESCE((v_poll->>'is_closed')::BOOLEAN, false);
    v_expires_at := (v_poll->>'expires_at')::TIMESTAMPTZ;
    v_allow_change := COALESCE((v_poll->>'allow_change_vote')::BOOLEAN, true);
    v_is_multiple := COALESCE((v_poll->>'is_multiple_choice')::BOOLEAN, false);

    -- Cek apakah polling sudah ditutup atau melewati deadline
    IF v_is_closed OR (v_expires_at IS NOT NULL AND NOW() > v_expires_at) THEN
        RAISE EXCEPTION 'Polling sudah berakhir dan tidak menerima suara lagi.';
    END IF;

    -- Cek vote yang sudah ada dari user ini
    SELECT COUNT(*) INTO v_existing_votes_count
    FROM public.post_poll_votes
    WHERE post_id = p_post_id AND user_id = v_user_id;

    IF v_existing_votes_count > 0 AND NOT v_allow_change THEN
        RAISE EXCEPTION 'Pilihan sudah terkunci dan tidak dapat diubah.';
    END IF;

    -- Jika multiple choice tidak aktif tapi mengirim > 1 opsi
    IF NOT v_is_multiple AND array_length(p_option_ids, 1) > 1 THEN
        RAISE EXCEPTION 'Hanya diizinkan memilih 1 opsi.';
    END IF;

    -- Hapus vote lama jika ganti pilihan
    DELETE FROM public.post_poll_votes
    WHERE post_id = p_post_id AND user_id = v_user_id;

    -- Masukkan vote baru
    FOREACH v_opt_id IN ARRAY p_option_ids LOOP
        INSERT INTO public.post_poll_votes (post_id, user_id, option_id)
        VALUES (p_post_id, v_user_id, v_opt_id);
    END LOOP;

    -- Hitung ulang total suara per opsi langsung dari tabel votes
    v_options := v_poll->'options';
    FOR v_opt_idx IN 0 .. jsonb_array_length(v_options) - 1 LOOP
        v_opt := v_options->v_opt_idx;
        v_opt_id := v_opt->>'id';

        SELECT COUNT(*) INTO v_opt_count
        FROM public.post_poll_votes
        WHERE post_id = p_post_id AND option_id = v_opt_id;

        v_total_votes := v_total_votes + v_opt_count;
        v_opt := jsonb_set(v_opt, '{votes_count}', to_jsonb(v_opt_count));
        v_new_options := v_new_options || v_opt;
    END LOOP;

    -- Perbarui JSONB poll di market_posts
    v_poll := jsonb_set(v_poll, '{options}', v_new_options);
    v_poll := jsonb_set(v_poll, '{total_votes}', to_jsonb(v_total_votes));

    UPDATE public.market_posts
    SET poll = v_poll
    WHERE id = p_post_id;

    RETURN v_poll;
END;
$$;

-- 4. Fungsi Tutup Polling Lebih Awal (close_poll)
CREATE OR REPLACE FUNCTION public.close_poll(
    p_post_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_post RECORD;
    v_poll JSONB;
BEGIN
    SELECT id, poll, seller_id INTO v_post
    FROM public.market_posts
    WHERE id = p_post_id;

    IF NOT FOUND OR v_post.poll IS NULL THEN
        RAISE EXCEPTION 'Polling tidak ditemukan.';
    END IF;

    -- Hanya pembuat postingan atau admin yang bisa menutup polling lebih awal
    IF v_post.seller_id != v_user_id AND NOT public.is_admin() THEN
        RAISE EXCEPTION 'Hanya pembuat postingan yang dapat menutup polling.';
    END IF;

    v_poll := jsonb_set(v_post.poll, '{is_closed}', 'true'::JSONB);

    UPDATE public.market_posts
    SET poll = v_poll
    WHERE id = p_post_id;

    RETURN v_poll;
END;
$$;
