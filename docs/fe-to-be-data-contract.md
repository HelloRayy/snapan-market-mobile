# 📡 KONTRAK DATA DETAIL FRONTEND KE BACKEND (FE $\rightarrow$ BE SPECIFICATION)

Dokumen ini adalah **spesifikasi teknis detail dari sisi Frontend (Laptop A)** untuk **Backend Developer (Laptop B)**. Dokumen ini merinci:
1. Setiap aksi interaksi user di UI.
2. **Payload Request** persis yang dikirim oleh Frontend saat form/tombol ditekan.
3. **Response Data Shape** yang diharapkan diterima oleh Frontend untuk merender komponen.
4. **Mock Data yang harus digantikan** oleh query Supabase aktif.
5. **Mapping CamelCase (FE) $\leftrightarrow$ Snake_Case (PostgreSQL Database)**.

---

## 📑 DAFTAR ISI
1. [Matriks Transformasi Penamaan (CamelCase $\leftrightarrow$ Snake_Case)](#1-matriks-transformasi-penamaan-camelcase--snake_case)
2. [Spesifikasi Payload & Response per Fitur UI](#2-spesifikasi-payload--response-per-fitur-ui)
   - [A. Pembuatan Postingan & Produk (`CreatePostModal.tsx`)](#a-pembuatan-postingan--produk-createpostmodaltsx)
   - [B. Feed Beranda & Interaksi Cepat (`MarketPostCard.tsx`)](#b-feed-beranda--interaksi-cepat-marketpostcardtsx)
   - [C. Komentar Bersarang / Nested Thread (`CommentDetailPage.tsx`)](#c-komentar-bersarang--nested-thread-commentdetailpagetsx)
   - [D. Direct Messaging: Tab Obrolan vs Pembeli (`DirectMessagesPage.tsx`)](#d-direct-messaging-tab-obrolan-vs-pembeli-directmessagespagetsx)
   - [E. Checkout COD & Titik Temu Sekolah (`CheckoutPage.tsx`)](#e-checkout-cod--titik-temu-sekolah-checkoutpagetsx)
   - [F. Edit Profil & Avatar (`EditProfilePage.tsx`)](#f-edit-profil--avatar-editprofilepagetsx)
   - [G. Pencarian Multi-Tab & Rekomendasi Akun (`SearchPage.tsx`)](#g-pencarian-multi-tab--rekomendasi-akun-searchpagetsx)
3. [Daftar Mock Data FE yang Harus Digantikan oleh Supabase](#3-daftar-mock-data-fe-yang-harus-digantikan-oleh-supabase)

---

## 1. 🔄 MATRIKS TRANSFORMASI PENAMAAN (CamelCase $\leftrightarrow$ Snake_Case)

Backend bertugas mengembalikan data dalam format database (`snake_case`), dan API Service di `src/services/api/` bertugas mengonversinya ke `camelCase` untuk UI Frontend:

| Field Frontend (`camelCase`) | Kolom Database (`snake_case`) | Tipe Data TypeScript / Postgres | Keterangan |
| :--- | :--- | :--- | :--- |
| `postType` | `post_type` | `'thread' \| 'product'` | Tipe postingan (Utas sosial vs Jualan) |
| `originalPrice` | `original_price` | `number` / `numeric` | Harga coret sebelum diskon |
| `locationTag` | `location_tag` | `string` / `text` | e.g. `'Kantin Depan'`, `'Lab PPLG 1'` |
| `topicTag` | `topic_tag` | `string` / `text` | e.g. `'frontend'`, `'PJBL'`, `'html-css'` |
| `isOfficialTopic` | `is_official_topic` | `boolean` | `true` jika topik resmi dari dropdown |
| `topicIcon` | `topic_icon` | `string` / `text` | `'threads'` (3-dot) atau `'presentation'` |
| `voiceNoteUrl` | `voice_note_url` | `string` / `text` | URL file audio di Storage `voice-notes` |
| `likesCount` | `likes_count` | `number` / `integer` | Agregat total likes |
| `commentsCount` | `comments_count` | `number` / `integer` | Agregat total komentar |
| `repostsCount` | `reposts_count` | `number` / `integer` | Agregat total posting ulang |
| `parentCommentId` | `parent_comment_id`| `string \| null` / `uuid` | `NULL` = Root, `UUID` = Sub-Reply ($P2 \rightarrow P3$) |
| `classGroup` | `class_group` | `string` / `text` | e.g. `'XII PPLG 1'`, `'XI DKV 2'` |
| `isVerified` | `is_verified` | `boolean` | Centang biru akun terverifikasi |
| `meetingPointId` | `meeting_point_id` | `string` / `uuid` | Foreign key ke `school_meeting_points` |
| `orderStatus` | `order_status` | `'pending' \| 'paid' \| ...` | Status transaksi COD |

---

## 2. 📋 SPESIFIKASI PAYLOAD & RESPONSE PER FITUR UI

---

### A. Pembuatan Postingan & Produk (`CreatePostModal.tsx`)

#### 1. Aksi User:
User mengklik tombol **"+"** di Bottom Nav $\rightarrow$ Modal `CreatePostModal` terbuka $\rightarrow$ Mengisi teks caption, memilih topik, mengunggah foto, merekam voice note, atau menyetel harga jualan $\rightarrow$ Klik **"Posting"**.

#### 2. Payload Request yang Dikirim oleh FE:
```json
{
  "seller_id": "8f3b2a1c-4d5e-6f7a-8b9c-0d1e2f3a4b5c",
  "post_type": "product", 
  "title": "Gantungan Kunci Akrilik PPLG",
  "caption": "Open PO gantungan kunci akrilik logo jurusan PPLG. Bahan tebal 3mm, double side print! 🚀",
  "description": "Spesifikasi: Ukuran 5x5cm, ring gantungan putar anti karat. Tersedia 15 slot!",
  "price": 15000,
  "original_price": 20000,
  "category": "Aksesoris",
  "stock": 15,
  "images": [
    "https://[supabase-url]/storage/v1/object/public/market-media/posts/img-1.webp",
    "https://[supabase-url]/storage/v1/object/public/market-media/posts/img-2.webp"
  ],
  "voice_note_url": "https://[supabase-url]/storage/v1/object/public/voice-notes/vn-123.webm",
  "location_tag": "Lab PPLG 1",
  "topic_tag": "PJBL",
  "is_official_topic": true,
  "topic_icon": "presentation"
}
```

#### 3. Response Shape yang Diharapkan FE:
```typescript
interface CreatePostResponse {
  id: string; // UUID post baru
  created_at: string; // ISO Timestamp
  seller_id: string;
  post_type: 'thread' | 'product';
  title: string | null;
  caption: string;
  price: number;
  stock: number;
  images: string[];
  likes_count: 0;
  comments_count: 0;
  reposts_count: 0;
}
```

---

### B. Feed Beranda & Interaksi Cepat (`MarketPostCard.tsx`)

#### 1. Aksi User:
User membuka beranda $\rightarrow$ Melakukan aksi Like (❤️), Repost (🔁), Bookmark (🔖), atau Share link (🔗).

#### 2. Service & Payload:
- **Fetch Feed**: `GET /rest/v1/market_posts?select=*,seller:profiles(*),likes:post_likes(user_id)&order=created_at.desc`
- **Toggle Like**:
  ```typescript
  // Payload ke tabel post_likes
  { "post_id": "post-uuid", "user_id": "auth-user-uuid" }
  ```
- **Toggle Bookmark**:
  ```typescript
  // Payload ke tabel post_bookmarks
  { "post_id": "post-uuid", "user_id": "auth-user-uuid" }
  ```

#### 3. Response Data Model yang Digunakan Komponen FE (`MarketPostItem`):
```typescript
interface MarketPostItem {
  id: string;
  postType: 'thread' | 'product';
  title?: string;
  description?: string;
  caption: string;
  price?: number;
  originalPrice?: number;
  category?: string;
  images: string[];
  stock?: number;
  locationTag?: string;
  topicTag?: string;
  isOfficialTopic?: boolean;
  topicIcon?: string;
  likesCount: number;
  commentsCount: number;
  repostsCount: number;
  timestamp: string; // FE formatter mengonversi created_at -> '10m', '2j'
  isLiked: boolean; // Computed dari apakah auth.uid() ada di post_likes
  isReposted: boolean; // Computed dari post_reposts
  isSaved: boolean; // Computed dari post_bookmarks
  seller: {
    id: string;
    name: string;
    username: string;
    avatar: string;
    classGroup: string;
    isVerified: boolean;
  };
}
```

---

### C. Komentar Bersarang / Nested Thread (`CommentDetailPage.tsx`)

#### 1. Aksi User:
User membuka detail postingan $\rightarrow$ Melihat thread komentar tingkat 1 ($P2$) dan membalas komentar orang lain sehingga membentuk balasan anak tingkat 2 ($P3, P4$).

#### 2. Payload Request Tambah Komentar (`createComment`):
```json
{
  "post_id": "post-uuid-123",
  "user_id": "auth-user-uuid",
  "parent_comment_id": "parent-comment-uuid-456", // Isi NULL jika komentar utama, isi UUID jika membalas komentar
  "content": "Bisa COD di depan Lab DKV waktu istirahat kedua kak?",
  "images": []
}
```

#### 3. Response Hierarchy yang Dibutuhkan FE:
```typescript
interface PostComment {
  id: string;
  postId: string;
  content: string;
  timestamp: string;
  likesCount: number;
  isLiked: boolean;
  user: {
    id: string;
    name: string;
    username: string;
    avatar: string;
    classGroup: string;
    isVerified: boolean;
    isAuthor?: boolean; // True jika user.id === post.seller_id
  };
  replies?: PostComment[]; // Array komentar anak rekursif
}
```

---

### D. Direct Messaging: Tab Obrolan vs Pembeli (`DirectMessagesPage.tsx`)

#### 1. Aksi User:
User membuka halaman Pesan $\rightarrow$ Berpindah antara tab **[ Obrolan ]** (chat santai) dan **[ Pembeli ]** (inquiry produk barang jualan).

#### 2. Pemisahan Logika Database:
- **Filter "Obrolan"**: `WHERE product_id IS NULL`
- **Filter "Pembeli"**: `WHERE product_id IS NOT NULL` (chat yang dipicu dari tombol *Tanya Penjual / Beli* pada kartu produk)

#### 3. Payload Kirim Pesan Baru:
```json
{
  "conversation_id": "conv-uuid-789",
  "sender_id": "auth-user-uuid",
  "message_text": "Halo kak, apakah slot preloved hoodie masih ada?",
  "is_read": false
}
```

#### 4. Realtime Channel Subscription di FE:
```typescript
// FE mendengarkan event INSERT pada tabel direct_messages
supabase
  .channel(`dm-chat-${conversationId}`)
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'direct_messages',
    filter: `conversation_id=eq.${conversationId}`
  }, (payload) => {
    // FE otomatis menambahkan bubble chat baru secara realtime
  })
  .subscribe();
```

---

### E. Checkout COD & Titik Temu Sekolah (`CheckoutPage.tsx`)

#### 1. Aksi User:
User mengklik tombol **"Beli Sekarang"** pada produk $\rightarrow$ Masuk ke `CheckoutPage.tsx` $\rightarrow$ Memilih jumlah barang dan memilih titik temu COD di peta sekolah 2D $\rightarrow$ Mengklik **"Buat Pesanan"**.

#### 2. Payload Request Pembuatan Order:
```json
{
  "buyer_id": "buyer-user-uuid",
  "seller_id": "seller-user-uuid",
  "post_id": "product-post-uuid",
  "meeting_point_id": "meeting-point-uuid-kantin",
  "quantity": 2,
  "unit_price": 15000,
  "total_amount": 30000,
  "order_status": "pending",
  "scheduled_at": "2026-08-28T03:30:00Z", // Jam istirahat sekolah
  "notes": "Tolong dibungkus plastik ya kak, saya tunggu di gazebo depan lab."
}
```

#### 3. Query Master Titik Temu Kampus (`school_meeting_points`):
```json
[
  {
    "id": "mp-1",
    "name": "Kantin Depan (Gazebo Utama)",
    "code": "KANTIN-01",
    "category": "Kantin",
    "description": "Dekat kasir kantin bu Siti",
    "floor": "Lantai 1",
    "pin_x": 420,
    "pin_y": 680,
    "is_active": true
  },
  {
    "id": "mp-2",
    "name": "Lobi Gedung PPLG / DKV",
    "code": "LAB-PPLG-01",
    "category": "Akademik",
    "description": "Depan pintu masuk Lab Komputer 1",
    "floor": "Lantai 2",
    "pin_x": 210,
    "pin_y": 340,
    "is_active": true
  }
]
```

---

### F. Edit Profil & Avatar (`EditProfilePage.tsx`)

#### 1. Aksi User:
User membuka halaman profil $\rightarrow$ Klik **"Edit Profil"** $\rightarrow$ Mengubah bio, minat, link Instagram, kelas, atau memilih foto preset $\rightarrow$ Klik **"Selesai"**.

#### 2. Payload Update Profil:
```json
{
  "full_name": "Raditya Rayhan",
  "username": "radityarayhannnn",
  "bio": "XII PPLG 1 • Tech Enthusiast • Jual aksesoris PPLG & preloved distro",
  "class_group": "XII PPLG 1",
  "avatar_url": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&q=80",
  "interests": "💻 Web PWA, 🎨 UI/UX, 👕 Preloved, ⚡ Joki Coding",
  "link": "https://instagram.com/radityarayhannnn"
}
```

---

### G. Pencarian Multi-Tab & Rekomendasi Akun (`SearchPage.tsx`)

#### 1. Aksi User:
User mengetik query di search bar $\rightarrow$ Menekan tombol cari $\rightarrow$ Berpindah antara tab **[ Terpopuler ]**, **[ Terbaru ]**, dan **[ Profil ]**.

#### 2. Kebutuhan Query Backend:
- **Tab Terpopuler**: Query `market_posts` diurutkan berdasarkan `likes_count + comments_count * 2 DESC`.
- **Tab Terbaru**: Query `market_posts` diurutkan berdasarkan `created_at DESC`.
- **Tab Profil**: Query `profiles` dengan filter `username ILIKE '%query%' OR full_name ILIKE '%query%' OR bio ILIKE '%query%'`.

---

## 3. 📦 DAFTAR MOCK DATA FE YANG HARUS DIGANTIKAN OLEH SUPABASE

Saat ini Frontend memiliki file mock data di `src/data/mockMarketData.ts`. Backend wajib mengisi database Supabase agar data ini bisa digantikan sepenuhnya:

| Variabel Mock di Frontend | Lokasi Penggunaan di UI | Target Tabel Supabase Pengganti |
| :--- | :--- | :--- |
| `MOCK_MARKET_POSTS` | `HomePage.tsx`, `MarketPostCard.tsx` | Tabel `market_posts` join `profiles` |
| `MOCK_USER_REPLIES` | `ProfilePage.tsx` (Tab Balasan) | Tabel `post_comments` join `market_posts` |
| `INITIAL_SUGGESTED_ACCOUNTS` | `SearchPage.tsx` (Saran Ikuti) | Tabel `profiles` (Top accounts by followers) |
| `PRESET_AVATARS` | `EditProfilePage.tsx` | Supabase Storage Bucket `avatars/presets/` |
| `MOCK_MEETING_POINTS` | `Campus2DMap.tsx`, `CheckoutPage.tsx` | Tabel `school_meeting_points` |

---

## 💡 Ringkasan untuk Laptop B:
Semua interface TypeScript di atas sudah terdaftar di `src/types/marketFeed.ts` dan `src/types/product.ts`. Backend developer tinggal mencocokkan field di atas ke dalam PostgreSQL query dan function service di `src/services/api/`.
