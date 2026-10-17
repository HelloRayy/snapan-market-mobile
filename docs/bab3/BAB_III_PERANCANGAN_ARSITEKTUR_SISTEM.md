# BAB III: PERANCANGAN ARSITEKTUR SISTEM

**Judul Proyek**: Pengembangan Aplikasi Snapan Market Mobile (sNaps) Berbasis Android Sebagai Platform Komunitas dan Marketplace Vokasi di Lingkungan SMKN 8 Semarang  
**Program Keahlian**: Pengembangan Perangkat Lunak dan Gim (PPLG) - SMKN 8 Semarang  

---

## 3.1 Pelaksanaan dan Hasil Riset

### 3.1.1 Pelaksanaan Riset Lapangan
Riset perancangan sistem dilaksanakan di lingkungan kampus SMKN 8 Semarang dengan melibatkan siswa dari berbagai program keahlian (PPLG, DKV, Kuliner, dan Otomotif) melalui metode wawancara mendalam (*in-depth interview*) serta observasi langsung terhadap dinamika komunikasi siswa di grup chat WhatsApp sekolah.

### 3.1.2 Hasil dan Analisis Kebutuhan
Dari pelaksanaan riset tersebut, diperoleh kesimpulan dan analisis kebutuhan sebagai berikut:
1. **Kejenuhan dan Banjir Informasi pada Grup WhatsApp**: Siswa merasa promosi karya dan penawaran barang preloved di grup kelas atau grup angkatan sangat cepat tenggelam oleh tumpukan chat lainnya sehingga tidak efisien.
2. **Kebutuhan Wadah Unjuk Karya Jurusan**: Siswa PPLG membutuhkan media untuk mendistribusikan aplikasi/game, siswa DKV membutuhkan tempat memasarkan merchandise dan portofolio, dan siswa Kuliner memerlukan media pemesanan makanan ringan siap antar saat jam istirahat sekolah.
3. **Pentingnya Keamanan Ekosistem Berbasis NIS**: Siswa menginginkan aplikasi yang tertutup khusus warga sekolah, di mana login diwajibkan menggunakan Nomor Induk Siswa (NIS) untuk mencegah akun palsu atau penipuan dari luar sekolah.
4. **Preferensi Metode Pembayaran COD di Spot Sekolah**: Siswa menghendaki transaksi tanpa biaya admin transfer bank dengan metode pembayaran tunai saat bertemu langsung (*Cash on Delivery*) di titik-titik kumpul resmi sekolah.

---

## 3.2 Diagram Flowchart Sistem

### 3.2.1 Diagram Flowchart Alur Manual (Konvensional)
Diagram berikut menggambarkan alur jual-beli antar siswa sebelum adanya sistem aplikasi sNaps:

```mermaid
flowchart TD
    Start([Mulai: Siswa Ingin Menjual Barang/Karya]) --> PostWA[Unggah Foto & Deskripsi ke Status WhatsApp/Instagram]
    PostWA --> WaitChat[Menunggu Chat Masuk dari Siswa Lain]
    WaitChat --> ChatCheck{Apakah Ada Siswa yang Membalas?}
    ChatCheck -- Tidak (Chat Tenggelam) --> Expired[Postingan Hilang 24 Jam Tanpa Penjualan] --> EndCancel([Selesai / Gagal])
    ChatCheck -- Ya --> ChatTawar[Tanya Jawab Manual via DM: Stok & Harga]
    ChatTawar --> DealCheck{Sepakat Membeli?}
    DealCheck -- Batal --> EndCancel
    DealCheck -- Sepakat --> JanjiManual[Menentukan Tempat & Waktu Janji Temu]
    JanjiManual --> RiskMiscommunication[Rawan Miskomunikasi Lokasi & Waktu / Ghosting]
    RiskMiscommunication --> MeetManual[Bertemu Fisik di Area Sekolah]
    MeetManual --> CashHandover[Pemberian Uang Tunai & Serah Terima Barang]
    CashHandover --> ManualCalc[Pencatatan Keuangan Manual di Buku Pribadi]
    ManualCalc --> EndSuccess([Selesai: Transaksi Berhasil])
```

