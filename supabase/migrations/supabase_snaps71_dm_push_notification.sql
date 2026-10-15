-- =========================================================================
-- SNAPS-71: AUTOMATIC DM PUSH NOTIFICATION (SUPABASE -> FCM HTTP v1)
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard/project/lcwsxldnoqjdfqxqcqja/sql
-- =========================================================================

-- 1. Pastikan ekstensi pg_net tersedia untuk asynchronous HTTP dispatch
create extension if not exists pg_net with schema extensions;

-- 2. Fungsi trigger pemicu pengiriman Push Notifikasi via Edge Function
create or replace function public.trigger_dm_push_notification()
returns trigger
security definer
language plpgsql
as $$
declare
  edge_function_url text;
  anon_key text;
  payload jsonb;
begin
  -- Buat payload JSON pesan baru
  payload := jsonb_build_object(
    'record', jsonb_build_object(
      'id', new.id,
      'conversation_id', new.conversation_id,
      'sender_id', new.sender_id,
      'message_text', new.message_text,
      'created_at', new.created_at
    )
  );

  -- URL Edge Function Supabase (send-dm-push)
  -- Menggunakan URL project internal Supabase
  edge_function_url := 'https://lcwsxldnoqjdfqxqcqja.supabase.co/functions/v1/send-dm-push';

  -- Eksekusi panggilan HTTP POST secara async tanpa memblokir transaksi INSERT direct_messages
  perform net.http_post(
    url := edge_function_url,
    headers := jsonb_build_object(
      'Content-Type', 'application/json'
    ),
    body := payload,
    timeout_milliseconds := 3000
  );

  return new;
exception
  when others then
    -- Fail-safe: Jangan batalkan pengiriman pesan jika terjadi kendala pada webhook
    raise warning 'Gagal mentrigger push notifikasi DM: %', sqlerrm;
    return new;
end;
$$;

-- 3. Pasang trigger pada tabel direct_messages (AFTER INSERT)
drop trigger if exists on_dm_inserted_send_push on public.direct_messages;

create trigger on_dm_inserted_send_push
after insert on public.direct_messages
for each row
execute function public.trigger_dm_push_notification();

-- =========================================================================
-- CATATAN SETUP DI SUPABASE DASHBOARD:
-- 1. Deploy Edge Function:
--    supabase functions deploy send-dm-push --no-verify-jwt
-- 2. Set Secret Service Account Google:
--    supabase secrets set FIREBASE_SERVICE_ACCOUNT='{"type":"service_account",...}'
-- =========================================================================
