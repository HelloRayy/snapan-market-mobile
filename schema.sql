-- ========================================================
-- 🗄️ SNAPAN MARKET MOBILE — DATABASE MIGRATION SCRIPT
-- Copy & Paste isi file ini ke Supabase Dashboard -> SQL Editor
-- ========================================================

-- 1. TABEL PROFILES (Ekstensi auth.users)
create table if not exists public.profiles (
  id uuid primary key,
  full_name text not null,
  avatar_url text,
  class_group text default 'Siswa Snapan',
  is_verified boolean default false,
  role text default 'buyer' check (role in ('buyer', 'seller', 'admin')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Trigger Otomatis saat User Sign Up (Google OAuth / Email)
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name', 'Pengguna Baru'),
    coalesce(new.raw_user_meta_data->>'avatar_url', new.raw_user_meta_data->>'picture', '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();


-- 2. TABEL MARKET POSTS (Postingan Feed Jualan)
create table if not exists public.market_posts (
  id uuid default gen_random_uuid() primary key,
  seller_id uuid references public.profiles(id) on delete cascade not null,
  caption text not null,
  images text[] default '{}',
  is_video boolean default false,
  stock integer default 1 check (stock >= 0),
  price numeric default 0,
  original_price numeric,
  category text default 'Umum',
  location_tag text default 'SMKN 8',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);


-- 3. TABEL POST LIKES (Suka Postingan)
create table if not exists public.post_likes (
  post_id uuid references public.market_posts(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (post_id, user_id)
);


-- 4. TABEL POST COMMENTS (Komentar Postingan Threads)
create table if not exists public.post_comments (
  id uuid default gen_random_uuid() primary key,
  post_id uuid references public.market_posts(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  parent_id uuid references public.post_comments(id) on delete cascade,
  content text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);


-- 5. TABEL CART ITEMS (Keranjang Belanja User)
create table if not exists public.cart_items (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  post_id uuid references public.market_posts(id) on delete cascade not null,
  quantity integer default 1 check (quantity > 0),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique (user_id, post_id)
);


-- 6. TABEL POST BOOKMARKS (Simpan / Markah Postingan)
create table if not exists public.post_bookmarks (
  post_id uuid references public.market_posts(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (post_id, user_id)
);


-- 7. TABEL NOTIFICATIONS (Notifikasi Sistem & Interaksi Sosial)
create table if not exists public.notifications (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  actor_id uuid references public.profiles(id) on delete cascade,
  type text not null check (type in ('like', 'comment', 'reply', 'order', 'system')),
  title text not null,
  message text not null,
  post_id uuid references public.market_posts(id) on delete cascade,
  is_read boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);


-- ========================================================
-- 🛡️ ROW LEVEL SECURITY (RLS) POLICIES
-- ========================================================
alter table public.profiles enable row level security;
alter table public.market_posts enable row level security;
alter table public.post_likes enable row level security;
alter table public.post_comments enable row level security;
alter table public.cart_items enable row level security;
alter table public.post_bookmarks enable row level security;
alter table public.notifications enable row level security;

-- Profiles Policies
drop policy if exists "Profiles viewable by everyone" on public.profiles;
drop policy if exists "Users can update own profile" on public.profiles;
create policy "Profiles viewable by everyone" on public.profiles for select using (true);
create policy "Users can update own profile" on public.profiles for update using (auth.uid() = id);

-- Market Posts Policies
drop policy if exists "Market posts viewable by everyone" on public.market_posts;
drop policy if exists "Sellers can insert own posts" on public.market_posts;
drop policy if exists "Sellers can update own posts" on public.market_posts;
create policy "Market posts viewable by everyone" on public.market_posts for select using (true);
create policy "Sellers can insert own posts" on public.market_posts for insert with check (auth.uid() = seller_id);
create policy "Sellers can update own posts" on public.market_posts for update using (auth.uid() = seller_id);

-- Post Likes Policies
drop policy if exists "Likes viewable by everyone" on public.post_likes;
drop policy if exists "Users can like posts" on public.post_likes;
drop policy if exists "Users can unlike posts" on public.post_likes;
create policy "Likes viewable by everyone" on public.post_likes for select using (true);
create policy "Users can like posts" on public.post_likes for insert with check (auth.uid() = user_id);
create policy "Users can unlike posts" on public.post_likes for delete using (auth.uid() = user_id);

-- Post Comments Policies
drop policy if exists "Comments viewable by everyone" on public.post_comments;
drop policy if exists "Users can insert comments" on public.post_comments;
create policy "Comments viewable by everyone" on public.post_comments for select using (true);
create policy "Users can insert comments" on public.post_comments for insert with check (auth.uid() = user_id);

-- Cart Items Policies
drop policy if exists "Users view own cart" on public.cart_items;
drop policy if exists "Users add to own cart" on public.cart_items;
drop policy if exists "Users modify own cart" on public.cart_items;
drop policy if exists "Users remove from own cart" on public.cart_items;
create policy "Users view own cart" on public.cart_items for select using (auth.uid() = user_id);
create policy "Users add to own cart" on public.cart_items for insert with check (auth.uid() = user_id);
create policy "Users modify own cart" on public.cart_items for update using (auth.uid() = user_id);
create policy "Users remove from own cart" on public.cart_items for delete using (auth.uid() = user_id);

-- Post Bookmarks Policies
drop policy if exists "Users view own bookmarks" on public.post_bookmarks;
drop policy if exists "Users toggle own bookmarks" on public.post_bookmarks;
create policy "Users view own bookmarks" on public.post_bookmarks for select using (auth.uid() = user_id);
create policy "Users add own bookmark" on public.post_bookmarks for insert with check (auth.uid() = user_id);
create policy "Users remove own bookmark" on public.post_bookmarks for delete using (auth.uid() = user_id);

-- Notifications Policies
drop policy if exists "Users view own notifications" on public.notifications;
drop policy if exists "Users update own notifications" on public.notifications;
drop policy if exists "Users delete own notifications" on public.notifications;
drop policy if exists "Authenticated users can create notification" on public.notifications;
create policy "Users view own notifications" on public.notifications for select using (auth.uid() = user_id);
create policy "Users update own notifications" on public.notifications for update using (auth.uid() = user_id);
create policy "Users delete own notifications" on public.notifications for delete using (auth.uid() = user_id);
create policy "Authenticated users can create notification" on public.notifications for insert with check (auth.role() = 'authenticated');


-- ========================================================
-- ⚡ INDEXING UNTUK PERFORMA PENCARIAN & FILTERING
-- ========================================================
create index if not exists idx_market_posts_category on public.market_posts(category);
create index if not exists idx_market_posts_post_type on public.market_posts(post_type);
create index if not exists idx_market_posts_price on public.market_posts(price);
create index if not exists idx_market_posts_created_at on public.market_posts(created_at desc);


