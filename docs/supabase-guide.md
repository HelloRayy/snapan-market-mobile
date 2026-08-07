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
  );
  return new;
end;
$$ language plpgsql security definer;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();


-- ========================================================
-- 2. TABEL MARKET POSTS (Postingan Jualan Feed)
-- ========================================================
create table if not exists public.market_posts (
  id uuid default gen_random_uuid() primary key,
  seller_id uuid references public.profiles(id) on delete cascade not null,
  caption text not null,
  images text[] default '{}',
  is_video boolean default false,
  stock integer default 1 check (stock >= 0),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);


-- ========================================================
-- 3. TABEL POST LIKES (Suka Postingan)
-- ========================================================
create table if not exists public.post_likes (
  post_id uuid references public.market_posts(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (post_id, user_id)
);


-- ========================================================
-- 4. TABEL POST COMMENTS (Komentar Postingan)
-- ========================================================
create table if not exists public.post_comments (
  id uuid default gen_random_uuid() primary key,
  post_id uuid references public.market_posts(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  content text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);


-- ========================================================
-- 5. TABEL CART ITEMS (Keranjang Belanja User)
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
-- 🛡️ ROW LEVEL SECURITY (RLS) POLICIES
-- ========================================================
alter table public.profiles enable row level security;
alter table public.market_posts enable row level security;
alter table public.post_likes enable row level security;
alter table public.post_comments enable row level security;
alter table public.cart_items enable row level security;

-- Profiles: Siapa saja bisa baca, user hanya bisa edit profile sendiri
create policy "Profiles viewable by everyone" on public.profiles for select using (true);
create policy "Users can update own profile" on public.profiles for update using (auth.uid() = id);

-- Market Posts: Siapa saja bisa baca, seller terautentikasi bisa posting/edit
create policy "Market posts viewable by everyone" on public.market_posts for select using (true);
create policy "Sellers can insert own posts" on public.market_posts for insert with check (auth.uid() = seller_id);
create policy "Sellers can update own posts" on public.market_posts for update using (auth.uid() = seller_id);

-- Post Likes: Publik bisa lihat, user terautentikasi bisa toggle like
create policy "Likes viewable by everyone" on public.post_likes for select using (true);
create policy "Users can like posts" on public.post_likes for insert with check (auth.uid() = user_id);
create policy "Users can unlike posts" on public.post_likes for delete using (auth.uid() = user_id);

-- Post Comments: Publik bisa lihat, user terautentikasi bisa memberi komentar
create policy "Comments viewable by everyone" on public.post_comments for select using (true);
create policy "Users can insert comments" on public.post_comments for insert with check (auth.uid() = user_id);

-- Cart Items: User hanya bisa kelola keranjang miliknya sendiri
create policy "Users view own cart" on public.cart_items for select using (auth.uid() = user_id);
create policy "Users add to own cart" on public.cart_items for insert with check (auth.uid() = user_id);
create policy "Users modify own cart" on public.cart_items for update using (auth.uid() = user_id);
create policy "Users remove from own cart" on public.cart_items for delete using (auth.uid() = user_id);
```
