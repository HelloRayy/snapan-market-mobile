# Supabase Setup & Marketplace Database Schema Guide

Panduan integrasi Supabase, konfigurasi **Google OAuth Authentication**, dan SQL Schema e-commerce lengkap untuk marketplace **Snapan Market**.

---

## 🔑 1. Setup Environment Variables

Buat file `.env` di root project (salin dari `.env.example`):

```env
VITE_SUPABASE_URL=https://lcwsxldnoqjdfqxqcqja.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

---

## 🔐 2. Konfigurasi Google OAuth di Dashboard Supabase

1. Buka [Supabase Dashboard](https://supabase.com/dashboard) -> Masuk ke project Anda.
2. Buka menu **Authentication -> Providers -> Google**.
3. Aktifkan Google Provider (`Enable Google provider`).
4. Masukkan **Client ID** dan **Client Secret** dari [Google Cloud Console](https://console.cloud.google.com/).
5. Salin **Redirect URL** dari Supabase dan daftarkan ke *Authorized redirect URIs* di Google Cloud Console.

---

## 🗄️ 3. SQL Schema Lengkap E-Commerce (Snapan Market)

Jalankan perintah SQL berikut di **Supabase SQL Editor**:

```sql
-- Enable Extension ( UUID Generation )
create extension if not exists "uuid-ossp";

-- 1. Tabel Profiles (User Accounts)
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  full_name text,
  avatar_url text,
  phone text,
  address text,
  role text default 'buyer' check (role in ('buyer', 'seller', 'admin')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Tabel Categories (Kategori Produk)
create table public.categories (
  id uuid default gen_random_uuid() primary key,
  name text not null unique,
  slug text not null unique,
  icon text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Tabel Products (Katalog Produk)
create table public.products (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  slug text,
  description text,
  price numeric not null check (price >= 0),
  stock integer default 0 check (stock >= 0),
  category_id uuid references public.categories(id) on delete set null,
  seller_id uuid references public.profiles(id) on delete cascade not null,
  image_url text,
  rating numeric default 0 check (rating >= 0 and rating <= 5),
  sold_count integer default 0 check (sold_count >= 0),
  is_active boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 4. Tabel Orders (Transaksi Pembelian)
create table public.orders (
  id uuid default gen_random_uuid() primary key,
  buyer_id uuid references public.profiles(id) on delete cascade not null,
  total_amount numeric not null check (total_amount >= 0),
  status text default 'pending' check (status in ('pending', 'paid', 'processing', 'shipped', 'completed', 'cancelled')),
  shipping_address text not null,
  notes text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 5. Tabel Order Items (Detail Barang per Pesanan)
create table public.order_items (
  id uuid default gen_random_uuid() primary key,
  order_id uuid references public.orders(id) on delete cascade not null,
  product_id uuid references public.products(id) on delete restrict not null,
  quantity integer not null check (quantity > 0),
  unit_price numeric not null check (unit_price >= 0),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 6. Tabel Reviews (Ulasan & Rating Produk)
create table public.reviews (
  id uuid default gen_random_uuid() primary key,
  product_id uuid references public.products(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  rating integer not null check (rating >= 1 and rating <= 5),
  comment text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  constraint unique_user_product_review unique (product_id, user_id)
);

-- ========================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ========================================================

alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.reviews enable row level security;

-- PROFILES Policies
create policy "Public profiles are viewable by everyone"
  on public.profiles for select using (true);

create policy "Users can update their own profile"
  on public.profiles for update using (auth.uid() = id);

-- CATEGORIES Policies
create policy "Categories are viewable by everyone"
  on public.categories for select using (true);

-- PRODUCTS Policies
create policy "Active products are viewable by everyone"
  on public.products for select using (is_active = true or auth.uid() = seller_id);

create policy "Sellers can insert their own products"
  on public.products for insert with check (auth.uid() = seller_id);

create policy "Sellers can update their own products"
  on public.products for update using (auth.uid() = seller_id);

create policy "Sellers can delete their own products"
  on public.products for delete using (auth.uid() = seller_id);

-- ORDERS Policies
create policy "Users can view their own orders"
  on public.orders for select using (auth.uid() = buyer_id);

create policy "Users can create their own orders"
  on public.orders for insert with check (auth.uid() = buyer_id);

create policy "Users can update their own orders"
  on public.orders for update using (auth.uid() = buyer_id);

-- ORDER ITEMS Policies
create policy "Users can view items of their own orders"
  on public.order_items for select using (
    exists (
      select 1 from public.orders
      where orders.id = order_items.order_id and orders.buyer_id = auth.uid()
    )
  );

create policy "Users can insert order items into their own orders"
  on public.order_items for insert with check (
    exists (
      select 1 from public.orders
      where orders.id = order_items.order_id and orders.buyer_id = auth.uid()
    )
  );

-- REVIEWS Policies
create policy "Reviews are viewable by everyone"
  on public.reviews for select using (true);

create policy "Users can create reviews"
  on public.reviews for insert with check (auth.uid() = user_id);

create policy "Users can update their own reviews"
  on public.reviews for update using (auth.uid() = user_id);

-- Trigger untuk membuat Profile otomatis saat Sign Up
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name', 'User'),
    coalesce(new.raw_user_meta_data->>'avatar_url', new.raw_user_meta_data->>'picture', '')
  );
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
```
