# 📱 DOKUMEN PRESENTASI APLIKASI: SNAPAN MARKET MOBILE
> **Panduan Penjelasan Aplikasi untuk Guru & Mentor**  
> *Fokus pada Konsep Dasar Aplikasi, Fitur Utama, Standar Desain UX, dan Arsitektur Teknis.*

---

## 📌 DAFTAR ISI
1. [Konsep Dasar & Latar Belakang Aplikasi](#1-konsep-dasar--latar-belakang-aplikasi)
2. [Fitur-Fitur Utama Snapan Market Mobile](#2-fitur-fitur-utama-snapan-market-mobile)
3. [Standar Desain & UX (Instant Snappy & Clean Aesthetic)](#3-standar-desain--ux-instant-snappy--clean-aesthetic)
4. [Arsitektur Teknis & Tech Stack](#4-arsitektur-teknis--tech-stack)

---

## 1. Konsep Dasar & Latar Belakang Aplikasi

### 💡 Apa Itu Snapan Market Mobile?
**Snapan Market Mobile** adalah platform marketplace dan forum komunitas digital *mobile-first* yang dikembangkan khusus untuk ekosistem siswa, guru, dan warga sekolah **SMKN 8 Jakarta**.

### ⚠️ Masalah Nyata yang Diselesaikan:
1. **Pusat Promosi Terpadu Siswa**: Menggantikan promosi jual-beli barang preloved (seragam, buku, alat praktik), karya kejuruan (desain, coding, kerajinan), dan kuliner kantin yang sebelumnya hanya tersebar di status WhatsApp/Instagram Story yang hilang dalam 24 jam.
2. **Platform Komunitas Interaktif**: Menyediakan ruang diskusi sekolah yang sehat, informatif, dan aman dengan identitas siswa yang terverifikasi.
3. **Akses Cepat & Ringan**: Aplikasi dirancang sangat ringan ($< 3.5\text{ MB}$) sehingga tidak membebani memori penyimpanan HP siswa.

---

## 2. Fitur-Fitur Utama Snapan Market Mobile

```
┌─────────────────────────────────────────────────────────────┐
│                 FITUR UTAMA SNAPAN MARKET                   │
├──────────────────────────────┬──────────────────────────────┤
│      🛍️ MARKETPLACE SISWA    │   💬 FORUM & UTAS (THREADS)  │
│ • Jual-beli produk & jasa    │ • Posting teks, foto, polling│
│ • Sticky Buy Bar melayang    │ • Komentar bertingkat        │
│ • Rincian stok & chat instan │ • Reaksi Love, Repost, Share │
├──────────────────────────────┼──────────────────────────────┤
│      🔍 SEARCH ENGINE MULTI  │   🛡️ KEAMANAN & VERIFIKASI   │
│ • Tab: Terpopuler, Terbaru   │ • Login terintegrasi akun    │
│ • Pencarian profil & topik   │ • Badge Centang Biru Resmi   │
│ • Hasil bersih tanpa noise   │ • Modal konfirmasi pengaman  │
└──────────────────────────────┴──────────────────────────────┘
```

1. **🛍️ Marketplace Produk & Jasa Siswa**:
   - Menampilkan barang dagangan siswa lengkap dengan foto resolusi optimal, deskripsi, harga, lokasi kelas, dan ketersediaan stok.
   - Bilah pembelian mengambang (*Sticky Buy Bar*) di bagian bawah layar yang memudahkan transaksi langsung.
2. **💬 Forum Komunitas & Utas Diskusi (*Thread Feed*)**:
   - Memungkinkan siswa membuat utas diskusi dengan teks berformat (*hashtag*, *mentions*), multi-gambar carousel, dan voting polling.
   - Kolom komentar bersarang (*nested replies*) dengan dok pengetikan mengambang (*floating capsule bar*).
3. **🔍 Sistem Pencarian Cepat (*Instant Multi-Tab Search*)**:
   - Pencarian cerdas dengan 3 tab: **Terpopuler**, **Terbaru**, dan **Profil Siswa/Toko**.
   - Penanda akhir pencarian minimalis yang rapi dan akurat terhadap kata kunci.
4. **🛡️ Modal Konfirmasi Standar Industri (*ConfirmActionModal*)**:
   - Dialog konfirmasi aksi kritis (Simpan Draf, Buang Perubahan, Hapus Postingan, dan Logout Akun) untuk mencegah kesalahan klik pengguna.
5. **🏷️ Profil & Verifikasi Siswa SMKN 8**:
   - Halaman profil lengkap dengan tab Postingan, Balasan, dan Produk Jualan.
   - Badge Centang Biru (*Verified Badge*) resmi untuk siswa dan guru aktif sekolah.

---

## 3. Standar Desain & UX (Instant Snappy & Clean Aesthetic)

Aplikasi Snapan Market Mobile mengadopsi standar desain modern kelas industri (ala **Meta Threads & X**) yang mengutamakan kecepatan dan kenyamanan membaca:

```
[ Sentuhan Jari ] ──( 0ms Delay )──> [ Feedback Mikro: active:scale-98 ] ──> [ Konten Langsung Terbuka ]
```

### 🎯 Prinsip Desain yang Diterapkan:
1. **Kecepatan Instan (*0ms Instant Response*)**:
   - Navigasi halaman dan pembukaan detail produk berjalan secara instan tanpa animasi zoom layar penuh yang memperlambat pengguna.
2. **Performa Halus 120 FPS (*Composite-Only GPU*)**:
   - Seluruh pergerakan komponen (modal dialog, bottom sheet, header dock) hanya menggunakan properti `transform` dan `opacity` yang diproses kartu grafis (**GPU**), menjamin pergerakan tetap mulus tanpa lag.
3. **Preservasi Memori (*In-Memory DOM Stacking*)**:
   - Halaman Home Feed dan Search Page dipertahankan di memori. Saat pengguna kembali dari melihat detail barang/postingan, posisi scroll tidak pernah hilang dan tidak perlu loading ulang.
4. **Feedback Taktil (*Touch & Haptics*)**:
   - Tombol memberikan respons visual seketika saat ditekan (`active:scale-[0.98]`) dilengkapi getaran mikro halus (*haptic feedback*).

---

## 4. Arsitektur Teknis & Tech Stack

```
┌─────────────────────────────────────────────────────────────┐
│                      FRONTEND LAYER                         │
│  React 18 + Vite + Tailwind CSS v4 + Framer Motion + Zustand│
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                   BACKEND & DATABASE LAYER                  │
│       Supabase (PostgreSQL Database + Auth + Storage)       │
│          Dilindungi Row Level Security (RLS) Policies       │
└─────────────────────────────────────────────────────────────┘
```

- **Frontend Framework**: `React 18` + `TypeScript` (Menjamin kode bersih, terstruktur, dan *Strict Type Safe*).
- **Build Tool**: `Vite` (Proses bundling modern super cepat $< 3.5$ detik).
- **Styling**: `Tailwind CSS v4` (Desain responsif *mobile-first* dengan utilitas CSS modern).
- **State Management**: `Zustand` (Manajemen state aplikasi yang sangat ringan dan efisien).
- **Database & Autentikasi**: `Supabase PostgreSQL` (Database relasional aman dengan enkripsi dan aturan keamanan *Row Level Security*).

---

> **Snapan Market Mobile — Platform Marketplace & Komunitas Siswa SMKN 8 Jakarta.**
