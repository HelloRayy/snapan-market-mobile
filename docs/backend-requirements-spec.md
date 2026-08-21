# 📋 BACKEND REQUIREMENTS SPECIFICATION (FOR LAPTOP B)

Dokumen ini adalah **Spesifikasi Kebutuhan Teknis Backend (Backend PRD)** yang disusun dari sisi Frontend (Laptop A) untuk dikerjakan oleh Backend Workstation (Laptop B). 

Dokumen ini **TIDAK memberikan kode jadi**, melainkan mendefinisikan **kebutuhan domain data, relasi bisnis, mutation flow, dan ekspektasi response** yang harus dipenuhi oleh Backend Supabase.

---

## 🏗️ 1. DOMAIN DATA & ENTITAS YANG DIBUTUHKAN FRONTEND

### A. Domain Profil Pengguna (`User Profile`)
- **Tujuan**: Menyimpan data identitas siswa/guru untuk ditampilkan pada setiap postingan, komentar, dan keranjang.
- **Kebutuhan Data**:
  - Relasi `1:1` dengan `auth.users` Supabase.
  - Data yang ditampilkan di UI: Nama Lengkap, Username unik, Foto Profil (Avatar URL), Label Kelas/Jurusan (contoh: `'XII PPLG 1'`), Status Verifikasi (`isVerified`), dan Role (`buyer` / `seller` / `admin`).
- **Aturan Bisnis**:
  - Saat user baru mendaftar lewat Auth (Google OAuth / Email), profil dasar harus otomatis terbuat.
  - Profil bersifat publik (bisa dibaca siapa saja), namun hanya pemilik akun yang berhak mengedit profilnya sendiri.

---

### B. Domain Postingan Feed (`Market Posts`)
- **Tujuan**: Menyimpan postingan di beranda yang terdiri dari 2 tipe:
  1. **Utas Sosial (`thread`)**: Diskusi/cerita tanpa harga.
  2. **Produk Marketplace (`product`)**: Barang/jasa jualan dengan harga, stok, dan spesifikasi.
- **Kebutuhan Data**:
  - Tipe Postingan (`thread` vs `product`).
  - Informasi Penjual (Foreign Key ke Profil Pengguna).
  - Konten: Judul (opsional untuk produk), Teks Caption, Deskripsi Detail (untuk bottom sheet produk).
  - Nilai Transaksi: Harga Jual (`price`), Harga Coret Asli (`original_price`).
  - Inventori: Kategori barang, Jumlah Stok (`stock`).
  - Media: Array URL Gambar/Video.
  - Metadata Tag: Tag Lokasi (contoh: `'Kantin Depan'`), Tag Topik (contoh: `'PJBL'`), Status Official Topic.
  - Agregat Interaksi: Counter Total Suka (`likes_count`), Counter Total Komentar (`comments_count`).
- **Aturan Bisnis**:
  - Publik bisa membaca semua postingan.
  - Hanya pengguna terautentikasi yang bisa membuat postingan.
  - Hanya pemilik postingan yang bisa mengedit atau menghapus postingannya.

---

### C. Domain Komentar & Sub-Thread Bersarang (`Threaded Comments`)
- **Tujuan**: Mendukung percakapan bertingkat ala Threads ($P1 \rightarrow P2 \rightarrow P3 \rightarrow P4$).
- **Kebutuhan Data**:
  - Relasi ke Postingan Utama (`post_id`).
  - Relasi ke Pembuat Komentar (`user_id`).
  - **Relasi Self-Referencing (`parent_comment_id`)**:
    - Jika bernilai `NULL` $\rightarrow$ Komentar Utama tingkat 1 ($P2$).
    - Jika berisi `comment_id` $\rightarrow$ Balasan bersarang ($P3, P4$).
  - Konten teks komentar, lampiran gambar opsional, nomor urut utas (`thread_part` / `total_parts`).
  - Counter Suka Komentar (`likes_count`).
- **Aturan Bisnis**:
  - Jika sebuah komentar dihapus, seluruh sub-balasan di bawahnya harus terhapus secara beruntun (*Cascade Delete*).
  - Pengguna hanya bisa menghapus komentarnya sendiri.

