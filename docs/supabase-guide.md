# Supabase Setup & Marketplace Database Schema Guide (Laptop B)

Panduan integrasi Supabase, konfigurasi **Google OAuth Authentication**, SQL Schema, dan RLS Security Policies untuk **Snapan Market Mobile**.

---

## 🔑 1. Setup Environment Variables

Buat file `.env` di root project (salin dari `.env.example`):

```env
VITE_SUPABASE_URL=https://lcwsxldnoqjdfqxqcqja.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

---

## 🔐 2. Konfigurasi Google OAuth & Storage Bucket

1. **Google OAuth**:
   - Buka [Supabase Dashboard](https://supabase.com/dashboard) -> Authentication -> Providers -> Google.
   - Aktifkan Google Provider dan isi Client ID & Client Secret dari Google Cloud Console.

2. **Supabase Storage Bucket (`market-media`)**:
   - Buka menu **Storage** di Supabase Dashboard.
   - Buat New Bucket bernama `market-media`.
   - Set status bucket menjadi **Public**.

---

## 🗄️ 3. SQL Migration Script (Supabase SQL Editor)

Jalankan script berikut di **Supabase Dashboard -> SQL Editor**:

```sql
-- ========================================================
-- 1. TABEL PROFILES (Ekstensi dari Auth Users)
-- ========================================================
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  full_name text not null,
  username text unique,
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
  insert into public.profiles (id, full_name, username, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name', 'Pengguna Baru'),
    coalesce(new.raw_user_meta_data->>'username', lower(replace(coalesce(new.raw_user_meta_data->>'full_name', 'user'), ' ', ''))),
    coalesce(new.raw_user_meta_data->>'avatar_url', new.raw_user_meta_data->>'picture', '')
  );
  return new;
end;
$$ language plpgsql security definer;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();


-- ========================================================
-- 2. TABEL MARKET POSTS (Utas Sosial & Produk Jualan)
-- ========================================================
create table if not exists public.market_posts (
  id uuid default gen_random_uuid() primary key,
  seller_id uuid references public.profiles(id) on delete cascade not null,
  post_type text default 'thread' check (post_type in ('thread', 'product')),
  title text,
  caption text not null,
  description text,
  price numeric default 0 check (price >= 0),
  original_price numeric default 0 check (original_price >= 0),
  category text default 'Lainnya',
  images text[] default '{}',
  stock integer default 1 check (stock >= 0),
  location_tag text,
  topic_tag text,
  is_official_topic boolean default false,
  topic_icon text default 'threads',
  likes_count integer default 0 check (likes_count >= 0),
  comments_count integer default 0 check (comments_count >= 0),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);


-- ========================================================
-- 3. TABEL POST LIKES (Suka Postingan Utama)
-- ========================================================
create table if not exists public.post_likes (
  post_id uuid references public.market_posts(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (post_id, user_id)
);


-- ========================================================
-- 4. TABEL POST COMMENTS & SUB-THREADS (Komentar Bersarang P2, P3, P4)
-- ========================================================
create table if not exists public.post_comments (
  id uuid default gen_random_uuid() primary key,
  post_id uuid references public.market_posts(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  parent_comment_id uuid references public.post_comments(id) on delete cascade,
  content text not null,
  images text[] default '{}',
  thread_part integer default 1,
  total_parts integer default 1,
  likes_count integer default 0 check (likes_count >= 0),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);


-- ========================================================
-- 5. TABEL COMMENT LIKES (Suka Komentar & Balasan)
-- ========================================================
create table if not exists public.comment_likes (
  comment_id uuid references public.post_comments(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (comment_id, user_id)
);


-- ========================================================
-- ========================================================
-- 6. TABEL CART ITEMS (Keranjang Belanja)
-- ========================================================
create table if not exists public.cart_items (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  post_id uuid references public.market_posts(id) on delete cascade not null,
  quantity integer default 1 check (quantity > 0),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique (user_id, post_id)
);


-- ========================================================
-- 7. TABEL POST BOOKMARKS (Simpan / Markah Postingan)
-- ========================================================
create table if not exists public.post_bookmarks (
  post_id uuid references public.market_posts(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (post_id, user_id)
);


-- ========================================================
-- 8. TABEL NOTIFICATIONS (Notifikasi Sistem & Interaksi Sosial)
-- ========================================================
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
-- 9. ROW LEVEL SECURITY (RLS) POLICIES
-- ========================================================
alter table public.profiles enable row level security;
alter table public.market_posts enable row level security;
alter table public.post_likes enable row level security;
alter table public.post_comments enable row level security;
alter table public.comment_likes enable row level security;
alter table public.cart_items enable row level security;
alter table public.post_bookmarks enable row level security;
alter table public.notifications enable row level security;

-- Profiles
create policy "Public profiles are viewable by everyone" on public.profiles for select using (true);
create policy "Users can update own profile" on public.profiles for update using (auth.uid() = id);

-- Market Posts
create policy "Market posts viewable by everyone" on public.market_posts for select using (true);
create policy "Users can insert posts" on public.market_posts for insert with check (auth.uid() = seller_id);
create policy "Users can update own posts" on public.market_posts for update using (auth.uid() = seller_id);
create policy "Users can delete own posts" on public.market_posts for delete using (auth.uid() = seller_id);

-- Post Likes
create policy "Post likes viewable by everyone" on public.post_likes for select using (true);
create policy "Users can toggle own post like" on public.post_likes for all using (auth.uid() = user_id);

-- Post Comments
create policy "Comments viewable by everyone" on public.post_comments;
create policy "Users can insert comments" on public.post_comments for insert with check (auth.uid() = user_id);
create policy "Users can delete own comments" on public.post_comments for delete using (auth.uid() = user_id);

-- Comment Likes
create policy "Comment likes viewable by everyone" on public.comment_likes for select using (true);
create policy "Users can toggle own comment like" on public.comment_likes for all using (auth.uid() = user_id);

-- Cart Items
create policy "Users can view own cart items" on public.cart_items for select using (auth.uid() = user_id);
create policy "Users can insert own cart items" on public.cart_items for insert with check (auth.uid() = user_id);
create policy "Users can update own cart items" on public.cart_items for update using (auth.uid() = user_id);
create policy "Users can delete own cart items" on public.cart_items for delete using (auth.uid() = user_id);

-- Post Bookmarks
create policy "Users view own bookmarks" on public.post_bookmarks for select using (auth.uid() = user_id);
create policy "Users add own bookmark" on public.post_bookmarks for insert with check (auth.uid() = user_id);
create policy "Users delete own bookmark" on public.post_bookmarks for delete using (auth.uid() = user_id);

-- Notifications
create policy "Users view own notifications" on public.notifications for select using (auth.uid() = user_id);
create policy "Users update own notifications" on public.notifications for update using (auth.uid() = user_id);
create policy "Users delete own notifications" on public.notifications for delete using (auth.uid() = user_id);
create policy "Authenticated users create notification" on public.notifications for insert with check (auth.role() = 'authenticated');


-- ========================================================
-- 10. INDEXING PERFORMA PENCARIAN & FILTERING
-- ========================================================
create index if not exists idx_market_posts_category on public.market_posts(category);
create index if not exists idx_market_posts_post_type on public.market_posts(post_type);
create index if not exists idx_market_posts_price on public.market_posts(price);
create index if not exists idx_market_posts_created_at on public.market_posts(created_at desc);
```
