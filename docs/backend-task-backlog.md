# 🗄️ DOKUMEN IMPLEMENTASI BACKEND (LAPTOP B) — TASK BACKLOG & API CONTRACTS

Dokumen ini adalah **panduan kerja resmi dan backlog tugas teknis Backend (Laptop B / Supabase)**. Dokumen ini memetakan seluruh fitur dan komponen Frontend yang telah selesai di **Laptop A** ke dalam kebutuhan Database Schema, Row Level Security (RLS), Realtime Channels, Storage Buckets, dan API Service Functions di Supabase.

---

## 📌 DAFTAR ISI
1. [Ringkasan Arsitektur FE $\leftrightarrow$ BE](#1-ringkasan-arsitektur-fe--be)
2. [Tabel Matriks Fitur Frontend ke Tugas Backend](#2-tabel-matriks-fitur-frontend-ke-tugas-backend)
3. [Rincian 8 Epic Tugas Backend (Laptop B)](#3-rincian-8-epic-tugas-backend-laptop-b)
4. [Master Script SQL Schema & RLS (Supabase SQL Editor)](#4-master-script-sql-schema--rls-supabase-sql-editor)
5. [Daftar Service API & Type Contract (`src/services/api/`)](#5-daftar-service-api--type-contract)
6. [Checklist Verifikasi & Kriteria Penerimaan](#6-checklist-verifikasi--kriteria-penerimaan)

---

## 1. 🏗️ RINGKASAN ARSITEKTUR FE $\leftrightarrow$ BE

```
┌────────────────────────────────────────────────────────────────────────┐
│                     FRONTEND (Laptop A — React 18 + PWA)                │
│  Pages: Home, Search, Profile, DirectMessages, Checkout, CampusMap     │
│  Components: MarketPostCard, CreatePostModal, PostCommentItem, dll.    │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ (Typed Queries / Mutations / Realtime)
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                   BACKEND LAYER (Laptop B — Supabase)                  │
│  • Auth: GoTrue (Email + Google OAuth)                                 │
│  • Database: PostgreSQL 15 + RLS (Row Level Security)                  │
│  • Storage: Public Buckets (`market-media`, `avatars`, `voice-notes`)   │
│  • Realtime: Supabase Realtime Channels (`dm-chat`, `notifications`)   │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. 📊 TABEL MATRIKS FITUR FRONTEND KE TUGAS BACKEND

| No | Modul Frontend | Lokasi File UI | Kebutuhan Entitas Database | Kebutuhan API Service | Realtime / Storage |
| :-: | :--- | :--- | :--- | :--- | :--- |
| **1** | **User Auth & Profil** | `src/ui/pages/ProfilePage.tsx`<br>`src/ui/pages/EditProfilePage.tsx` | Tabel `profiles`, `user_follows` | `authService.ts`<br>`profileService.ts` | Storage: `avatars` |
| **2** | **Feed Postingan (Utas & Produk)** | `src/ui/components/marketplace/MarketPostCard.tsx`<br>`src/ui/components/marketplace/CreatePostModal.tsx` | Tabel `market_posts` | `marketPostsService.ts` | Storage: `market-media`<br>Storage: `voice-notes` |
| **3** | **Komentar & Sub-Thread Bersarang** | `src/ui/components/marketplace/PostCommentItem.tsx`<br>`src/ui/components/marketplace/CommentDetailPage.tsx` | Tabel `post_comments`, `comment_likes` | `commentService.ts` | — |
| **4** | **Sistem Interaksi Sosial (Like, Repost, Bookmark)** | `src/ui/components/marketplace/MarketPostCard.tsx`<br>`src/ui/components/marketplace/PostSubmenuDropdown.tsx` | Tabel `post_likes`, `post_reposts`, `post_bookmarks` | `bookmarkService.ts`<br>`likeService.ts` | — |
| **5** | **Direct Messages (Obrolan vs Pembeli)** | `src/ui/pages/DirectMessagesPage.tsx` | Tabel `direct_messages`, `conversations` | `chatService.ts` | Realtime: `dm-chat-${userId}` |
| **6** | **Checkout & Titik Temu COD Kampus** | `src/ui/pages/CheckoutPage.tsx`<br>`src/ui/components/map/Campus2DMap.tsx` | Tabel `in_app_orders`, `school_meeting_points` | `checkoutService.ts`<br>`meetingPointService.ts` | — |
| **7** | **Pemberitahuan & Notifikasi Pesanan** | `src/ui/components/ui/ToastNotification.tsx`<br>`src/ui/components/marketplace/MarketBottomNav.tsx` | Tabel `notifications`, `order_notifications` | `notificationService.ts`<br>`orderNotificationService.ts` | Realtime: `order-notifs-${userId}` |
| **8** | **Pencarian Semantik & Saran Akun** | `src/ui/pages/SearchPage.tsx` | Query PostgreSQL Full-Text Search / Tokenizer | `searchService.ts` | — |

---

## 3. 🎯 RINCIAN 8 EPIC TUGAS BACKEND (LAPTOP B)

### 📌 EPIC 1: User Profile & Follow System
- **Deskripsi**: Menyimpan data identitas siswa, kelas/jurusan, status verifikasi, minat, tautan profil, dan relasi pertemanan/following.
- **Tugas Backend**:
  1. Buat tabel `profiles` dengan trigger otomatis saat user signup (`auth.users` $\rightarrow$ `profiles`).
  2. Buat tabel `user_follows` (`follower_id`, `following_id`) dengan constraint unique.
  3. Implementasikan fungsi API: `getProfile(userId)`, `updateProfile(userId, data)`, `toggleFollowUser(targetUserId)`.

---

### 📌 EPIC 2: Multi-Type Market Posts (Utas Sosial, Produk, & Voice Note)
- **Deskripsi**: Menyimpan postingan di beranda yang terdiri dari tipe `thread` (diskusi) dan `product` (jualan dengan harga/stok), serta lampiran audio/voice note.
- **Tugas Backend**:
  1. Buat tabel `market_posts` dengan kolom `post_type`, `title`, `caption`, `description`, `price`, `original_price`, `stock`, `images`, `voice_note_url`, `topic_tag`, `location_tag`.
  2. Pasang Storage Bucket `market-media` (foto produk) dan `voice-notes` (audio voice note) dengan public access.
  3. Implementasikan pagination `fetchMarketFeed({ page, limit, category, topicTag })`.

---

### 📌 EPIC 3: Threaded Comments & Nested Sub-Replies
- **Deskripsi**: Komentar bertingkat bergaya Threads ($P1 \rightarrow P2 \rightarrow P3 \rightarrow P4$) dengan parent referencing.
- **Tugas Backend**:
  1. Buat tabel `post_comments` dengan self-referencing column `parent_comment_id`.
  2. Implementasikan query rekursif atau nested join untuk mereturn komentar root beserta anak-anak balasannya.
  3. Pasang cascade delete: jika root comment dihapus, semua sub-balasan otomatis terhapus.

---

### 📌 EPIC 4: Social Action Aggregations (Likes, Reposts, Bookmarks)
- **Deskripsi**: Menangani aksi interaksi cepat dengan status toggle idempotent.
- **Tugas Backend**:
  1. Buat tabel `post_likes`, `post_reposts`, dan `post_bookmarks`.
  2. Buat PostgreSQL Database Triggers untuk otomatis menambah/mengurangi `likes_count` dan `comments_count` pada `market_posts`.
  3. Implementasikan `togglePostBookmark(postId, sellerId, shouldSave)`.

---

### 📌 EPIC 5: Direct Messages (Tab "Obrolan" & "Pembeli")
- **Deskripsi**: Sistem pesan instan yang memisahkan chat biasa dengan chat calon pembeli produk jualan.
- **Tugas Backend**:
  1. Buat tabel `conversations` dan `direct_messages`.
  2. Kolom `product_id` pada percakapan: jika terisi, masuk ke filter tab **"Pembeli"**; jika `NULL`, masuk ke filter tab **"Obrolan"**.
  3. Buat Supabase Realtime Channel untuk sinkronisasi pesan baru secara instan tanpa refresh.

---

### 📌 EPIC 6: In-App Checkout & School COD Meeting Points
- **Deskripsi**: Alur checkout pesanan barang/jasa dengan pemilihan titik temu COD di area sekolah (Kantin, Lab, Lapangan, dll.).
- **Tugas Backend**:
  1. Buat tabel master `school_meeting_points` (berisi koordinat peta 2D kampus).
  2. Buat tabel transaksi `in_app_orders` dengan status enum: `pending`, `paid`, `completed`, `cancelled`.
  3. Implementasikan service `createOrder(payload)` dan `updateOrderStatus(orderId, status)`.

---

### 📌 EPIC 7: Realtime Notifications & In-App Alerts
- **Deskripsi**: Mengirim notifikasi saat postingan disukai, dibalas, atau saat ada order pesanan baru dari pembeli.
- **Tugas Backend**:
  1. Buat tabel `notifications` dan `order_notifications`.
  2. Trigger otomatis: saat baris baru masuk ke `in_app_orders`, trigger insert ke `order_notifications`.
  3. Implementasikan service `getUnreadNotificationCount(userId)` dan `markAsRead(notificationId)`.

---

### 📌 EPIC 8: Full-Text Search & Discovery
- **Deskripsi**: Pencarian postingan, produk, hashtag, dan profil pengguna pada `SearchPage.tsx`.
- **Tugas Backend**:
  1. Buat PostgreSQL GIN index pada `market_posts.caption`, `market_posts.title`, `profiles.username`, dan `profiles.full_name`.
  2. Sediakan fungsi query `searchAll(query, tab: 'top' | 'latest' | 'profiles')`.

---

## 4. 📜 MASTER SCRIPT SQL SCHEMA & RLS (Supabase SQL Editor)

Laptop B cukup menyalin dan menjalankan seluruh script SQL di bawah ini pada **Supabase Dashboard $\rightarrow$ SQL Editor**:

```sql
-- ============================================================================
-- 1. ENUMS & EXTENSIONS
-- ============================================================================
create extension if not exists "uuid-ossp";

create type post_type_enum as enum ('thread', 'product');
create type order_status_enum as enum ('pending', 'paid', 'completed', 'cancelled');
create type notification_type_enum as enum ('like', 'comment', 'reply', 'order', 'system');

-- ============================================================================
-- 2. TABEL PROFILES & USER FOLLOWS
-- ============================================================================
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  full_name text not null,
  username text unique,
  avatar_url text,
  bio text default '',
  link text default '',
  interests text default '',
  class_group text default 'Siswa Snapan',
  is_verified boolean default false,
  role text default 'buyer' check (role in ('buyer', 'seller', 'admin')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table if not exists public.user_follows (
  follower_id uuid references public.profiles(id) on delete cascade not null,
  following_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (follower_id, following_id)
);

-- Trigger Otomatis User Baru
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

-- ============================================================================
-- 3. TABEL MARKET POSTS & SOCIAL ACTIONS
-- ============================================================================
create table if not exists public.market_posts (
  id uuid default gen_random_uuid() primary key,
  seller_id uuid references public.profiles(id) on delete cascade not null,
  post_type post_type_enum default 'thread' not null,
  title text,
  caption text not null,
  description text,
  price numeric default 0 check (price >= 0),
  original_price numeric default 0 check (original_price >= 0),
  category text default 'Lainnya',
  images text[] default '{}',
  voice_note_url text,
  stock integer default 1 check (stock >= 0),
  location_tag text,
  topic_tag text,
  is_official_topic boolean default false,
  topic_icon text default 'threads',
  likes_count integer default 0 check (likes_count >= 0),
  comments_count integer default 0 check (comments_count >= 0),
  reposts_count integer default 0 check (reposts_count >= 0),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table if not exists public.post_likes (
  post_id uuid references public.market_posts(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (post_id, user_id)
);

create table if not exists public.post_reposts (
  post_id uuid references public.market_posts(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (post_id, user_id)
);

create table if not exists public.post_bookmarks (
  post_id uuid references public.market_posts(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (post_id, user_id)
);

-- ============================================================================
-- 4. TABEL THREADED COMMENTS & SUB-REPLIES
-- ============================================================================
create table if not exists public.post_comments (
  id uuid default gen_random_uuid() primary key,
  post_id uuid references public.market_posts(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  parent_comment_id uuid references public.post_comments(id) on delete cascade,
  content text not null,
  images text[] default '{}',
  likes_count integer default 0 check (likes_count >= 0),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table if not exists public.comment_likes (
  comment_id uuid references public.post_comments(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (comment_id, user_id)
);

-- ============================================================================
-- 5. TABEL DIRECT MESSAGING (OBROLAN VS PEMBELI)
-- ============================================================================
create table if not exists public.conversations (
  id uuid default gen_random_uuid() primary key,
  participant_one uuid references public.profiles(id) on delete cascade not null,
  participant_two uuid references public.profiles(id) on delete cascade not null,
  product_id uuid references public.market_posts(id) on delete set null, -- NULL: Obrolan, UUID: Pembeli
  last_message text default '',
  last_message_at timestamp with time zone default timezone('utc'::text, now()) not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table if not exists public.direct_messages (
  id uuid default gen_random_uuid() primary key,
  conversation_id uuid references public.conversations(id) on delete cascade not null,
  sender_id uuid references public.profiles(id) on delete cascade not null,
  message_text text not null,
  is_read boolean default false not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- ============================================================================
-- 6. TABEL COD MEETING POINTS & IN-APP ORDERS
-- ============================================================================
create table if not exists public.school_meeting_points (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  code text unique not null,
  category text not null,
  description text default '',
  floor text default 'Lantai 1',
  pin_x integer not null,
  pin_y integer not null,
  is_active boolean default true not null
);

create table if not exists public.in_app_orders (
  id uuid default gen_random_uuid() primary key,
  buyer_id uuid references public.profiles(id) on delete cascade not null,
  seller_id uuid references public.profiles(id) on delete cascade not null,
  post_id uuid references public.market_posts(id) on delete cascade not null,
  meeting_point_id uuid references public.school_meeting_points(id) on delete set null,
  quantity integer default 1 check (quantity > 0) not null,
  unit_price numeric not null,
  total_amount numeric not null,
  order_status order_status_enum default 'pending' not null,
  scheduled_at timestamp with time zone,
  notes text default '',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- ============================================================================
-- 7. TABEL NOTIFICATIONS & ORDER NOTIFICATIONS
-- ============================================================================
create table if not exists public.notifications (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  actor_id uuid references public.profiles(id) on delete set null,
  type notification_type_enum default 'system' not null,
  title text not null,
  message text not null,
  post_id uuid references public.market_posts(id) on delete set null,
  is_read boolean default false not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table if not exists public.order_notifications (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  order_id uuid references public.in_app_orders(id) on delete cascade not null,
  is_read boolean default false not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- ============================================================================
-- 8. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================
alter table public.profiles enable row level security;
alter table public.user_follows enable row level security;
alter table public.market_posts enable row level security;
alter table public.post_likes enable row level security;
alter table public.post_reposts enable row level security;
alter table public.post_bookmarks enable row level security;
alter table public.post_comments enable row level security;
alter table public.comment_likes enable row level security;
alter table public.conversations enable row level security;
alter table public.direct_messages enable row level security;
alter table public.school_meeting_points enable row level security;
alter table public.in_app_orders enable row level security;
alter table public.notifications enable row level security;
alter table public.order_notifications enable row level security;

-- SELECT Policies (Publik vs Private)
create policy "Public profiles are readable by everyone" on public.profiles for select using (true);
create policy "Public posts are readable by everyone" on public.market_posts for select using (true);
create policy "Public comments are readable by everyone" on public.post_comments for select using (true);
create policy "Public meeting points readable by everyone" on public.school_meeting_points for select using (true);

-- User-specific CRUD Policies
create policy "Users can update own profile" on public.profiles for update using (auth.uid() = id);
create policy "Users can insert own posts" on public.market_posts for insert with check (auth.uid() = seller_id);
create policy "Users can update own posts" on public.market_posts for update using (auth.uid() = seller_id);
create policy "Users can delete own posts" on public.market_posts for delete using (auth.uid() = seller_id);

create policy "Users can manage own likes" on public.post_likes for all using (auth.uid() = user_id);
create policy "Users can manage own reposts" on public.post_reposts for all using (auth.uid() = user_id);
create policy "Users can manage own bookmarks" on public.post_bookmarks for all using (auth.uid() = user_id);

create policy "Users can view own conversations" on public.conversations for select using (auth.uid() in (participant_one, participant_two));
create policy "Users can view own messages" on public.direct_messages for select using (
  exists (select 1 from public.conversations where id = direct_messages.conversation_id and auth.uid() in (participant_one, participant_two))
);

create policy "Users can view own orders" on public.in_app_orders for select using (auth.uid() in (buyer_id, seller_id));
create policy "Users can view own notifications" on public.notifications for select using (auth.uid() = user_id);
create policy "Users can view own order notifications" on public.order_notifications for select using (auth.uid() = user_id);
```

---

## 5. 🔌 DAFTAR SERVICE API & TYPE CONTRACT

Laptop B bertanggung jawab memverifikasi implementasi fungsi-fungsi di folder `src/services/api/`:

| File Service | Fungsi Utama | Status Kontrak di Frontend |
| :--- | :--- | :---: |
| `src/services/api/marketPostsService.ts` | `fetchMarketFeed()`, `createMarketPost()`, `deleteMarketPost()` | ✅ Siap Konsumsi |
| `src/services/api/bookmarkService.ts` | `togglePostBookmark()`, `fetchUserBookmarks()` | ✅ Siap Konsumsi |
| `src/services/api/commentService.ts` | `fetchPostComments()`, `createComment()`, `toggleCommentLike()` | ✅ Siap Konsumsi |
| `src/services/api/meetingPointService.ts` | `getSchoolMeetingPoints()`, `getMeetingPointById()` | ✅ Siap Konsumsi |
| `src/services/api/orderNotificationService.ts` | `getOrderNotifications()`, `getUnreadOrderNotificationCount()` | ✅ Siap Konsumsi |
| `src/services/api/notificationService.ts` | `getUserNotifications()`, `markNotificationAsRead()` | ✅ Siap Konsumsi |
| `src/services/api/realtimeService.ts` | `subscribeToOrderNotifications()`, `subscribeToDirectChat()` | ✅ Siap Konsumsi |

---

## 6. ✅ CHECKLIST VERIFIKASI & KRITERIA PENERIMAAN (LAPTOP B)

Sebelum Laptop B menyatakan tugas backend selesai, jalankan checklist verifikasi berikut:

- [ ] **SQL Script**: Seluruh tabel, enums, triggers, dan RLS berhasil di-execute di Supabase SQL Editor tanpa error.
- [ ] **Storage Buckets**: Bucket `market-media`, `avatars`, dan `voice-notes` telah dibuat dengan hak akses *Public*.
- [ ] **Environment Variables**: `.env` memiliki `VITE_SUPABASE_URL` dan `VITE_SUPABASE_ANON_KEY` yang valid.
- [ ] **TypeScript Contract Check**: File `src/types/supabase.ts` sinkron 100% dengan skema tabel terbaru.
- [ ] **Build Validation**: Perintah `npx tsc --noEmit && npm run build` menghasilkan **0 Error**.
- [ ] **Git Push**: Jalankan `git add . && git commit -m "feat(backend): complete supabase schema, rls, and service functions" && git push -u origin main`.
