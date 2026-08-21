# 🗄️ LAPTOP B — BACKEND IMPLEMENTATION WORK SHEET & SOP

Dokumen ini adalah **panduan kerja resmi untuk Laptop B (Backend Workstation)** agar dapat mengimplementasikan Supabase Database, SQL Migrations, RLS Security, Types TypeScript, dan API Services **100% independen tanpa mengganggu atau mengubah kode UI frontend yang sudah selesai di Laptop A**.

---

## 📋 DAFTAR TUGAS LAPTOP B (CHECKLIST)

| No | Modul Backend | File Output | Status |
| :--- | :--- | :--- | :--- |
| **Task 1** | **Database Schema & SQL Migrations** | Jalankan SQL di Supabase SQL Editor | ⬜ Pending |
| **Task 2** | **Row Level Security (RLS) & Triggers** | Jalankan RLS Policy di Supabase | ⬜ Pending |
| **Task 3** | **TypeScript Database Contracts** | `src/types/supabase.ts` | ⬜ Pending |
| **Task 4** | **API Services Implementation** | `src/services/api/` | ⬜ Pending |
| **Task 5** | **Build & Type Check Validation** | `npx tsc --noEmit && npm run build` | ⬜ Pending |

---

## 🗄️ TASK 1 & 2: SQL SCHEMA & RLS SCRIPT (Jalankan di Supabase SQL Editor)

Salin seluruh script SQL di bawah ini dan jalankan langsung di **Supabase Dashboard -> SQL Editor**:

```sql
-- ========================================================
-- 1. TABEL PROFILES (Ekstensi User Auth)
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

-- Trigger Otomatis saat Registrasi Baru
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
-- 2. TABEL MARKET POSTS (Utas Sosial & Produk Marketplace)
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
-- 3. TABEL POST LIKES (Sistem Suka Postingan)
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
  parent_comment_id uuid references public.post_comments(id) on delete cascade, -- NULL = Root Comment, UUID = Sub-Reply
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
-- 7. ROW LEVEL SECURITY (RLS) POLICIES
-- ========================================================
alter table public.profiles enable row level security;
alter table public.market_posts enable row level security;
alter table public.post_likes enable row level security;
alter table public.post_comments enable row level security;
alter table public.comment_likes enable row level security;
alter table public.cart_items enable row level security;

-- Profiles: Siapa saja bisa baca profil, hanya pemilik yang bisa edit profilnya
create policy "Public profiles are viewable by everyone" on public.profiles for select using (true);
create policy "Users can update own profile" on public.profiles for update using (auth.uid() = id);

-- Market Posts: Publik bisa membaca, hanya user login yang bisa membuat, dan hanya pembuat yang bisa edit/delete
create policy "Market posts viewable by everyone" on public.market_posts for select using (true);
create policy "Users can insert posts" on public.market_posts for insert with check (auth.uid() = seller_id);
create policy "Users can update own posts" on public.market_posts for update using (auth.uid() = seller_id);
create policy "Users can delete own posts" on public.market_posts for delete using (auth.uid() = seller_id);

-- Post Likes: Publik bisa melihat, user login bisa toggle like miliknya
create policy "Post likes viewable by everyone" on public.post_likes for select using (true);
create policy "Users can toggle own post like" on public.post_likes for all using (auth.uid() = user_id);

-- Post Comments: Publik bisa membaca komentar, user login bisa komentar & hapus komentar miliknya
create policy "Comments viewable by everyone" on public.post_comments for select using (true);
create policy "Users can insert comments" on public.post_comments for insert with check (auth.uid() = user_id);
create policy "Users can delete own comments" on public.post_comments for delete using (auth.uid() = user_id);

-- Comment Likes: Publik bisa melihat, user login bisa like komentar
create policy "Comment likes viewable by everyone" on public.comment_likes for select using (true);
create policy "Users can toggle own comment like" on public.comment_likes for all using (auth.uid() = user_id);

-- Cart Items: User hanya bisa melihat dan memodifikasi keranjangnya sendiri
create policy "Users can view own cart items" on public.cart_items for select using (auth.uid() = user_id);
create policy "Users can insert own cart items" on public.cart_items for insert with check (auth.uid() = user_id);
create policy "Users can update own cart items" on public.cart_items for update using (auth.uid() = user_id);
create policy "Users can delete own cart items" on public.cart_items for delete using (auth.uid() = user_id);
```

---

## 📦 TASK 3: UPDATE TYPE CONTRACT (`src/types/supabase.ts`)

File: `src/types/supabase.ts`
Pastikan interface tipe data mencerminkan seluruh skema tabel di atas dengan strict:

