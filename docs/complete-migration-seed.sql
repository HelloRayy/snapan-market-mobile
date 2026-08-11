-- ========================================================
-- 🗄️ SNAPAN MARKET MOBILE — COMPLETE DATABASE MIGRATION & SEED DATA
-- Jalankan file SQL ini di Supabase Dashboard -> SQL Editor
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


-- ========================================================
-- 🛡️ ROW LEVEL SECURITY (RLS) POLICIES
-- ========================================================
alter table public.profiles enable row level security;
alter table public.market_posts enable row level security;
alter table public.post_likes enable row level security;
alter table public.post_comments enable row level security;
alter table public.cart_items enable row level security;

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


-- ========================================================
-- 🌱 SEED DUMMY DATA (UNTUK INTEGRASI & TESTING)
-- ========================================================

-- Insert Dummy Profiles
insert into public.profiles (id, full_name, avatar_url, class_group, is_verified, role)
values
  ('11111111-1111-1111-1111-111111111111', 'Raymond Chin', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80', 'XII PPLG 1', true, 'seller'),
  ('22222222-2222-2222-2222-222222222222', 'Faiz Intifada', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80', 'XII DKV 2', true, 'seller'),
  ('33333333-3333-3333-3333-333333333333', 'Ibu Kantin Sayang', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80', 'Kantin SMKN 8', true, 'seller')
on conflict (id) do nothing;

-- Insert Dummy Posts
insert into public.market_posts (id, seller_id, caption, images, stock, price, original_price, category, location_tag)
values
  (
    'a1111111-1111-1111-1111-111111111111',
    '11111111-1111-1111-1111-111111111111',
    'Ada kenalan website designer / UI engineer yang bisa bikin landing page & PWA kilat? Comment portofolio & tawaran harganya ya :)',
    array['https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&q=80', 'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?w=800&q=80'],
    5,
    150000,
    200000,
    'Jasa DKV/PPLG',
    'Lab Komputer PPLG'
  ),
  (
    'b2222222-2222-2222-2222-222222222222',
    '22222222-2222-2222-2222-222222222222',
    'Hadir mas! Open commission UI/UX & Design Engineering PWA responsive siap pakai. Portofolio lengkap bisa dicek langsung 🚀✨',
    array['https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&q=80'],
    3,
    250000,
    350000,
    'Jasa DKV/PPLG',
    'Studio DKV Gedung B'
  ),
  (
    'c3333333-3333-3333-3333-333333333333',
    '33333333-3333-3333-3333-333333333333',
    'Tahu Walik Renyah + Sambal Kecap Pedas Mantap Baru Matang! Tinggal 10 porsi lagi di Kantin Tengah. Pesan sekarang bisa diantar ke kelas pas istirahat ke-2! 🥟🔥',
    array['https://images.unsplash.com/photo-1541544741938-0af808871cc0?w=800&q=80'],
    10,
    10000,
    12000,
    'Kantin',
    'Kantin Utama Depan Aula'
  )
on conflict (id) do nothing;