### 3.2.2 Diagram Flowchart Alur Sistem Digital (sNaps)
Diagram berikut menggambarkan alur terotomatisasi transaksi C2C dan interaksi komunitas pada aplikasi sNaps:

```mermaid
flowchart TD
    Start([Mulai: Siswa Membuka Aplikasi sNaps]) --> AuthCheck{Sudah Login NIS?}
    AuthCheck -- Belum --> LoginNIS[Input NIS & Password -> Validasi student_registry]
    LoginNIS --> FeedScreen[Tampil Beranda: Feed Karya & Marketplace Vokasi]
    AuthCheck -- Sudah --> FeedScreen
    
    FeedScreen --> ActionChoice{Pilihan Aktivitas Siswa}
    
    %% Alur Penjual
    ActionChoice -- Buat Listing Produk --> FormProduct[Input Judul, Foto, Kategori Jurusan, Harga, Stok]
    FormProduct --> SaveDB[(Simpan ke Database PostgreSQL)]
    SaveDB --> PostPublished[Produk Tayang di Feed & Marketplace] --> EndWait([Selesai])
    
    %% Alur Pembeli
    ActionChoice -- Beli Produk --> ViewDetail[Buka Halaman Detail Produk & Profil Penjual]
    ViewDetail --> CheckStock{Stok Produk Tersedia > 0?}
    CheckStock -- Habis --> AlertEmpty[Tampilkan Notifikasi 'Stok Habis'] --> EndWait
    CheckStock -- Tersedia --> TapCheckout[Tekan Tombol 'Beli Sekarang']
    
    TapCheckout --> SelectMeetingPoint[Pilih Titik Temu COD Resmi Sekolah: Gazebo / Kantin / Lab]
    SelectMeetingPoint --> InputNotes[Tulis Catatan Pertemuan COD]
    InputNotes --> ConfirmOrder[Konfirmasi Pesanan COD]
    
    ConfirmOrder --> SystemProcess[(Sistem Mengunci Stok & Menerbitkan Record Pesanan)]
    SystemProcess --> SendPushNotif[Kirim Push Notification ke Siswa Penjual]
    SendPushNotif --> OrderSuccessModal[Tampilkan Bukti Pesanan & ID Transaksi]
    
    OrderSuccessModal --> MeetCOD[Kedua Siswa Bertemu di Spot COD Sesuai Jadwal]
    MeetCOD --> InspectItem[Pembeli Memeriksa Fisik Barang & Membayar Tunai]
    InspectItem --> ConfirmCompletion[Siswa Mengonfirmasi 'Pesanan Diterima']
    ConfirmCompletion --> AutoDeductStock[(Sistem Memperbarui Status Pesanan: COMPLETED)]
    AutoDeductStock --> Finish([Selesai: Transaksi Sukses])
```

---

## 3.3 Diagram Konteks (Context Diagram)

Diagram Konteks memposisikan sistem sNaps pada Level 0 Global dengan batasan entitas luar **Siswa** dan **Admin Sekolah**:

```mermaid
flowchart LR
    subgraph SiswaEntity["Entitas Luar: Siswa"]
        Siswa["👤 SISWA (Warga SMKN 8)"]
    end

    subgraph CoreSystem["Sistem Utama"]
        App(("0.0<br/>SISTEM APLIKASI<br/>SNAPAN MARKET MOBILE<br/>(sNAPS)"))
    end

    subgraph AdminEntity["Entitas Luar: Admin"]
        Admin["🛡️ ADMIN SEKOLAH"]
    end

    %% Siswa -> Sistem
    Siswa -->|1. Kredensial Login NIS & Registrasi Perangkat| App
    Siswa -->|2. Data Postingan Thread & Produk Vokasi| App
    Siswa -->|3. Data Pesanan COD & Pilihan Titik Temu| App
    Siswa -->|4. Pesan Chat Realtime| App
    Siswa -->|5. Laporan Pelanggaran Konten| App

    %% Sistem -> Siswa
    App -->|a. Akses Beranda & Profil Siswa| Siswa
    App -->|b. Tampilan Feed & Katalog Produk Vokasi| Siswa
    App -->|c. Notifikasi Status Pesanan & Lokasi COD| Siswa
    App -->|d. Pesan Chat Masuk Realtime| Siswa

    %% Admin -> Sistem
    Admin -->|1. Master Data Registry Siswa (NIS & Kelas)| App
    Admin -->|2. Master Titik Temu COD Sekolah| App
    Admin -->|3. Tindakan Moderasi (Banned Akun/Take Down Post)| App

    %% Sistem -> Admin
    App -->|a. Notifikasi Laporan Konten Siswa| Admin
    App -->|b. Log Keamanan & Registrasi Hardware| Admin
    App -->|c. Rekapitulasi Data Siswa & Transaksi Sekolah| Admin
```

---

## 3.4 Data Flow Diagram (DFD)

### 3.4.1 DFD Level 0
Menguraikan sistem utama menjadi lima sub-proses fungsional terintegrasi dengan tabel penyimpanan:

```mermaid
flowchart TD
    Siswa["👤 Siswa"]
    Admin["🛡️ Admin Sekolah"]

    P1(("1.0<br/>Autentikasi &<br/>Profil Siswa"))
    P2(("2.0<br/>Feed Komunitas &<br/>Diskusi Vokasi"))
    P3(("3.0<br/>Manajemen Produk &<br/>Katalog Karya"))
    P4(("4.0<br/>Transaksi COD &<br/>Titik Temu"))
    P5(("5.0<br/>Moderasi Konten &<br/>Master Registry"))

    D1[("D1: student_registry")]
    D2[("D2: profiles")]
    D3[("D3: market_posts")]
    D4[("D4: school_meeting_points")]
    D5[("D5: orders")]
    D6[("D6: content_reports")]

    Siswa -->|NIS & Password| P1
    D1 -->|Verifikasi Validitas NIS| P1
    P1 -->|Simpan Profil| D2
    P1 -->|Session Aktif| Siswa

    Siswa -->|Unggah Thread / Like / Komen| P2
    P2 -->|Simpan Interaksi| D3
    D3 -->|Ambil Data Feed| P2
    P2 -->|Timeline Beranda| Siswa

    Siswa -->|Unggah Produk Vokasi| P3
    P3 -->|Simpan Produk & Stok| D3
    D3 -->|Katalog Produk| P3
    P3 -->|Tampilkan Produk Jurusan| Siswa

    Siswa -->|Pilih Barang & Titik Temu| P4
    D4 -->|Data Titik Temu Sekolah| P4
    P4 -->|Validasi Stok & Buat Order| D5
    P4 -->|Update Stok Terkunci| D3
    D5 -->|Status Pesanan| P4
    P4 -->|Notifikasi Pesanan & Bukti COD| Siswa

    Siswa -->|Laporkan Konten| P5
    P5 -->|Simpan Laporan| D6
    Admin -->|Master Siswa (NIS/Kelas)| P5
    P5 -->|Update Registry| D1
    Admin -->|Kelola Spot COD| P5
    P5 -->|Update Titik Temu| D4
    D6 -->|Daftar Laporan| P5
    P5 -->|Hasil Moderasi| Admin
```

### 3.4.2 DFD Level 1 (Fokus: Proses 4.0 Transaksi COD)
Menguraikan rincian sub-proses transaksi pemesanan barang hingga serah terima di sekolah:

```mermaid
flowchart TD
    Pembeli["👤 Siswa Pembeli"]
    Penjual["👤 Siswa Penjual"]

    P41(("4.1<br/>Validasi Kuantitas &<br/>Ketersediaan Stok"))
    P42(("4.2<br/>Pemilihan Titik Temu<br/>Resmi Sekolah"))
    P43(("4.3<br/>Penerbitan Pesanan &<br/>Notifikasi Realtime"))
    P44(("4.4<br/>Verifikasi Fisik COD &<br/>Penyelesaian Pesanan"))

    D3[("D3: market_posts")]
    D4[("D4: school_meeting_points")]
    D5[("D5: orders")]

    Pembeli -->|Pilih Item & Kuantitas| P41
    D3 -->|Cek Kuantitas Stok| P41
    P41 -->|Stok Valid| P42

    D4 -->|Daftar Titik Temu Aktif| P42
    Pembeli -->|Pilih Titik Kumpul & Catatan Jam| P42
    P42 -->|Data Lengkap Checkout| P43

    P43 -->|Simpan Pesanan (Status: PENDING)| D5
    P43 -->|Kurangi Kuantitas Stok| D3
    P43 -->|Push Notifikasi Pesanan Baru| Penjual
    P43 -->|Ringkasan Pesanan Digital| Pembeli

    Pembeli -->|Konfirmasi Terima Barang| P44
    Penjual -->|Konfirmasi Penyerahan Fisik & Uang| P44
    P44 -->|Update Status (COMPLETED)| D5
```

---

## 3.5 Use Case Diagram

```mermaid
flowchart LR
    Siswa["👤 Siswa (Warga SMKN 8)"]
    Admin["🛡️ Admin Sekolah"]

    subgraph sNapsBoundary["Boundary Sistem sNaps"]
        UC1(["Registrasi & Login NIS"])
        UC1_INC(["Validasi Master Registry Sekolah"])
        UC2(["Kelola Profil Siswa"])
        UC3(["Publikasi Thread Komunitas"])
        UC3_EXT(["Tambahkan Polling Interaktif"])
        UC4(["Interaksi Feed (Like & Komentar)"])
        UC5(["Publikasi Produk Vokasi & Karya"])
        UC6(["Jelajah Katalog & Filter Jurusan"])
        UC7(["Checkout Pesanan COD"])
        UC7_INC1(["Validasi Kuantitas Stok"])
        UC7_INC2(["Pilih Titik Temu Resmi Sekolah"])
        UC8(["Direct Chat Realtime (DM)"])
        UC9(["Laporkan Konten Melanggar"])

        UC10(["Kelola Master Registry Siswa"])
        UC11(["Kelola Master Titik Temu COD"])
        UC12(["Tinjau & Moderasi Konten"])
        UC13(["Monitor Log Keamanan & Perangkat"])
    end

    Siswa --> UC1
    Siswa --> UC2
    Siswa --> UC3
    Siswa --> UC4
    Siswa --> UC5
    Siswa --> UC6
    Siswa --> UC7
    Siswa --> UC8
    Siswa --> UC9

    UC1 -.->|"<<include>>"| UC1_INC
    UC3_EXT -.->|"<<extend>>"| UC3
    UC7 -.->|"<<include>>"| UC7_INC1
    UC7 -.->|"<<include>>"| UC7_INC2

    Admin --> UC10
    Admin --> UC11
    Admin --> UC12
    Admin --> UC13
```

### Skenario Use Case Utama (UC-07: Checkout Pesanan COD Titik Temu)
- **Aktor Utama**: Siswa Pembeli
- **Aktor Sekunder**: Siswa Penjual, Database Server
- **Kondisi Awal (Pre-condition)**: Pembeli terautentikasi NIS dan stok produk $> 0$.
- **Kondisi Akhir (Post-condition)**: Record `orders` tercipta dengan status `pending`, stok terpotong, dan notifikasi terkirim ke penjual.
- **Alur Normal**: Pembeli memilih barang -> Memilih titik temu resmi sekolah -> Mengisi catatan waktu COD -> Menekan konfirmasi pesanan -> Sistem mengunci stok dan menerbitkan pesanan -> Penjual menerima notifikasi realtime.
- **Alur Alternatif**: Jika stok habis saat divalidasi, sistem membatalkan proses dan memunculkan dialog stok telah habis.

