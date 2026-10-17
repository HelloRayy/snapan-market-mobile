# 08. PHYSICAL DATA MODEL (PDM)

**Dokumen**: Bab III - Bagian 3.7.2  
**Proyek**: Snapan Market Mobile (sNaps) - SMKN 8 Semarang  
**Target DBMS**: PostgreSQL 15+ (Supabase BaaS) & Kompatibilitas Relasional SQL  

---

## 1. Definisi & Konsep PDM
Physical Data Model (PDM) merupakan spesifikasi teknis implementasi database fisik pada media penyimpanan komputer. PDM memetakan entitas konseptual ke dalam tabel nyata, mendefinisikan tipe data kolom secara presisi, mengalokasikan *Primary Key* (PK), *Foreign Key* (FK), nilai *Default*, serta *Check Constraints*.

---

## 2. Diagram Struktur Fisik Tabel (PDM)

```mermaid
erDiagram
    student_registry {
        TEXT nis PK "Primary Key (Nomor Induk Siswa)"
        TEXT full_name "NOT NULL - Nama Siswa"
        TEXT class_group "NOT NULL - Kelas (contoh: XII PPLG 1)"
        TEXT major "NOT NULL - Jurusan (PPLG/DKV/Kuliner)"
        BOOLEAN is_active "DEFAULT true - Status Aktif Siswa"
    }

    profiles {
        UUID id PK "Primary Key (Terkoneksi ke auth.users)"
        TEXT nis FK "UNIQUE, NOT NULL - FK ke student_registry.nis"
        TEXT username "UNIQUE, NOT NULL - Username Siswa"
        TEXT full_name "NOT NULL - Nama Profil Tampilan"
        TEXT avatar_url "NULLABLE - Link File Storage Foto"
        TEXT role "NOT NULL, DEFAULT 'user' - CHECK (role IN ('user', 'admin'))"
        TEXT class_group "NOT NULL - Kelas Siswa"
        TEXT bio "NULLABLE - Biografi Profil"
        TIMESTAMPTZ created_at "DEFAULT NOW() - Waktu Akun Dibuat"
    }

    market_posts {
        UUID id PK "Primary Key"
        UUID seller_id FK "NOT NULL - FK ke profiles.id"
        TEXT title "NOT NULL - Judul Produk/Karya"
        TEXT description "NOT NULL - Deskripsi Rinci"
        INT price "NOT NULL, DEFAULT 0 - Harga (Rupiah)"
        INT stock "NOT NULL, DEFAULT 1 - Stok Barang"
        TEXT type "NOT NULL - CHECK (type IN ('thread', 'product'))"
        TEXT category "NOT NULL - PPLG, DKV, Kuliner, Umum"
        JSONB image_urls "DEFAULT '[]'::jsonb - Galeri Foto"
        INT view_count "DEFAULT 0 - Total Dilihat"
        TIMESTAMPTZ created_at "DEFAULT NOW() - Waktu Dibuat"
    }

    school_meeting_points {
        UUID id PK "Primary Key"
        TEXT name "NOT NULL - Nama Spot (cth: Gazebo PPLG)"
        TEXT code "UNIQUE, NOT NULL - Kode Spot (cth: GZB-01)"
        TEXT area_zone "NOT NULL - Zona Kampus Sekolah"
        TEXT description "NOT NULL - Landmark Petunjuk"
        TEXT photo_url "NULLABLE - Foto Real Spot"
        BOOLEAN is_active "DEFAULT true - Status Titik Aktif"
    }

    orders {
        UUID id PK "Primary Key"
        UUID buyer_id FK "NOT NULL - FK ke profiles.id"
        UUID seller_id FK "NOT NULL - FK ke profiles.id"
        UUID post_id FK "NOT NULL - FK ke market_posts.id"
        UUID meeting_point_id FK "NOT NULL - FK ke school_meeting_points.id"
        INT total_price "NOT NULL - Nilai Transaksi COD"
        TEXT buyer_note "NOT NULL - Catatan Jam COD Pembeli"
        TEXT status "NOT NULL, DEFAULT 'pending' - CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled'))"
        TIMESTAMPTZ created_at "DEFAULT NOW() - Waktu Pesan"
        TIMESTAMPTZ completed_at "NULLABLE - Waktu Selesai Fisik"
    }

    conversations {
        UUID id PK "Primary Key"
        UUID buyer_id FK "NOT NULL - FK ke profiles.id"
        UUID seller_id FK "NOT NULL - FK ke profiles.id"
        UUID post_id FK "NULLABLE - FK ke market_posts.id"
        TIMESTAMPTZ created_at "DEFAULT NOW() - Waktu Dibuat"
    }

    direct_messages {
        UUID id PK "Primary Key"
        UUID conversation_id FK "NOT NULL - FK ke conversations.id"
        UUID sender_id FK "NOT NULL - FK ke profiles.id"
        TEXT content "NOT NULL - Teks Pesan"
        BOOLEAN is_read "DEFAULT false - Status Terbaca"
        TIMESTAMPTZ created_at "DEFAULT NOW() - Waktu Kirim"
    }

    content_reports {
        UUID id PK "Primary Key"
        UUID reporter_id FK "NOT NULL - FK ke profiles.id"
        UUID target_post_id FK "NOT NULL - FK ke market_posts.id"
        TEXT reason "NOT NULL - Alasan Laporan Siswa"
        TEXT status "NOT NULL, DEFAULT 'pending' - CHECK (status IN ('pending', 'reviewed', 'dismissed', 'taken_down'))"
        TIMESTAMPTZ created_at "DEFAULT NOW() - Waktu Laporan"
    }

    student_registry ||--o| profiles : "nis"
    profiles ||--o{ market_posts : "seller_id"
    profiles ||--o{ orders : "buyer_id"
    profiles ||--o{ orders : "seller_id"
    market_posts ||--o{ orders : "post_id"
    school_meeting_points ||--o{ orders : "meeting_point_id"
    profiles ||--o{ conversations : "buyer_id"
    profiles ||--o{ conversations : "seller_id"
    conversations ||--o{ direct_messages : "conversation_id"
    profiles ||--o{ content_reports : "reporter_id"
    market_posts ||--o{ content_reports : "target_post_id"
```

