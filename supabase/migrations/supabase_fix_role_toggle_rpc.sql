-- Migration to fix role changing between admin and siswa/user
-- Sets security definer, explicit search_path, and input validation

create or replace function public.admin_update_profile_role(target_user_id uuid, new_role text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_normalized_role text;
begin
  if not public.is_admin() then
    raise exception 'Unauthorized: Hanya admin yang dapat mengubah role akun.';
  end if;

  v_normalized_role := lower(trim(new_role));
  if v_normalized_role not in ('user', 'admin', 'buyer', 'seller') then
    raise exception 'Invalid role: %', new_role;
  end if;

  update public.profiles
  set role = v_normalized_role,
      updated_at = now()
  where id = target_user_id;
end;
$$;

grant execute on function public.admin_update_profile_role(uuid, text) to authenticated;
