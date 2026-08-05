# Supabase Setup & Marketplace Database Schema Guide

Panduan integrasi Supabase, konfigurasi **Google OAuth Authentication**, dan SQL Schema dasar untuk marketplace **Snapan Market**.

---

## 🔑 1. Setup Environment Variables

Buat file `.env` di root project (salin dari `.env.example`):

```env
VITE_SUPABASE_URL=https://your-project-ref.supabase.co
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

## 🗄️ 3. SQL Schema dasar untuk Marketplace

Jalankan perintah SQL berikut di **Supabase SQL Editor**:

```sql
-- 1. Tabel Profiles (User)
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  full_name text,
  avatar_url text,
  role text default 'buyer' check (role in ('buyer', 'seller', 'admin')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Tabel Products
create table public.products (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  description text,
  price numeric not null check (price >= 0),
  stock integer default 0 check (stock >= 0),
  seller_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- RLS (Row Level Security) Policies
alter table public.profiles enable row level security;
alter table public.products enable row level security;

-- Policy Membaca Produk (Dapat dibaca oleh siapa saja)
create policy "Products are viewable by everyone" on public.products
  for select using (true);
```