```typescript
export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string
          full_name: string
          username: string | null
          avatar_url: string | null
          class_group: string
          is_verified: boolean
          role: 'buyer' | 'seller' | 'admin'
          created_at: string
        }
        Insert: {
          id: string
          full_name: string
          username?: string | null
          avatar_url?: string | null
          class_group?: string
          is_verified?: boolean
          role?: 'buyer' | 'seller' | 'admin'
          created_at?: string
        }
        Update: {
          id?: string
          full_name?: string
          username?: string | null
          avatar_url?: string | null
          class_group?: string
          is_verified?: boolean
          role?: 'buyer' | 'seller' | 'admin'
          created_at?: string
        }
      }
      market_posts: {
        Row: {
          id: string
          seller_id: string
          post_type: 'thread' | 'product'
          title: string | null
          caption: string
          description: string | null
          price: number
          original_price: number
          category: string
          images: string[]
          stock: number
          location_tag: string | null
          topic_tag: string | null
          is_official_topic: boolean
          topic_icon: string
          likes_count: number
          comments_count: number
          created_at: string
        }
        Insert: {
          id?: string
          seller_id: string
          post_type?: 'thread' | 'product'
          title?: string | null
          caption: string
          description?: string | null
          price?: number
          original_price?: number
          category?: string
          images?: string[]
          stock?: number
          location_tag?: string | null
          topic_tag?: string | null
          is_official_topic?: boolean
          topic_icon?: string
          likes_count?: number
          comments_count?: number
          created_at?: string
        }
        Update: {
          id?: string
          seller_id?: string
          post_type?: 'thread' | 'product'
          title?: string | null
          caption?: string
          description?: string | null
          price?: number
          original_price?: number
          category?: string
          images?: string[]
          stock?: number
          location_tag?: string | null
          topic_tag?: string | null
          is_official_topic?: boolean
          topic_icon?: string
          likes_count?: number
          comments_count?: number
          created_at?: string
        }
      }
      post_comments: {
        Row: {
          id: string
          post_id: string
          user_id: string
          parent_comment_id: string | null
          content: string
          images: string[]
          thread_part: number
          total_parts: number
          likes_count: number
          created_at: string
        }
        Insert: {
          id?: string
          post_id: string
          user_id: string
          parent_comment_id?: string | null
          content: string
          images?: string[]
          thread_part?: number
          total_parts?: number
          likes_count?: number
          created_at?: string
        }
        Update: {
          id?: string
          post_id?: string
          user_id?: string
          parent_comment_id?: string | null
          content?: string
          images?: string[]
          thread_part?: number
          total_parts?: number
          likes_count?: number
          created_at?: string
        }
      }
      post_likes: {
        Row: {
          post_id: string
          user_id: string
          created_at: string
        }
        Insert: {
          post_id: string
          user_id: string
          created_at?: string
        }
        Update: {
          post_id?: string
          user_id?: string
          created_at?: string
        }
      }
      comment_likes: {
        Row: {
          comment_id: string
          user_id: string
          created_at: string
        }
        Insert: {
          comment_id: string
          user_id: string
          created_at?: string
        }
        Update: {
          comment_id?: string
          user_id?: string
          created_at?: string
        }
      }
      cart_items: {
        Row: {
          id: string
          user_id: string
          post_id: string
          quantity: number
          created_at: string
        }
        Insert: {
          id?: string
          user_id: string
          post_id: string
          quantity?: number
          created_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          post_id?: string
          quantity?: number
          created_at?: string
        }
      }
    }
  }
}
```

---

## 🛠️ TASK 4: API SERVICES IMPLEMENTATION (`src/services/api/`)

Laptop B membuat / memperbarui fungsi data fetching di folder `src/services/api/`:

### 1. `src/services/api/commentService.ts`
- `fetchPostComments(postId: string)`: Mengambil komentar root beserta sub-replies bersarang (join dengan `profiles`).
- `createComment(commentData: InsertComment)`: Menyimpan komentar atau balasan baru.
- `toggleCommentLike(commentId: string, userId: string)`: Toggle like komentar.

### 2. `src/services/api/postService.ts`
- `fetchMarketFeed(limit?: number, page?: number)`: Mengambil daftar postingan feed terbaru dengan profil penjual & status like user aktif.
- `createMarketPost(postData: InsertMarketPost)`: Menyimpan postingan jualan/utas baru.
- `togglePostLike(postId: string, userId: string)`: Toggle like pada postingan utama.

### 3. `src/services/api/cartService.ts`
- `fetchUserCart(userId: string)`: Mengambil daftar item keranjang belanja user beserta detail produk postingan.
- `addToCart(userId: string, postId: string, quantity?: number)`: Menambahkan item ke keranjang.
- `removeFromCart(cartItemId: string)`: Menghapus item dari keranjang.

---

## 🔒 ATURAN KETAT KERJA LAPTOP B (ISOLASI 100%)

1. ❌ **DILARANG mengubah atau menyentuh folder UI**:
   - Jangan mengedit file di `src/ui/` (Pages, Components, Hooks UI).
2. ❌ **DILARANG mengubah layout index.html atau styling CSS**:
   - Jangan mengedit `src/index.css` atau Tailwind config.
3. ✅ **HANYA BEKERJA DI FOLDER**:
   - `docs/` (Dokumentasi SQL & Schema)
   - `src/types/supabase.ts` (Interface Database)
   - `src/services/api/` (API Client & Query Services)
   - `.env.example`
4. ✅ **WAJIB VALIDASI SEBELUM COMMIT**:
   - Jalankan `npx tsc --noEmit && npm run build` (harus 0 errors).
   - Lakukan `git push` ke branch `main`.

---

## 🚀 PERINTAH POST-PULL UNTUK LAPTOP B

Saat Laptop B mulai bekerja:

```bash
# 1. Tarik pembaruan frontend terbaru dari Laptop A
git pull origin main

# 2. Verifikasi status build
npx tsc --noEmit && npm run build
```
