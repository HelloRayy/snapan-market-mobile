-- ==============================================================================
-- SNAPS MIGRATION: Fitur Hapus Akun Admin Dashboard (SNAPS-Admin-Delete-Account)
-- Memungkinkan Administrator menghapus akun siswa secara permanen.
-- Seluruh postingan, data transaksi, dan interaksi sosial dibersihkan,
-- serta Username dan NIS dibebaskan kembali agar dapat didaftarkan ulang.
-- Jalankan langsung di Supabase Dashboard -> SQL Editor
-- ==============================================================================

-- 0. Helper Function Cek Role Admin (Security Definer untuk menghindari infinite recursion)
create or replace function public.is_admin()
returns boolean
language sql
security definer
stable
set search_path = public, auth
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- 1. Kebijakan RLS agar Admin berhak menghapus baris di public.profiles
drop policy if exists "Admins can delete any profile" on public.profiles;
create policy "Admins can delete any profile"
on public.profiles
for delete
to authenticated
using (public.is_admin());

-- 2. Kebijakan RLS agar Admin berhak menghapus orders saat penghapusan akun
drop policy if exists "Admins can delete orders" on public.orders;
create policy "Admins can delete orders"
on public.orders
for delete
to authenticated
using (public.is_admin());

-- 3. RPC Function: Admin Delete User Permanently (Security Definer)
create or replace function public.admin_delete_user(target_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_nis text;
  v_username text;
  v_admin_email text;
begin
  -- 3.1. Verifikasi Otoritas Admin
  if not public.is_admin() then
    raise exception 'Unauthorized: Hanya administrator yang berhak menghapus akun pengguna.';
  end if;

  -- 3.2. Cegah Admin menghapus akun sendiri
  if target_user_id = auth.uid() then
    raise exception 'Invalid Operation: Administrator tidak diizinkan menghapus akun sendiri.';
  end if;

  -- Ambil data identifikasi sebelum baris profil dihapus
  -- Aman: Deteksi dinamis apakah kolom nis sudah ada di tabel public.profiles
  if exists (
    select 1 from information_schema.columns 
    where table_schema = 'public' and table_name = 'profiles' and column_name = 'nis'
  ) then
    execute 'select nis, username from public.profiles where id = $1'
    into v_nis, v_username
    using target_user_id;
  else
    select username into v_username
    from public.profiles
    where id = target_user_id;
  end if;

  select coalesce(auth.jwt()->>'email', 'admin@snaps.internal') into v_admin_email;

  -- 3.3. Lepaskan klaim master data siswa (student_registry)
  -- Bebaskan NIS agar bisa didaftarkan kembali oleh pengguna baru
  if exists (select from pg_tables where schemaname = 'public' and tablename = 'student_registry') then
    if v_nis is not null then
      execute 'update public.student_registry set is_claimed = false, claimed_by = null, claimed_at = null where claimed_by = $1 or nis = $2'
      using target_user_id, v_nis;
    else
      execute 'update public.student_registry set is_claimed = false, claimed_by = null, claimed_at = null where claimed_by = $1'
      using target_user_id;
    end if;
  end if;

  -- 3.4. Bersihkan data transaksi (orders) agar tidak melanggar foreign key restrict
  if exists (select from pg_tables where schemaname = 'public' and tablename = 'orders') then
    -- Lepaskan relasi cancelled_by jika user membatalkan pesanan orang lain
    update public.orders
    set cancelled_by = null
    where cancelled_by = target_user_id;

    -- Hapus pesanan di mana user adalah pembeli atau penjual
    delete from public.orders
    where buyer_id = target_user_id or seller_id = target_user_id;

    -- Hapus pesanan pada postingan yang dimiliki user
    delete from public.orders
    where post_id in (select id from public.market_posts where seller_id = target_user_id);
  end if;

  -- 3.5. Bersihkan data order_notifications
  if exists (select from pg_tables where schemaname = 'public' and tablename = 'order_notifications') then
    delete from public.order_notifications where recipient_id = target_user_id;
  end if;

  -- 3.6. Bersihkan cart_items, post_bookmarks, reposts
  if exists (select from pg_tables where schemaname = 'public' and tablename = 'cart_items') then
    delete from public.cart_items where user_id = target_user_id;
  end if;

  if exists (select from pg_tables where schemaname = 'public' and tablename = 'post_bookmarks') then
    delete from public.post_bookmarks where user_id = target_user_id;
  end if;

  if exists (select from pg_tables where schemaname = 'public' and tablename = 'post_reposts') then
    delete from public.post_reposts where user_id = target_user_id;
  end if;

  -- 3.7. Hapus semua postingan pasar & utas feed milik pengguna
  -- (Cascade akan membersihkan likes dan comments terkait)
  delete from public.market_posts
  where seller_id = target_user_id;

  -- 3.8. Hapus interaksi sosial & riwayat terkait
  delete from public.post_likes where user_id = target_user_id;
  delete from public.post_comments where user_id = target_user_id;

  if exists (select from pg_tables where schemaname = 'public' and tablename = 'comment_likes') then
    delete from public.comment_likes where user_id = target_user_id;
  end if;

  if exists (select from pg_tables where schemaname = 'public' and tablename = 'user_follows') then
    delete from public.user_follows where follower_id = target_user_id or following_id = target_user_id;
  end if;

  if exists (select from pg_tables where schemaname = 'public' and tablename = 'follows') then
    delete from public.follows where follower_id = target_user_id or following_id = target_user_id;
  end if;

  -- FIX: Tabel notifications menggunakan kolom user_id dan actor_id (bukan recipient_id).
  -- Didukung deteksi dinamis kolom untuk mencegah error runtime 42703.
  if exists (select from pg_tables where schemaname = 'public' and tablename = 'notifications') then
    if exists (
      select 1 from information_schema.columns 
      where table_schema = 'public' and table_name = 'notifications' and column_name = 'user_id'
    ) then
      delete from public.notifications where user_id = target_user_id or actor_id = target_user_id;
    elsif exists (
      select 1 from information_schema.columns 
      where table_schema = 'public' and table_name = 'notifications' and column_name = 'recipient_id'
    ) then
      delete from public.notifications where recipient_id = target_user_id or actor_id = target_user_id;
    end if;
  end if;

  if exists (select from pg_tables where schemaname = 'public' and tablename = 'content_reports') then
    update public.content_reports set resolved_by = null where resolved_by = target_user_id;
    delete from public.content_reports where reporter_id = target_user_id;
  end if;

  if exists (select from pg_tables where schemaname = 'public' and tablename = 'direct_messages') then
    delete from public.direct_messages where sender_id = target_user_id;
  end if;

  if exists (select from pg_tables where schemaname = 'public' and tablename = 'conversations') then
    delete from public.conversations where participant_one = target_user_id or participant_two = target_user_id;
  end if;

  if exists (select from pg_tables where schemaname = 'public' and tablename = 'chat_conversations') then
    delete from public.chat_conversations where participant_one = target_user_id or participant_two = target_user_id;
  end if;

  if exists (select from pg_tables where schemaname = 'public' and tablename = 'post_poll_votes') then
    delete from public.post_poll_votes where user_id = target_user_id;
  end if;

  if exists (select from pg_tables where schemaname = 'public' and tablename = 'device_registrations') then
    delete from public.device_registrations where user_id = target_user_id;
  end if;

  if exists (select from pg_tables where schemaname = 'public' and tablename = 'app_security_settings') then
    update public.app_security_settings set updated_by = null where updated_by = target_user_id;
  end if;

  if exists (select from pg_tables where schemaname = 'public' and tablename = 'fcm_tokens') then
    delete from public.fcm_tokens where user_id = target_user_id;
  end if;

  if exists (select from pg_tables where schemaname = 'public' and tablename = 'user_fcm_tokens') then
    delete from public.user_fcm_tokens where user_id = target_user_id;
  end if;

  -- 3.9. Bersihkan file/storage objects milik pengguna jika ada
  if exists (select from pg_tables where schemaname = 'storage' and tablename = 'objects') then
    begin
      execute 'delete from storage.objects where owner::text = $1' using target_user_id::text;
    exception when others then
      null;
    end;
  end if;

  -- 3.10. Hapus baris profil dari public.profiles
  -- Menghapus baris profil ini akan langsung membebaskan username (karena kolom username unique)
  delete from public.profiles
  where id = target_user_id;

  -- 3.11. Hapus akun autentikasi dari auth.users
  -- Sehingga email / akun Supabase auth terhapus total
  begin
    delete from auth.users
    where id = target_user_id;
  exception when others then
    raise notice 'Catatan: Supabase auth.users internal delete notice: %', sqlerrm;
  end;

  -- 3.12. Catat ke audit log admin jika tabel log tersedia
  if exists (select from pg_tables where schemaname = 'public' and tablename = 'admin_activity_logs') then
    insert into public.admin_activity_logs (admin_id, admin_email, action, target_info, metadata)
    values (
      auth.uid(),
      v_admin_email,
      'DELETE_USER_PERMANENT',
      coalesce(v_username, target_user_id::text),
      jsonb_build_object(
        'target_user_id', target_user_id,
        'username', v_username,
        'nis', v_nis
      )
    );
  end if;
end;
$$;

-- 4. Berikan izin eksekusi kepada authenticated dan service_role
grant execute on function public.admin_delete_user(uuid) to authenticated;
grant execute on function public.admin_delete_user(uuid) to service_role;