---

## 3. Matriks Padanan Tipe Data Fisik (PostgreSQL vs MySQL)

Untuk memenuhi kebutuhan kurikulum sekolah yang sering menstandarisasi sintaks basis data relasional ke MySQL, berikut tabel padanan implementasinya:

| Kolom Teknis | Implementasi Nyata (PostgreSQL Supabase) | Alternatif Padanan (MySQL 8.0+) | Keterangan Batasan Integritas |
|---|---|---|---|
| Kunci Unik ID | `UUID DEFAULT gen_random_uuid()` | `VARCHAR(36)` / `CHAR(36)` | Menggunakan UUID v4 untuk mencegah nomor ID mudah ditebak (*anti-ID enumeration*). |
| Nomor Induk Siswa | `TEXT` | `VARCHAR(20)` | Terikat constraint unik pada tabel registry siswa. |
| Kuantitas Stok | `INT CHECK (stock >= 0)` | `INT CHECK (stock >= 0)` | Mencegah nilai kuantitas negatif di database. |
| Status Pesanan | `TEXT CHECK (status IN (...))` | `ENUM('pending','confirmed','completed','cancelled')` | Membatasi status state machine pesanan secara ketat. |
| Gambar Galeri | `JSONB DEFAULT '[]'::jsonb` | `JSON` | Menyimpan array URL foto multi-slide produk. |
| Waktu Transaksi | `TIMESTAMPTZ DEFAULT NOW()` | `DATETIME DEFAULT CURRENT_TIMESTAMP` | Menyimpan timestamp presisi zona waktu Indonesia Barat (+07:00). |
