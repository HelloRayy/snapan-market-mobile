# 📱 OVERVIEW & PANDUAN INTERAKSI: SNAPAN MARKET MOBILE
> **Dokumentasi Lengkap Konsep Aplikasi, Alur Pengguna, dan Seluruh Desain Interaksi**  
> *Panduan Resmi untuk Presentasi, Pengujian UX, dan Portofolio SMKN 8 Jakarta.*

---

## 📌 DAFTAR ISI
1. [Overview Aplikasi & Visi Produk](#1-overview-aplikasi--visi-produk)
2. [Profil Pengguna & Target Audience](#2-profil-pengguna--target-audience)
3. [Peta Interaksi Utama Aplikasi (User Journey Map)](#3-peta-interaksi-utama-aplikasi-user-journey-map)
4. [Rincian Desain Interaksi per Halaman](#4-rincian-desain-interaksi-per-halaman)
   - 4.1. [Interaksi Halaman Utama (Home Feed)](#41-interaksi-halaman-utama-home-feed)
   - 4.2. [Interaksi Marketplace & Transaksi Produk](#42-interaksi-marketplace--transaksi-produk)
   - 4.3. [Interaksi Pembuatan Post & Jualan (Create Modal)](#43-interaksi-pembuatan-post--jualan-create-modal)
   - 4.4. [Interaksi Pencarian Multi-Dimensi (Search Page)](#44-interaksi-pencarian-multi-dimensi-search-page)
   - 4.5. [Interaksi Kolom Komentar & Diskusi Bertingkat](#45-interaksi-kolom-komentar--diskusi-bertingkat)
   - 4.6. [Interaksi Profil & Pengaturan Akun](#46-interaksi-profil--pengaturan-akun)
5. [Standar Micro-Interactions & Sentuhan Taktil (Haptics & Motion)](#5-standar-micro-interactions--sentuhan-taktil-haptics--motion)
6. [Teknologi & Arsitektur Pendukung](#6-teknologi--arsitektur-pendukung)

---

## 1. Overview Aplikasi & Visi Produk

### 💡 Apa Itu Snapan Market Mobile?
**Snapan Market Mobile** adalah platform marketplace dan media sosial komunitas sekolah *mobile-first* yang dirancang eksklusif untuk warga **SMKN 8 Jakarta** ("Snapan").

Aplikasi ini menggabungkan dua fungsi utama dalam satu ekosistem:
1. **Pusat Ekonomi Kreatif Siswa (Marketplace)**: Wadah jual-beli barang preloved (seragam, buku pelajaran, modul SMK, alat praktik), produk karya kejuruan (coding software, desain grafis, kerajinan), dan jajan kuliner kantin.
2. **Forum Komunikasi & Utas Sekolah (Community Feed)**: Ruang berekspresi, berbagi tips belajar, info tugas/magang/PJBL, serta diskusi antar jurusan secara terverifikasi dan aman.

```
┌─────────────────────────────────────────────────────────────┐
│                    SNAPAN MARKET MOBILE                     │
├──────────────────────────────┬──────────────────────────────┤
│      🛍️ MARKETPLACE SISWA    │   💬 FORUM & UTAS SEKOLAH    │
│  Tempat jual-beli terpercaya │  Ruang diskusi karya, tugas, │
│  antar siswa & kelas SMKN 8  │  dan info seputar sekolah    │
└──────────────────────────────┴──────────────────────────────┘
```

---

## 2. Profil Pengguna & Target Audience

| Tipe Pengguna | Peran & Kebutuhan Utama di Aplikasi |
| :--- | :--- |
| **Siswa Penjual (Seller)** | Menjual barang preloved sekolah, jasa kejuruan (coding, desain, servis), atau jajanan kelas dengan cepat tanpa biaya admin. |
| **Siswa Pembeli (Buyer)** | Mencari seragam murah, buku pelajaran bekas berkualitas, makanan kantin, atau jasa teman sekelas dengan sistem COD di sekolah. |
| **Siswa Kreator / Diskusi** | Berbagi karya proyek PJBL, bertanya seputar tugas kejuruan (PPLG, TJKT, DKV, dll.), dan membuat polling voting sekolah. |
| **Guru & Pembina** | Memantau kegiatan kewirausahaan siswa, membagikan pengumuman resmi sekolah, dan memberikan badge verifikasi resmi. |

---

## 3. Peta Interaksi Utama Aplikasi (User Journey Map)

```
[ Buka Aplikasi (PWA) ] ──> [ Home Feed: Eksplorasi Utas & Produk ]
                                    │
       ┌────────────────────────────┼────────────────────────────┐
       ▼                            ▼                            ▼
[ Buka Detail Produk ]     [ Buat Post / Jualan ]      [ Cari di Search Page ]
 • Baca deskripsi & stok    • Tulis caption & foto      • Tab Populer & Terbaru
 • Sticky Buy Bar (Beli)    • Toggle Mode Jualan        • Cari Profil Siswa / Toko
 • Chat langsung penjual    • Simpan / Buang Draf       • Navigasi Instan 0ms
       │                            │                            │
       └────────────────────────────┼────────────────────────────┘
                                    ▼
                      [ Interaksi Komentar & Profil ]
                       • Balas komentar bertingkat
                       • Konfirmasi hapus postingan
                       • Cek Badge Centang Biru Sekolah
```

---

## 4. Rincian Desain Interaksi per Halaman

### 4.1. Interaksi Halaman Utama (Home Feed)
Halaman Home menyajikan feed gabungan antara postingan diskusi dan produk jualan dengan layout *edge-to-edge* ala Meta Threads:

- **Ketuk Postingan (0ms Instant Navigation)**: Mengetuk area postingan langsung membuka halaman detail secara instan tanpa jeda.
- **Tombol Reaksi Love (*Micro-Pop Interaction*)**:
  - Sentuhan pertama: Icon membesar halus ($0.8 \rightarrow 1.25 \rightarrow 1.0$), warna berubah menjadi **Ruby Red**, jumlah suka bertambah $+1$, dan memicu getaran mikro taktil (*haptic*).
  - Sentuhan kedua: Membatalkan like dan kembali ke outline abu-abu netral.
- **Tombol Komentar Cepat**: Membuka halaman detail postingan dan langsung mengarahkan fokus ke bilah pengetikan komentar bawah.
- **Tombol Repost (*Emerald Glide*)**: Memunculkan menu opsi sebar ulang utas dengan transisi warna hijau zamrud (*emerald*).
- **Tombol Bagikan (*Share Action*)**: Memicu *Native Web Share API* HP pengguna untuk menyalin tautan atau membagikannya ke WhatsApp/Instagram.
- **Pull-to-Refresh**: Menarik feed ke bawah memicu spinner elastis untuk memuat data postingan terbaru.
- **Smart Scroll Navigation**: Header atas dan navigasi bawah otomatis bersembunyi saat scrolling ke bawah untuk ruang baca maksimal, dan **otomatis terbuka penuh saat kembali ke Home**.

---

### 4.2. Interaksi Marketplace & Transaksi Produk
Khusus postingan dengan tipe *Jualan Produk*:

- **Badge Harga Khas Marketplace**: Menampilkan label harga Rupiah tebal (misal: `Rp 45.000`) dan badge lokasi kelas penjual (misal: `📍 XII PPLG 1`).
- **Sticky Buy Bar Mengambang (*Floating Action Pill*)**:
  - Di bagian bawah layar detail produk, terdapat kapsul putih melayang yang menampilkan ringkasan harga, sisa stok, dan tombol **"Beli Sekarang"**.
- **Bottom Sheet Transaksi (*Buy Bottom Sheet*)**:
  - Mengetuk "Beli Sekarang" memunculkan lembar bawah (*slide-up sheet*) berisi rincian varian, jumlah stok yang ingin dibeli, estimasi total, dan tombol **"Hubungi Penjual via WhatsApp"** untuk janjian COD di area SMKN 8.
- **Tandai Markah (*Bookmark*)**: Menyimpan produk ke daftar favorit akun untuk dicek kembali nanti.

---

### 4.3. Interaksi Pembuatan Post & Jualan (Create Modal)
Diakses melalui tombol tambah `[ + ]` di menu navigasi:

- **Mode Switcher (Tab Utas vs Jualan Produk)**:
  - **Mode Utas (Diskusi)**: Fokus pada teks caption, lampiran foto carousel, GIF, dan polling suara.
  - **Mode Jualan**: Membuka input tambahan untuk Judul Barang, Harga (IDR), Jumlah Stok, dan Lokasi Kelas/Kantin.
- **Tag Topik 1-Ketuk (*Threads 3-Dot Topic Tag*)**:
  - Memilih kategori seperti `#frontend`, `#kantin`, `#preloved`, `#dkv`, `#tjkt` untuk mempermudah pencarian.
- **Sistem Pengaman Draf (*Draft & Discard Safety*)**:
  - Jika pengguna menutup modal saat tulisan belum selesai, muncul dialog **`ConfirmActionModal`**:
    - `[ Simpan ]` $\rightarrow$ Menyimpan tulisan ke memori lokal browser (*localStorage*).
    - `[ Jangan simpan ]` $\rightarrow$ Menghapus draf dan mereset form.
    - `[ Batal ]` $\rightarrow$ Menutup dialog dan melanjutkan pengetikan.

---

### 4.4. Interaksi Pencarian Multi-Dimensi (Search Page)
Pusat eksplorasi dan penemuan konten sekolah:

- **Live Keyword Filtering**: Hasil pencarian muncul secara langsung saat mengetik.
- **3 Tab Kategori Utama**:
  1. **Terpopuler**: Menampilkan postingan & produk dengan jumlah interaksi terbanyak yang cocok dengan kata kunci.
  2. **Terbaru**: Menampilkan postingan terkini berdasarkan urutan waktu.
  3. **Profil**: Menampilkan daftar akun siswa dan toko jurusan yang relevan.
- **Preservasi Navigasi (*Zero State Loss*)**:
  - Membuka postingan dari hasil pencarian lalu menekan tombol Kembali **tidak akan menghapus kata kunci pencarian** (pengguna tetap berada di halaman hasil pencarian yang sama).
- **Tombol Kembali Pintar `[ ← ]`**:
  - Jika sedang di hasil pencarian: Menekan `[ ← ]` mereset kata kunci dan kembali ke mode awal *Discovery*.
  - Jika di mode awal: Menekan `[ ← ]` kembali ke Home.

---

### 4.5. Interaksi Kolom Komentar & Diskusi Bertingkat
- **Komentar Bersarang (*Nested Reply Tree*)**: Balasan komentar memiliki garis alur vertikal tipis yang menghubungkan percakapan antar siswa.
- **Floating Comment Capsule Bar**:
  - Bilah pengetikan komentar selalu melayang elegan di dasar layar, otomatis naik ke atas virtual keyboard saat mengetik tanpa menutupi isi obrolan.
- **Balas Spesifik (@Mention Trigger)**:
  - Menekan tombol "Balas" di bawah komentar teman akan memunculkan banner balasan aktif `Membalas @username` dengan tombol `[ Batal ]`.
- **Sub-Thread Detail Modal**:
  - Mengetuk "Lihat balasan lainnya" membuka halaman fokus khusus untuk percakapan tersebut.

---

### 4.6. Interaksi Profil & Pengaturan Akun
- **Header Profil Personal**: Menampilkan foto profil, username, nama lengkap, badge kejuruan (misal: *XII PPLG 1*), dan bio keahlian.
- **Official Verified Badge (Centang Biru)**: Mengetuk centang biru memunculkan modal verifikasi resmi sekolah SMKN 8 Jakarta.
- **Edit Profil dengan Deteksi Perubahan**:
  - Mengubah avatar, bio, kelas, atau tautan Instagram.
  - Jika keluar tanpa menyimpan, muncul **`ConfirmActionModal`** (*"Buang perubahan?"* $\rightarrow$ Buang / Batal).
- **Pengaturan & Logout Aman**:
  - Menekan "Keluar dari Akun" memunculkan dialog konfirmasi pengaman bertingkat.

---

## 5. Standar Micro-Interactions & Sentuhan Taktil (Haptics & Motion)

Aplikasi Snapan Market Mobile dirancang dengan standar kenyamanan interaksi tertinggi:

```
┌─────────────────────────────────────────────────────────────┐
│                 STANDAR SENTUHAN & GERAK                    │
├─────────────────────────────────────────────────────────────┤
│ • Zero Touch Delay (0ms Latency pada sentuhan layar HP)     │
│ • Active Touch Scale (active:scale-[0.98] seketika)         │
│ • Taptic Haptic Feedback (Getaran mikro via navigator.vibrate│
│ • 120 FPS GPU Composite (Animasi transform & opacity only)  │
│ • In-Memory DOM Stacking (Feed tidak pernah reload)         │
└─────────────────────────────────────────────────────────────┘
```

1. **Sentuhan Taktil Aktif (`active:scale-[0.98]`)**:
   - Setiap elemen yang bisa diklik memberikan respons visual mengecil halus seketika saat jari menyentuh layar (*Touch Down*).
2. **Sensasi Getaran Hardware (*Haptic Engine*)**:
   - Getaran ringan ($10\text{ms}$) aktif saat: Menyukai postingan, menandai markah, memilih tab, dan membuka modal.
3. **Motion Restraint (Kekangan Gerak)**:
   - Tidak ada animasi berlebihan yang membuat pusing. Perpindahan halaman dilakukan secara instan (*Instant Snappy*) agar fokus pada konten.

---

## 6. Teknologi & Arsitektur Pendukung

- **Frontend**: `React 18` + `TypeScript` + `Tailwind CSS v4` + `Framer Motion`.
- **PWA & Caching**: `vite-plugin-pwa` + `Workbox` (Mendukung pemasangan icon di Home Screen HP & akses offline).
- **Backend & Database**: `Supabase PostgreSQL` dengan proteksi data *Row Level Security (RLS)*.
- **State Management**: `Zustand` untuk performa tinggi tanpa lag.

---

> **Snapan Market Mobile — Menghubungkan Kreativitas, Transaksi, dan Komunitas Siswa SMKN 8 Jakarta.**