---

### D. Domain Interaksi Suka (`Likes System`)
- **Tujuan**: Mendukung fitur Like pada Postingan Utama dan Like pada Komentar/Balasan.
- **Kebutuhan Data**:
  - **Post Likes**: Pasangan unik `(post_id, user_id)`.
  - **Comment Likes**: Pasangan unik `(comment_id, user_id)`.
- **Aturan Bisnis**:
  - Bersifat idempotent / toggle (jika belum like $\rightarrow$ tambahkan; jika sudah like $\rightarrow$ hapus).
  - Satu user hanya boleh like 1x per post/komentar.
  - Query feed & komentar harus mengembalikan status `isLiked: boolean` berdasarkan user yang sedang login.

---

### E. Domain Keranjang Belanja (`Shopping Cart`)
- **Tujuan**: Menyimpan item produk yang dimasukkan ke keranjang oleh pembeli.
- **Kebutuhan Data**:
  - Relasi ke Pembeli (`user_id`).
  - Relasi ke Produk Postingan (`post_id`).
  - Kuantitas pesanan (`quantity`).
- **Aturan Bisnis**:
  - Keranjang bersifat privat (hanya bisa dilihat dan diubah oleh pemilik `user_id`).
  - Jika item yang sama ditambahkan lagi, kuantitas di-update (bukan membuat baris duplikat).

---

### F. Domain Media Storage (`Storage Buckets`)
- **Tujuan**: Tempat penyimpanan file gambar upload (bukti bayar, foto produk, foto profil, avatar).
- **Kebutuhan**:
  - Bucket publik: `market-media`.
  - File yang di-upload harus menghasilkan Public URL yang bisa diakses langsung oleh frontend.

---

## 🔄 2. RANGKUMAN ALUR INTEGRASI API (FRONTEND $\leftrightarrow$ BACKEND)

Frontend telah menyiapkan pemanggilan API service di folder `src/services/api/` dengan ekspektasi fungsi sebagai berikut:

| Nama Modul API | Fungsi yang Harus Disediakan Backend | Ekspektasi Output untuk Frontend |
| :--- | :--- | :--- |
| **`postService`** | `fetchMarketFeed(limit, page)` | Mengembalikan list postingan + profil penjual + status `isLiked` user aktif. |
| | `createMarketPost(payload)` | Menyimpan post baru dan mengembalikan objek post yang baru dibuat. |
| | `togglePostLike(postId, userId)` | Toggle suka post & memperbarui counter agregat. |
| **`commentService`** | `fetchPostComments(postId)` | Mengembalikan daftar komentar root beserta relasi sub-balasan bersarangnya. |
| | `createComment(payload)` | Menyimpan komentar/sub-reply baru (`parent_comment_id`). |
| | `toggleCommentLike(commentId, userId)`| Toggle suka pada komentar/balasan. |
| **`cartService`** | `fetchUserCart(userId)` | Mengembalikan list item keranjang join detail produk & penjual. |
| | `addToCart(userId, postId, qty)` | Menambah/update item keranjang. |
| | `removeFromCart(cartItemId)` | Menghapus item dari keranjang. |
| **`profileService`**| `fetchProfile(userId)` | Mengambil data profil lengkap user. |
| | `updateProfile(userId, payload)` | Mengupdate profil (nama, avatar, kelas, username). |

---

## 🛡️ 3. STANDAR KEAMANAN & INTEGRITAS DATA (RLS)

1. **Row Level Security (RLS)** wajib diaktifkan pada semua tabel.
2. Kebijakan **SELECT**:
   - `profiles`, `market_posts`, `post_comments`, `post_likes`, `comment_likes`: **Publik**.
   - `cart_items`: **Hanya pemilik (`auth.uid() = user_id`)**.
3. Kebijakan **INSERT / UPDATE / DELETE**:
   - Hanya user yang terautentikasi dan memiliki ID yang cocok (`auth.uid() = seller_id` atau `auth.uid() = user_id`) yang berhak memodifikasi datanya.
