-- ========================================================
-- 💬 DIRECT MESSAGES & REALTIME HARDENING MIGRATION
-- Fixes:
-- 1. RLS policy to allow recipient to update `is_read = true`
-- 2. DB trigger to auto-update conversation last_message & timestamp atomically
-- 3. Replica identity full + publication to guarantee Supabase Realtime delivery
-- 4. Optimized indexes for rapid conversation list & unread query
-- ========================================================

-- 1. Ensure Tables Exist
create table if not exists public.conversations (
  id uuid default gen_random_uuid() primary key,
  participant_one uuid not null references public.profiles(id) on delete cascade,
  participant_two uuid not null references public.profiles(id) on delete cascade,
  product_id uuid references public.market_posts(id) on delete set null,
  last_message text default '',
  last_message_at timestamp with time zone default timezone('utc'::text, now()) not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  constraint check_not_self_chat check (participant_one != participant_two)
);

create table if not exists public.direct_messages (
  id uuid default gen_random_uuid() primary key,
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  message_text text not null,
  is_read boolean not null default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. RLS Security Hardening
alter table public.conversations enable row level security;
alter table public.direct_messages enable row level security;

-- Conversations RLS Policies
drop policy if exists "Users can view own conversations" on public.conversations;
drop policy if exists "Users can create conversations" on public.conversations;
drop policy if exists "Users can update own conversations" on public.conversations;

create policy "Users can view own conversations"
  on public.conversations for select to authenticated
  using ((select auth.uid()) in (participant_one, participant_two));

create policy "Users can create conversations"
  on public.conversations for insert to authenticated
  with check ((select auth.uid()) in (participant_one, participant_two));

create policy "Users can update own conversations"
  on public.conversations for update to authenticated
  using ((select auth.uid()) in (participant_one, participant_two))
  with check ((select auth.uid()) in (participant_one, participant_two));

-- Direct Messages RLS Policies
drop policy if exists "Users can view conversation messages" on public.direct_messages;
drop policy if exists "Users can send messages" on public.direct_messages;
drop policy if exists "Users can update own messages" on public.direct_messages;
drop policy if exists "Participants can update messages" on public.direct_messages;
drop policy if exists "Users can delete own messages" on public.direct_messages;

create policy "Users can view conversation messages"
  on public.direct_messages for select to authenticated
  using (
    exists (
      select 1 from public.conversations c
      where c.id = direct_messages.conversation_id
        and (select auth.uid()) in (c.participant_one, c.participant_two)
    )
  );

create policy "Users can send messages"
  on public.direct_messages for insert to authenticated
  with check (
    (select auth.uid()) = sender_id
    and exists (
      select 1 from public.conversations c
      where c.id = direct_messages.conversation_id
        and (select auth.uid()) in (c.participant_one, c.participant_two)
    )
  );

-- Recipients can mark messages as read, senders can update text
create policy "Participants can update messages"
  on public.direct_messages for update to authenticated
  using (
    exists (
      select 1 from public.conversations c
      where c.id = direct_messages.conversation_id
        and (select auth.uid()) in (c.participant_one, c.participant_two)
    )
  )
  with check (
    exists (
      select 1 from public.conversations c
      where c.id = direct_messages.conversation_id
        and (select auth.uid()) in (c.participant_one, c.participant_two)
    )
  );

create policy "Users can delete own messages"
  on public.direct_messages for delete to authenticated
  using ((select auth.uid()) = sender_id);

-- 3. Automatic Trigger to keep conversation snapshot up to date
create or replace function public.handle_direct_message_created()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.conversations
  set
    last_message = left(new.message_text, 100),
    last_message_at = new.created_at
  where id = new.conversation_id;
  return new;
end;
$$;

drop trigger if exists on_direct_message_created on public.direct_messages;
create trigger on_direct_message_created
  after insert on public.direct_messages
  for each row
  execute function public.handle_direct_message_created();

-- 4. Publication & Full Replica Identity for Realtime
alter table public.conversations replica identity full;
alter table public.direct_messages replica identity full;

do $$ begin
  alter publication supabase_realtime add table public.conversations;
exception when duplicate_object or others then null;
end $$;

do $$ begin
  alter publication supabase_realtime add table public.direct_messages;
exception when duplicate_object or others then null;
end $$;

-- 5. High Performance Composite Indexes
create index if not exists idx_conversations_participants on public.conversations(participant_one, participant_two);
create index if not exists idx_conversations_last_message_at on public.conversations(last_message_at desc);
create index if not exists idx_direct_messages_conv_created on public.direct_messages(conversation_id, created_at asc);
create index if not exists idx_direct_messages_unread on public.direct_messages(conversation_id, is_read) where is_read = false;