---

## 3.6 Activity Diagram (Checkout COD Titik Temu)

```mermaid
flowchart TD
    subgraph Pembeli["Siswa Pembeli"]
        A1([Mulai: Buka Detail Produk]) --> A2[Tekan 'Beli Sekarang']
        A2 --> A3[Pilih Titik Temu Resmi Sekolah]
        A3 --> A4[Tulis Catatan Waktu Pertemuan COD]
        A4 --> A5[Tekan 'Konfirmasi Pesanan']
        A8[Terima Konfirmasi & Modal Sukses] --> A9[Temui Penjual di Spot COD Sesuai Jadwal]
        A9 --> A10[Periksa Fisik Barang & Serahkan Uang Tunai]
        A10 --> A11[Tekan 'Konfirmasi Pesanan Selesai' di Aplikasi]
    end

    subgraph Sistem["Sistem sNaps"]
        A5 --> S1{Cek Ketersediaan Stok}
        S1 -- Habis <= 0 --> S2[Tampilkan Notifikasi 'Stok Habis' & Batalkan]
        S2 --> S_End([Batal / Selesai])
        S1 -- Tersedia > 0 --> S3[Simpan Pesanan ke Tabel orders: Status PENDING]
        S3 --> S4[Kunci Stok & Kurangi Kuantitas Produk]
        S4 --> S5[Kirim Push Notifikasi Realtime ke Penjual]
        S5 --> A8
        A11 --> S6[Update Status Pesanan: COMPLETED]
        S6 --> S7[Catat Riwayat Transaksi Berhasil]
        S7 --> S_Final([Selesai: Transaksi Berhasil])
    end

    subgraph Penjual["Siswa Penjual"]
        S5 -.-> P1[Terima Notifikasi Pesanan Masuk]
        P1 --> P2[Tinjau Titik Temu & Catatan Pembeli]
        P2 --> P3[Bawa Produk ke Titik Temu yang Dipilih]
        P3 --> A9
        A10 --> P4[Terima Uang Tunai & Serahkan Barang]
    end
```

---

## 3.7 Perancangan Basis Data (ERD, CDM, PDM)

### 3.7.1 Conceptual Data Model (CDM)
Struktur konseptual data logis mendefinisikan hubungan bisnis antara entitas utama:
- `student_registry`: Master buku induk sekolah (NIS, Nama, Kelas, Jurusan).
- `profiles`: Akun aktif pengguna aplikasi sNaps.
- `market_posts`: Listing produk wirausaha dan thread forum diskusi.
- `school_meeting_points`: Daftar lokasi titik temu fisik di sekolah.
- `orders`: Data pesanan COD antar siswa.
- `conversations` & `direct_messages`: Data obrolan privat antar pengguna.
- `content_reports`: Data pelaporan konten melanggar etika sekolah.

### 3.7.2 Physical Data Model (PDM)
Struktur fisik tabel diimplementasikan pada database PostgreSQL (Supabase):

