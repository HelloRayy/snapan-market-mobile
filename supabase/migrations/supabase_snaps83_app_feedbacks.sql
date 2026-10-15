-- ========================================================
-- 🛡️ SNAPAN MARKET MOBILE — SNAPS-83 APP FEEDBACKS MIGRATION
-- Copy & Paste isi file ini ke Supabase Dashboard -> SQL Editor
-- ========================================================

-- 1. TABEL APP FEEDBACKS (Laporan Masalah & Masukan Aplikasi)
CREATE TABLE IF NOT EXISTS public.app_feedbacks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    category TEXT NOT NULL, -- 'bug_ui', 'fitur_error', 'gagal_unggah', 'lag', 'lainnya'
    custom_topic TEXT,
    description TEXT NOT NULL,
    screenshot_url TEXT,
    app_version TEXT,
    device_info JSONB,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'investigating', 'resolved', 'ignored')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ,
    admin_note TEXT
);

-- Indexing untuk query admin & filter status
CREATE INDEX IF NOT EXISTS idx_app_feedbacks_user_id ON public.app_feedbacks(user_id);
CREATE INDEX IF NOT EXISTS idx_app_feedbacks_category ON public.app_feedbacks(category);
CREATE INDEX IF NOT EXISTS idx_app_feedbacks_status ON public.app_feedbacks(status);
CREATE INDEX IF NOT EXISTS idx_app_feedbacks_created_at ON public.app_feedbacks(created_at DESC);

-- 2. ROW LEVEL SECURITY (RLS) POLICIES
ALTER TABLE public.app_feedbacks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated insert feedbacks" ON public.app_feedbacks;
DROP POLICY IF EXISTS "Allow anon insert feedbacks" ON public.app_feedbacks;
DROP POLICY IF EXISTS "Allow users read own feedbacks" ON public.app_feedbacks;
DROP POLICY IF EXISTS "Allow admins manage feedbacks" ON public.app_feedbacks;

-- Izinkan pengguna terotentikasi dan tamu mengirimkan laporan
CREATE POLICY "Allow authenticated insert feedbacks"
    ON public.app_feedbacks FOR INSERT
    TO authenticated
    WITH CHECK (true);

CREATE POLICY "Allow anon insert feedbacks"
    ON public.app_feedbacks FOR INSERT
    TO anon
    WITH CHECK (true);

-- Pengguna hanya bisa membaca feedback buatannya sendiri
CREATE POLICY "Allow users read own feedbacks"
    ON public.app_feedbacks FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- Admin dapat membaca dan memperbarui semua feedback
CREATE POLICY "Allow admins manage feedbacks"
    ON public.app_feedbacks FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
        )
    );

-- 3. STORAGE BUCKET UNTUK SCREENSHOT (feedback_attachments)
-- Buat bucket publik untuk lampiran screenshot jika belum ada
INSERT INTO storage.buckets (id, name, public)
VALUES ('feedback_attachments', 'feedback_attachments', true)
ON CONFLICT (id) DO NOTHING;

-- Policy Storage: Izinkan upload untuk pengguna
DROP POLICY IF EXISTS "Allow public upload feedback attachments" ON storage.objects;
CREATE POLICY "Allow public upload feedback attachments"
    ON storage.objects FOR INSERT
    TO authenticated, anon
    WITH CHECK (bucket_id = 'feedback_attachments');

DROP POLICY IF EXISTS "Allow public view feedback attachments" ON storage.objects;
CREATE POLICY "Allow public view feedback attachments"
    ON storage.objects FOR SELECT
    TO public
    USING (bucket_id = 'feedback_attachments');
