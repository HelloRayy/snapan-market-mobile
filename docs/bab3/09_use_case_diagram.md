# 09. USE CASE DIAGRAM & SKENARIO SISTEM

**Dokumen**: Bab III - Bagian 3.5  
**Proyek**: Snapan Market Mobile (sNaps) - SMKN 8 Semarang  
**Fokus**: Pemodelan Fungsionalitas Sistem Berdasarkan Peran Aktor  

---

## 1. Definisi & Batasan Sistem
Use Case Diagram mendefinisikan interaksi fungsional antara aktor eksternal (**Siswa** dan **Admin Sekolah**) dengan kasus-kasus penggunaan (*use cases*) yang disediakan di dalam batasan sistem (*system boundary*) sNaps. Diagram ini juga mengilustrasikan dependensi berupa relasi `<<include>>` (proses mutlak yang wajib dipanggil) dan `<<extend>>` (proses bersyarat opsional).

---

## 2. Use Case Diagram sNaps

```mermaid
flowchart LR
    %% Aktor
    Siswa["👤 SISWA (Warga SMKN 8)"]
    Admin["🛡️ ADMIN SEKOLAH"]

    subgraph sNapsBoundary["System Boundary: Snapan Market Mobile (sNaps)"]
        %% Use Case Siswa
        UC1(["UC-01: Registrasi & Login NIS"])
        UC1_INC(["UC-01.1: Validasi Buku Induk Registry"])
        UC2(["UC-02: Kelola Profil & Avatar"])
        UC3(["UC-03: Publikasi Thread Komunitas"])
        UC3_EXT(["UC-03.1: Tambahkan Polling Interaktif"])
        UC4(["UC-04: Interaksi Feed (Like & Komentar)"])
        UC5(["UC-05: Publikasi Produk Vokasi & Preloved"])
        UC6(["UC-06: Jelajah Katalog & Filter Jurusan"])
        UC7(["UC-07: Checkout Pesanan COD"])
        UC7_INC1(["UC-07.1: Validasi Kuantitas Stok"])
        UC7_INC2(["UC-07.2: Pilih Titik Temu Resmi Sekolah"])
        UC8(["UC-08: Direct Chat Realtime (DM)"])
        UC9(["UC-09: Laporkan Konten Melanggar"])

        %% Use Case Admin
        UC10(["UC-10: Kelola Master Registry Siswa"])
        UC11(["UC-11: Kelola Master Titik Temu COD"])
        UC12(["UC-12: Tinjau & Moderasi Konten"])
        UC13(["UC-13: Monitor Audit Keamanan Perangkat"])
    end

    %% Hubungan Aktor Siswa
    Siswa --> UC1
    Siswa --> UC2
    Siswa --> UC3
    Siswa --> UC4
    Siswa --> UC5
    Siswa --> UC6
    Siswa --> UC7
    Siswa --> UC8
    Siswa --> UC9

    %% Relasi Include / Extend
    UC1 -.->|"<<include>>"| UC1_INC
    UC3_EXT -.->|"<<extend>>"| UC3
    UC7 -.->|"<<include>>"| UC7_INC1
    UC7 -.->|"<<include>>"| UC7_INC2

    %% Hubungan Aktor Admin
    Admin --> UC10
    Admin --> UC11
    Admin --> UC12
    Admin --> UC13
```

---

## 3. Identifikasi & Hak Akses Aktor

| Nama Aktor | Deskripsi Peran | Hak Akses Utama |
|---|---|---|
| **Siswa** | Warga belajar aktif SMKN 8 Semarang yang memiliki NIS sah. | Mengakses timeline, mengunggah karya, berbelanja karya sesama siswa, memesan COD di titik temu, mengirim chat, dan melaporkan postingan tidak pantas. |
| **Admin Sekolah** | Tim kesiswaan dan staf IT SMKN 8 Semarang. | Mengelola master data NIS, mengonfigurasi titik kumpul resmi sekolah, menindaklanjuti aduan laporan konten, serta memantau log perangkat mencurigakan. |

---

## 4. Spesifikasi Skenario Use Case Kunci

### 4.1 Skenario UC-01: Registrasi & Login NIS
- **Aktor**: Siswa
- **Tujuan**: Membuka akses aplikasi sNaps secara terverifikasi.
- **Pre-Condition**: Siswa memiliki NIS yang terdaftar di SMKN 8 Semarang.
- **Alur Utama (Main Flow)**:
  1. Siswa membuka form registrasi / login dan memasukkan NIS serta password.
  2. Sistem menjalankan `<<include>>` validasi ke `student_registry`.
  3. Jika valid, sistem mengecek batas perangkat (*device limit*).
  4. Sistem mengikat identifier perangkat (*bind device*) dan menerbitkan token sesi JWT.
  5. Siswa dialihkan ke halaman Beranda.
- **Alur Alternatif (Exception Flow)**:
  - Jika NIS tidak terdaftar di buku induk sekolah, sistem menolak autentikasi dan memunculkan notifikasi: *"NIS tidak terdaftar sebagai siswa aktif SMKN 8 Semarang."*

### 4.2 Skenario UC-07: Checkout Pesanan COD Titik Temu Sekolah
- **Aktor**: Siswa Pembeli
- **Tujuan**: Melakukan pemesanan barang karya vokasi dengan kesepakatan titik temu COD di area sekolah.
- **Pre-Condition**: Siswa login terverifikasi dan membuka halaman detail produk dengan stok $> 0$.
- **Alur Utama (Main Flow)**:
  1. Pembeli menekan tombol *"Beli Sekarang"*.
  2. Sistem membuka lembar checkout dan menjalankan `<<include>>` pemilihan titik temu resmi sekolah (`school_meeting_points`).
  3. Pembeli memilih salah satu spot (contoh: *Gazebo Depan PPLG*) dan menuliskan catatan waktu pertemuan (contoh: *Jam istirahat ke-1*).
  4. Pembeli menekan *"Konfirmasi Pesanan"*.
  5. Sistem menjalankan `<<include>>` validasi kuantitas stok atomik di database.
  6. Sistem menerbitkan pesanan baru di tabel `orders` dengan status `pending` dan memotong stok.
  7. Sistem mengirimkan push notifikasi ke penjual dan menampilkan modal sukses ke pembeli.
- **Alur Alternatif (Exception Flow)**:
  - Jika saat verifikasi akhir kuantitas stok bernilai 0 (telah dibeli siswa lain), sistem membatalkan pesanan dan menampilkan pesan: *"Mohon maaf, stok produk baru saja habis."*