```mermaid
erDiagram
    student_registry {
        TEXT nis PK
        TEXT full_name
        TEXT class_group
        TEXT major
        BOOLEAN is_active
    }

    profiles {
        UUID id PK
        TEXT nis FK
        TEXT username
        TEXT full_name
        TEXT avatar_url
        TEXT role
        TEXT class_group
        TEXT bio
        TIMESTAMPTZ created_at
    }

    market_posts {
        UUID id PK
        UUID seller_id FK
        TEXT title
        TEXT description
        INT price
        INT stock
        TEXT type
        TEXT category
        JSONB image_urls
        INT view_count
        TIMESTAMPTZ created_at
    }

    school_meeting_points {
        UUID id PK
        TEXT name
        TEXT code
        TEXT area_zone
        TEXT description
        TEXT photo_url
        BOOLEAN is_active
    }

    orders {
        UUID id PK
        UUID buyer_id FK
        UUID seller_id FK
        UUID post_id FK
        UUID meeting_point_id FK
        INT total_price
        TEXT buyer_note
        TEXT status
        TIMESTAMPTZ created_at
        TIMESTAMPTZ completed_at
    }

    conversations {
        UUID id PK
        UUID buyer_id FK
        UUID seller_id FK
        UUID post_id FK
        TIMESTAMPTZ created_at
    }

    direct_messages {
        UUID id PK
        UUID conversation_id FK
        UUID sender_id FK
        TEXT content
        BOOLEAN is_read
        TIMESTAMPTZ created_at
    }

    content_reports {
        UUID id PK
        UUID reporter_id FK
        UUID target_post_id FK
        TEXT reason
        TEXT status
        TIMESTAMPTZ created_at
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

## 3.8 Class Diagram

```mermaid
classDiagram
    %% Models
    class UserProfile {
        +String id
        +String nis
        +String username
        +String fullName
        +String? avatarUrl
        +String role
        +String classGroup
        +String? bio
        +fromJson(Map data) UserProfile
        +toJson() Map
    }

    class MarketPost {
        +String id
        +String sellerId
        +String title
        +String description
        +int price
        +int stock
        +String type
        +String category
        +List~String~ imageUrls
        +DateTime createdAt
        +bool get isOutOfStock
    }

    class SchoolMeetingPoint {
        +String id
        +String name
        +String code
        +String areaZone
        +String description
        +String? photoUrl
        +bool isActive
    }

    class OrderTransaction {
        +String id
        +String buyerId
        +String sellerId
        +String postId
        +String meetingPointId
        +int totalPrice
        +String buyerNote
        +String status
        +DateTime createdAt
    }

    %% Services
    class SupabaseAuthService {
        -_client SupabaseClient
        +loginWithNis(String nis, String password) Future~AuthResponse~
        +registerWithNis(String nis, String username, String password) Future~void~
        +bindDevice(String userId, String deviceId) Future~void~
        +getCurrentUser() UserProfile?
    }

    class SupabaseFeedService {
        -_client SupabaseClient
        +fetchFeedPosts(int page, String? category) Future~List~MarketPost~~
        +createPost(MarketPost post) Future~MarketPost~
        +likePost(String postId) Future~void~
        +addComment(String postId, String comment) Future~void~
    }

    class SupabaseOrderService {
        -_client SupabaseClient
        +createCodOrder(OrderTransaction order) Future~OrderTransaction~
        +fetchMeetingPoints() Future~List~SchoolMeetingPoint~~
        +updateOrderStatus(String orderId, String newStatus) Future~void~
    }

    %% Controllers
    class AuthController {
        -SupabaseAuthService _authService
        +UserProfile? currentUser
        +bool isLoading
        +login(String nis, String password) Future~bool~
        +logout() Future~void~
    }

    class CheckoutController {
        -SupabaseOrderService _orderService
        +List~SchoolMeetingPoint~ meetingPoints
        +SchoolMeetingPoint? selectedPoint
        +bool isSubmitting
        +loadMeetingPoints() Future~void~
        +submitCodOrder(String postId, String buyerNote) Future~bool~
    }

    %% Relationships
    AuthController --> SupabaseAuthService : "uses"
    CheckoutController --> SupabaseOrderService : "uses"
    SupabaseAuthService ..> UserProfile : "returns"
    SupabaseFeedService ..> MarketPost : "manages"
    SupabaseOrderService ..> SchoolMeetingPoint : "fetches"
    SupabaseOrderService ..> OrderTransaction : "processes"
    OrderTransaction --> MarketPost : "contains post"
    OrderTransaction --> SchoolMeetingPoint : "meets at"
