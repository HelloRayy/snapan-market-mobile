# 05. DATA FLOW DIAGRAM (DFD LEVEL 0 & LEVEL 1)

**Dokumen**: Bab III - Bagian 3.4  
**Proyek**: Snapan Market Mobile (sNaps) - SMKN 8 Semarang  
**Fokus**: Dekomposisi Fungsional Aliran Data Logis dan Interaksi Datastore  

---

## 1. Definisi Data Flow Diagram
Data Flow Diagram (DFD) memodelkan sistem dari sudut pandang pemrosesan data: bagaimana data masuk, ditransformasikan oleh proses komputasi, disimpan ke dalam *datastore*, dan dikeluarkan kembali ke entitas tujuan.

---

## 2. DFD Level 0 (Overview Sistem sNaps)

DFD Level 0 memecah *Proses 0.0* menjadi 5 sub-proses inti:

```mermaid
flowchart TD
    %% Entitas
    Siswa["👤 SISWA"]
    Admin["🛡️ ADMIN SEKOLAH"]

    %% Sub-Proses
    P1(("1.0<br/>Autentikasi &<br/>Device Binding"))
    P2(("2.0<br/>Feed Komunitas &<br/>Diskusi Vokasi"))
    P3(("3.0<br/>Manajemen Produk &<br/>Katalog Karya"))
    P4(("4.0<br/>Transaksi COD &<br/>Titik Temu"))
    P5(("5.0<br/>Moderasi Konten &<br/>Registry Siswa"))

    %% Datastores
    D1[("D1: student_registry")]
    D2[("D2: profiles")]
    D3[("D3: market_posts")]
    D4[("D4: school_meeting_points")]
    D5[("D5: orders")]
    D6[("D6: content_reports")]

    %% Aliran Proses 1.0 (Autentikasi)
    Siswa -->|NIS & Password| P1
    D1 -->|Data Validasi Siswa Aktif| P1
    P1 -->|Insert/Update Data Akun| D2
    P1 -->|Token Sesi & Info Profil| Siswa

    %% Aliran Proses 2.0 (Feed & Diskusi)
    Siswa -->|Input Thread, Polling, Komentar| P2
    P2 -->|Simpan Konten Interaksi| D3
    D3 -->|Ambil Data Timeline Terkini| P2
    P2 -->|Feed Interaktif Warga Sekolah| Siswa

    %% Aliran Proses 3.0 (Katalog Karya)
    Siswa -->|Unggah Karya Vokasi/Preloved| P3
    P3 -->|Simpan Info Produk & Stok| D3
    D3 -->|Ambil Data Katalog Jurusan| P3
    P3 -->|Tampilkan Etalase Produk| Siswa

    %% Aliran Proses 4.0 (Transaksi COD)
    Siswa -->|Pilih Produk & Titik Temu COD| P4
    D4 -->|Data Spot Resmi (Gazebo/Kantin/Lab)| P4
    P4 -->|Validasi Ketersediaan Stok| D3
    P4 -->|Simpan Record Pesanan (PENDING)| D5
    P4 -->|Kurangi Kuantitas Stok| D3
    D5 -->|Ambil Status & Riwayat Order| P4
    P4 -->|Notifikasi Pesanan & Kode COD| Siswa

    %% Aliran Proses 5.0 (Moderasi & Registry)
    Siswa -->|Aduan Pelanggaran Konten| P5
    P5 -->|Simpan Laporan| D6
    Admin -->|Import CSV Master Siswa| P5
    P5 -->|Perbarui Data Buku Induk| D1
    Admin -->|Kelola Titik Kumpul COD| P5
    P5 -->|Update Data Spot Sekolah| D4
    D6 -->|Daftar Aduan Konten Siswa| P5
    P5 -->|Eksekusi Banned / Take Down| Admin
```

---

## 3. DFD Level 1 (Fokus: Proses 4.0 Transaksi COD & Titik Temu)

Untuk memahami mekanisme pencegahan *overselling* dan kepastian lokasi fisik di SMKN 8 Semarang, proses 4.0 didekomposisi lebih lanjut:

```mermaid
flowchart TD
    Pembeli["👤 Siswa Pembeli"]
    Penjual["👤 Siswa Penjual"]

    P41(("4.1<br/>Pengecekan &<br/>Kunci Stok"))
    P42(("4.2<br/>Pemilihan &<br/>Denah Titik Temu"))
    P43(("4.3<br/>Penerbitan Order &<br/>Broadcast Realtime"))
    P44(("4.4<br/>Verifikasi Fisik &<br/>Penyelesaian Pesanan"))

    D3[("D3: market_posts")]
    D4[("D4: school_meeting_points")]
    D5[("D5: orders")]

    %% 4.1
    Pembeli -->|Pilih Item & Jumlah Beli| P41
    D3 -->|Cek Sisa Stok Saat Ini| P41
    P41 -->|Stok Tersedia Valid| P42
    P41 -.->|Stok Habis: Batalkan| Pembeli

    %% 4.2
    D4 -->|Daftar Titik Temu Aktif Sekolah| P42
    Pembeli -->|Pilih Spot Kumpul & Catatan Jam| P42
    P42 -->|Payload Checkout Lengkap| P43

    %% 4.3
    P43 -->|Simpan Order Baru (Status: PENDING)| D5
    P43 -->|Potong Sisa Stok Barang| D3
    P43 -->|Push Notification Order Masuk| Penjual
    P43 -->|Tanda Terima Digital & QR Code| Pembeli

    %% 4.4
    Pembeli -->|Konfirmasi Terima Fisik di Spot COD| P44
    Penjual -->|Konfirmasi Uang Tunai Diterima| P44
    P44 -->|Update Status Pesanan: COMPLETED| D5
```

---

## 4. Matriks Hubungan Sub-Proses dengan Datastore

| Sub-Proses | Datastore Terlibat | Mode Akses | Keterangan Fungsional |
|---|---|---|---|
| **1.0 Autentikasi** | `student_registry`, `profiles` | Read, Write | Memvalidasi NIS terdaftar dan mencatat perangkat resmi siswa. |
| **2.0 Feed Komunitas** | `market_posts`, `profiles` | Read, Write | Menyimpan thread diskusi dan interaksi sosial. |
| **3.0 Manajemen Produk** | `market_posts` | Read, Write | Menangani CRUD etalase karya siswa dan kuantitas stok. |
| **4.0 Transaksi COD** | `orders`, `market_posts`, `school_meeting_points` | Read, Write | Menjalankan transaksi pemesanan aman dan pemotongan stok. |
| **5.0 Moderasi & Admin** | `content_reports`, `student_registry`, `school_meeting_points` | Read, Write | Menjaga kepatuhan aturan sekolah dan data induk siswa. |
