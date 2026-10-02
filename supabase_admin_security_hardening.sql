-- ========================================================
-- 🛡️ SNAPS-18: SUPABASE ADMIN SECURITY HARDENING MIGRATION
-- ========================================================
-- Salin dan jalankan seluruh SQL ini di Supabase SQL Editor:
-- Supabase Dashboard -> SQL Editor -> New Query -> Run

-- 1. Tambah Kolom Sesi Tunggal (Single Active Device) di Profiles
alter table public.profiles
add column if not exists current_admin_session_token text;

-- 2. Trigger Database: Cegah Eskalasi Hak Akses Mandiri (Anti-Privilege Escalation)
-- Mengunci kolom 'role' dan 'is_verified' agar tidak bisa diubah oleh siswa biasa via Client API.
create or replace function public.fn_protect_profile_sensitive_fields()
returns trigger as $$
begin
  -- Jika role atau is_verified diubah
  if (old.role is distinct from new.role) or (old.is_verified is distinct from new.is_verified) then
    -- Periksa apakah user yang sedang menjalankan request adalah admin terdaftar
    if not public.is_admin() then
      raise exception 'Akses Ditolak: Hanya administrator resmi yang dapat mengubah role dan status verifikasi akun.';
    end if;
  end if;

  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists trg_protect_profile_sensitive_fields on public.profiles;
create trigger trg_protect_profile_sensitive_fields
  before update on public.profiles
  for each row
  execute function public.fn_protect_profile_sensitive_fields();


-- 3. Tabel Log Aktivitas Administratif (Immutable Activity Log)
create table if not exists public.admin_activity_logs (
  id uuid primary key default gen_random_uuid(),
  admin_id uuid references public.profiles(id) on delete set null,
  admin_email text not null,
  action text not null, -- LOGIN, TAKEDOWN_POST, CHANGE_ROLE, VERIFY_USER, SPOT_MUTATION, etc.
  target_info text,
  metadata jsonb default '{}'::jsonb,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Index untuk pencarian log cepat
create index if not exists idx_admin_activity_logs_created_at
on public.admin_activity_logs (created_at desc);

-- 4. Kebijakan RLS Tabel Log Aktivitas (Hanya Admin yang dapat membaca & menambah)
alter table public.admin_activity_logs enable row level security;

drop policy if exists "Admins can view activity logs" on public.admin_activity_logs;
create policy "Admins can view activity logs"
on public.admin_activity_logs
for select
to authenticated
using (public.is_admin());

drop policy if exists "Admins can insert activity logs" on public.admin_activity_logs;
create policy "Admins can insert activity logs"
on public.admin_activity_logs
for insert
to authenticated
with check (public.is_admin());

-- Dilarang membuat policy UPDATE atau DELETE pada admin_activity_logs (Immutable Audit Trail)