```

---

## 3.9 Sequence Diagram

### 3.9.1 Sequence Diagram: Autentikasi NIS & Device Binding

```mermaid
sequenceDiagram
    autonumber
    actor Siswa as 👤 Siswa
    participant UI as 📱 LoginScreen
    participant Ctrl as 🎮 AuthController
    participant Svc as 🌐 SupabaseAuthService
    participant DB_Reg as 🗄️ student_registry
    participant DB_Prof as 🗄️ profiles

    Siswa->>UI: Input NIS & Password
    UI->>Ctrl: login(nis, password)
    Ctrl->>Svc: loginWithNis(nis, password)
    
    activate Svc
    Svc->>DB_Reg: SELECT * FROM student_registry WHERE nis = :nis AND is_active = true
    alt NIS Tidak Terdaftar di Sekolah
        DB_Reg-->>Svc: Data Kosong (Not Found)
        Svc-->>Ctrl: Error: NIS tidak terdaftar
        Ctrl-->>UI: Tampilkan SnackBar Peringatan NIS Ilegal
        UI-->>Siswa: Pesan Gagal Login
    else NIS Terdaftar Valid
        DB_Reg-->>Svc: Record Siswa (Nama, Kelas, Jurusan)
        Svc->>DB_Prof: SELECT * FROM profiles WHERE nis = :nis
        DB_Prof-->>Svc: User Profile & Role
        Svc->>Svc: Validasi Bind Hardware Device
        Svc-->>Ctrl: AuthResponse Sukses + Token JWT
        deactivate Svc
        
        Ctrl-->>UI: Update State Login Berhasil
        UI-->>Siswa: Navigasi ke Beranda (Feed & Market)
    end
```

### 3.9.2 Sequence Diagram: Checkout Pesanan COD Titik Temu Sekolah

```mermaid
sequenceDiagram
    autonumber
    actor Pembeli as 👤 Siswa Pembeli
    participant UI as 📱 CheckoutScreen
    participant Ctrl as 🎮 CheckoutController
    participant Svc as 🌐 SupabaseOrderService
    participant DB as 🗄️ Supabase PostgreSQL
    actor Penjual as 👤 Siswa Penjual

    Pembeli->>UI: Buka Halaman Checkout
    UI->>Ctrl: loadMeetingPoints()
    Ctrl->>Svc: fetchMeetingPoints()
    Svc->>DB: SELECT * FROM school_meeting_points WHERE is_active = true
    DB-->>Svc: List Titik Temu (Gazebo, Kantin, Lab)
    Svc-->>Ctrl: Data Lokasi Sekolah
    Ctrl-->>UI: Render Pilihan Spot COD di Denah

    Pembeli->>UI: Pilih Titik Temu & Tulis Catatan
    Pembeli->>UI: Tekan Tombol "Konfirmasi Pesanan"
    UI->>Ctrl: submitCodOrder(postId, note)
    
    activate Ctrl
    Ctrl->>Svc: createCodOrder(payload)
    activate Svc
    
    critical Verifikasi Stok Atomik
        Svc->>DB: BEGIN TRANSACTION
        Svc->>DB: SELECT stock FROM market_posts WHERE id = :postId FOR UPDATE
        alt Stok Habis (stock <= 0)
            DB-->>Svc: Stock = 0
            Svc->>DB: ROLLBACK
            Svc-->>Ctrl: Error: Stok Habis
            Ctrl-->>UI: Tampilkan Alert Gagal (Stok Kosong)
        else Stok Tersedia (stock > 0)
            Svc->>DB: INSERT INTO orders (buyer_id, seller_id, post_id, meeting_point_id, status='pending')
            Svc->>DB: UPDATE market_posts SET stock = stock - 1 WHERE id = :postId
            Svc->>DB: COMMIT TRANSACTION
            DB-->>Svc: Record Order Berhasil Dibuat
            
            Svc->>DB: TRIGGER Notifikasi Masuk ke Penjual
            DB-->>Penjual: Push Notification: "Ada Pesanan COD Baru Masuk!"
            
            Svc-->>Ctrl: Order Sukses
            deactivate Svc
            Ctrl-->>UI: Emit State Sukses
            deactivate Ctrl
            UI-->>Pembeli: Tampilkan Modal Sukses & Panduan Titik Temu
        end
    end
```
