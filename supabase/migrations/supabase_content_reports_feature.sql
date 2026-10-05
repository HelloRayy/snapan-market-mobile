-- ========================================================
-- 🛡️ SNAPAN MARKET MOBILE — CONTENT REPORTS FEATURE MIGRATION
-- Copy & Paste isi file ini ke Supabase Dashboard -> SQL Editor
-- ========================================================

-- 1. TABEL CONTENT REPORTS (Laporan Konten Pengguna)
create table if not exists public.content_reports (
  id uuid default gen_random_uuid() primary key,
  post_id uuid references public.market_posts(id) on delete cascade not null,
  reporter_id uuid references public.profiles(id) on delete cascade not null,
  reason text not null,
  details text,
  status text default 'pending' check (status in ('pending', 'resolved', 'dismissed')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  resolved_at timestamp with time zone,
  resolved_by uuid references public.profiles(id) on delete set null
);

-- Indexing untuk query admin dan pelaporan cepat
create index if not exists idx_content_reports_post_id on public.content_reports(post_id);
create index if not exists idx_content_reports_reporter_id on public.content_reports(reporter_id);
create index if not exists idx_content_reports_status on public.content_reports(status);
create index if not exists idx_content_reports_created_at on public.content_reports(created_at desc);

-- 2. ROW LEVEL SECURITY (RLS) POLICIES
alter table public.content_reports enable row level security;

-- Drop policy lama jika ada
drop policy if exists "Users can submit reports" on public.content_reports;
drop policy if exists "Users and Admins can view reports" on public.content_reports;
drop policy if exists "Admins can update report status" on public.content_reports;

-- User terotentikasi dapat mengirimkan laporan (pelapor = auth.uid())
create policy "Users can submit reports" on public.content_reports
  for insert to authenticated
  with check ((select auth.uid()) = reporter_id);

-- Laporan dapat dibaca oleh admin dan pelapor sendiri (atau umum untuk dashboard pengawasan admin)
create policy "Users and Admins can view reports" on public.content_reports
  for select
  using (
    (select auth.uid()) = reporter_id or
    exists (
      select 1 from public.profiles
      where profiles.id = (select auth.uid()) and profiles.role = 'admin'
    )
  );

-- Admin dapat mengupdate status laporan (pending / resolved / dismissed)
create policy "Admins can update report status" on public.content_reports
  for update
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = (select auth.uid()) and profiles.role = 'admin'
    )
  )
  with check (
    exists (
      select 1 from public.profiles
      where profiles.id = (select auth.uid()) and profiles.role = 'admin'
    )
  );

-- Function RPC untuk admin update status laporan secara aman jika RLS bypass dibutuhkan
create or replace function public.admin_update_report_status(
  target_report_id uuid,
  new_status text,
  admin_user_id uuid
)
returns void as $$
begin
  update public.content_reports
  set
    status = new_status,
    resolved_at = case when new_status in ('resolved', 'dismissed') then now() else null end,
    resolved_by = case when new_status in ('resolved', 'dismissed') then admin_user_id else null end
  where id = target_report_id;
end;
$$ language plpgsql security definer;
