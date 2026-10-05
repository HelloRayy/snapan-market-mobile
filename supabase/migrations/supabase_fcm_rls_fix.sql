-- =========================================================================
-- SNAPS NOTIFICATION & FCM RLS FIX MIGRATION
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard/project/lcwsxldnoqjdfqxqcqja/sql
-- =========================================================================

-- 1. Pastikan tabel user_fcm_tokens memiliki RLS aktif
alter table if exists public.user_fcm_tokens enable row level security;

-- 2. Policy SELECT: Pengguna dapat membaca token miliknya, dan Admin dapat membaca seluruh token siswa untuk push broadcast
drop policy if exists "Users and Admins can view fcm tokens" on public.user_fcm_tokens;
drop policy if exists "Users can view own fcm tokens" on public.user_fcm_tokens;
drop policy if exists "Admins can view all fcm tokens" on public.user_fcm_tokens;

create policy "Users and Admins can view fcm tokens"
on public.user_fcm_tokens
for select
to authenticated
using (
  auth.uid() = user_id 
  or public.is_admin()
);

-- 3. Policy INSERT & UPDATE: Pengguna dapat mendaftarkan dan memperbarui token perangkatnya sendiri
drop policy if exists "Users can insert own fcm tokens" on public.user_fcm_tokens;
create policy "Users can insert own fcm tokens"
on public.user_fcm_tokens
for insert
to authenticated
with check (
  auth.uid() = user_id
);

drop policy if exists "Users can update own fcm tokens" on public.user_fcm_tokens;
create policy "Users can update own fcm tokens"
on public.user_fcm_tokens
for update
to authenticated
using (
  auth.uid() = user_id
)
with check (
  auth.uid() = user_id
);

-- 4. Policy DELETE: Pengguna dapat menghapus token miliknya saat logout, dan Admin dapat menghapus token yang sudah hangus (UNREGISTERED)
drop policy if exists "Users and Admins can delete fcm tokens" on public.user_fcm_tokens;
create policy "Users and Admins can delete fcm tokens"
on public.user_fcm_tokens
for delete
to authenticated
using (
  auth.uid() = user_id 
  or public.is_admin()
);

-- 5. Policy SELECT pada tabel notifications untuk Admin
-- Agar Web Admin dapat membaca riwayat broadcast seluruh siswa pada tab Broadcast Notifikasi
drop policy if exists "Users and Admins can view notifications" on public.notifications;
drop policy if exists "Admins can view all notifications" on public.notifications;

create policy "Users and Admins can view notifications"
on public.notifications
for select
to authenticated
using (
  auth.uid() = user_id 
  or public.is_admin()
);

-- Selesai!
