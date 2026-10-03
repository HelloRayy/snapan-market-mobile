-- ==============================================================================
-- SNAPAN MARKET - ADMIN PERFORMANCE OPTIMIZATION INDEXES
-- Sesuai panduan Supabase Postgres Best Practices:
-- 1. Partial & Compound Indexes untuk query status + urutan tanggal
-- 2. Foreign Key Indexes untuk join performant (reporter_id, post_id, seller_id)
-- ==============================================================================

-- 1. Index untuk query laporan status pending (AdminHeader & Tab Laporan)
-- Mempercepat query WHERE status = 'pending' ORDER BY created_at DESC secara instan (Index Scan vs Seq Scan)
CREATE INDEX IF NOT EXISTS idx_content_reports_status_created 
ON public.content_reports (status, created_at DESC);

-- 2. Index Foreign Key pada content_reports untuk percepatan JOIN PostgREST
CREATE INDEX IF NOT EXISTS idx_content_reports_post_id 
ON public.content_reports (post_id);

CREATE INDEX IF NOT EXISTS idx_content_reports_reporter_id 
ON public.content_reports (reporter_id);

-- 3. Compound Index pada market_posts untuk moderasi & dashboard feed
CREATE INDEX IF NOT EXISTS idx_market_posts_seller_created 
ON public.market_posts (seller_id, created_at DESC);

-- Analisis vacuum untuk memperbarui planner statistik Postgres
ANALYZE public.content_reports;
ANALYZE public.market_posts;
ANALYZE public.profiles;
