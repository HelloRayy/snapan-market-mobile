-- ========================================================
-- 🛡️ SUPABASE ADMIN RLS & VERIFICATION POLICIES
-- ========================================================
-- Salin dan jalankan seluruh SQL ini di:
-- Supabase Dashboard -> SQL Editor -> New Query -> Run

-- 1. Helper function cek role admin (Security Definer untuk cegah infinite recursion)
create or replace function public.is_admin()
returns boolean
language sql
security definer
stable
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- 2. Kebijakan RLS agar Admin dapat UPDATE profil siapa saja (verifikasi & role)
drop policy if exists "Admins can update any profile" on public.profiles;
create policy "Admins can update any profile"
on public.profiles
for update
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- 3. Kebijakan RLS agar Admin dapat DELETE postingan feed untuk moderasi
drop policy if exists "Admins can delete any post" on public.market_posts;
create policy "Admins can delete any post"
on public.market_posts
for delete
to authenticated
using (public.is_admin());

-- 4. RPC Function Verifikasi Siswa (Security Definer)
create or replace function public.admin_toggle_verification(target_user_id uuid, new_status boolean)
returns void
language plpgsql
security definer
as $$
begin
  if not public.is_admin() then
    raise exception 'Unauthorized: Hanya admin yang dapat memverifikasi profil siswa.';
  end if;
  update public.profiles set is_verified = new_status where id = target_user_id;
end;
$$;

-- 5. RPC Function Ubah Role (Security Definer)
create or replace function public.admin_update_profile_role(target_user_id uuid, new_role text)
returns void
language plpgsql
security definer
as $$
begin
  if not public.is_admin() then
    raise exception 'Unauthorized: Hanya admin yang dapat mengubah role akun.';
  end if;
  update public.profiles set role = new_role where id = target_user_id;
end;
$$;

-- 6. RPC Function Takedown Post (Security Definer)
create or replace function public.admin_delete_post(target_post_id uuid)
returns void
language plpgsql
security definer
as $$
begin
  if not public.is_admin() then
    raise exception 'Unauthorized: Hanya admin yang dapat menghapus postingan feed.';
  end if;
  delete from public.market_posts where id = target_post_id;
end;
$$;

-- 7. LANGSUNG VERIFIKASI AKUN-AKUN YANG SEBELUMNYA GAGAL TERSIMPAN:
update public.profiles
set is_verified = true
where username in ('testuser', 'snaps', 'snaps9857')
   or full_name in ('Snaps Developer Team', 'Test User Updated', 'rap');
