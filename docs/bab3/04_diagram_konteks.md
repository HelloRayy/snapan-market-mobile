# 04. DIAGRAM KONTEKS (CONTEXT DIAGRAM)

**Dokumen**: Bab III - Bagian 3.3  
**Proyek**: Snapan Market Mobile (sNaps) - SMKN 8 Semarang  
**Fokus**: Pemodelan Tingkat Tertinggi Batasan Sistem dan Entitas Eksternal  

---

## 1. Definisi & Fungsi Diagram Konteks
Diagram Konteks (sering disebut sebagai DFD Level 0 Global) merupakan representasi model proses tingkat tertinggi yang mengisolasi sistem perangkat lunak secara keseluruhan sebagai satu lingkaran proses tunggal (*Proses 0.0*) dan memetakan interaksi aliran data dua arah dengan entitas lingkungan luar (*External Entities / Terminators*).

---

## 2. Diagram Konteks Sistem sNaps

```mermaid
flowchart LR
    subgraph ExternalEntity1["Entitas Eksternal 1"]
        Siswa["👤 SISWA (Warga SMKN 8 Semarang)<br/>- Berperan sebagai Pembeli & Penjual C2C -"]
    end

    subgraph CoreSystem["Lingkup Sistem Utama"]
        App(("0.0<br/>SISTEM APLIKASI<br/>SNAPAN MARKET MOBILE<br/>(sNAPS)"))
    end

    subgraph ExternalEntity2["Entitas Eksternal 2"]
        Admin["🛡️ ADMIN SEKOLAH<br/>- Guru Pembina & Tim IT Sekolah -"]
    end

    %% ALIRAN DATA SISWA -> SISTEM
    Siswa -->|1. Kredensial Login NIS & Registrasi Perangkat| App
    Siswa -->|2. Data Postingan Thread & Produk Vokasi| App
    Siswa -->|3. Data Pesanan COD & Pilihan Titik Temu| App
    Siswa -->|4. Pesan Obrolan Direct Message| App
    Siswa -->|5. Laporan Pengaduan Konten Melanggar| App

    %% ALIRAN DATA SISTEM -> SISWA
    App -->|a. Akses Timeline Beranda & Info Profil| Siswa
    App -->|b. Informasi Katalog Karya & Sisa Stok Realtime| Siswa
    App -->|c. Push Notifikasi Pesanan Masuk & Janji COD| Siswa
    App -->|d. Pesan Obrolan Masuk Realtime| Siswa
    App -->|e. Bukti Pesanan Digital & QR Transaksi| Siswa

    %% ALIRAN DATA ADMIN -> SISTEM
    Admin -->|1. Master Registry Data Siswa (NIS, Nama, Kelas)| App
    Admin -->|2. Master Titik Temu Resmi COD (Gazebo/Kantin/Lab)| App
    Admin -->|3. Kebijakan Moderasi Konten & Suspend Akun| App

    %% ALIRAN DATA SISTEM -> ADMIN
    App -->|a. Notifikasi Laporan Konten Bermasalah| Admin
    App -->|b. Audit Log Keamanan & Perangkat Siswa| Admin
    App -->|c. Laporan Rekapitulasi Aktivitas Pasar Sekolah| Admin
```

---

## 3. Identifikasi Entitas Eksternal

### 3.1 Entitas Siswa
- **Karakteristik**: Pengguna tangan pertama di lapangan (Siswa aktif SMKN 8 Semarang). Beroperasi dalam model *Consumer-to-Consumer* (C2C). Setiap siswa memiliki akun terpadu yang dapat membeli produk karya teman dan sekaligus mengunggah produk atau artikelnya sendiri.
- **Tanggung Jawab Data Masuk**: Memasukkan data identitas NIS, mengunggah media gambar produk, memilih titik temu sekolah, serta melakukan konfirmasi penyelesaian transaksi fisik.

### 3.2 Entitas Admin Sekolah
- **Karakteristik**: Pihak pengelola dari institusi sekolah (Wakil Kepala Sekolah Bidang Kesiswaan / Tim IT PPLG).
- **Tanggung Jawab Data Masuk**: Mengunggah master data NIS siswa aktif dari buku induk sekolah guna memastikan tidak ada pihak asing yang menyusup ke aplikasi, mengonfigurasi titik kumpul aman di lingkungan sekolah, dan meninjau postingan yang dilaporkan siswa.

---

## 4. Tabel Rincian Aliran Data Masuk & Keluar

| ID Aliran | Nama Aliran Data | Arah Aliran | Elemen Atribut Data |
|---|---|---|---|
| **IN-01** | Kredensial Login NIS | Siswa ➔ Sistem | `nis`, `password`, `device_id`, `device_model` |
| **IN-02** | Data Produk Vokasi | Siswa ➔ Sistem | `seller_id`, `title`, `description`, `price`, `stock`, `category`, `image_urls` |
| **IN-03** | Data Pesanan COD | Siswa ➔ Sistem | `buyer_id`, `post_id`, `meeting_point_id`, `buyer_note` |
| **IN-04** | Master Registry Siswa | Admin ➔ Sistem | `nis`, `full_name`, `class_group`, `major`, `is_active` |
| **IN-05** | Master Titik Temu COD | Admin ➔ Sistem | `code`, `name`, `area_zone`, `description`, `photo_url` |
| **OUT-01** | Notifikasi Pesanan COD | Sistem ➔ Siswa | `order_id`, `product_title`, `buyer_name`, `meeting_point_name`, `buyer_note` |
| **OUT-02** | Laporan Konten Siswa | Sistem ➔ Admin | `report_id`, `reporter_nis`, `post_id`, `reason`, `timestamp` |
