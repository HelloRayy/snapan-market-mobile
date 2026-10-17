# 11. CLASS DIAGRAM (STRUKTUR KELAS & METODE CHECKOUT)

**Dokumen**: Bab III - Bagian 3.9  
**Proyek**: Snapan Market Mobile (sNaps) - SMKN 8 Semarang  
**Teknologi**: Flutter Framework (Dart) & Supabase Client SDK  
**Fokus**: Pemodelan Berorientasi Objek (OOP) Kelas, Atribut, Metode, dan Hubungan Antar Objek  

---

## 1. Definisi & Arsitektur Kelas
Class Diagram menggambarkan struktur statis sistem perangkat lunak berorientasi objek dengan mendefinisikan kelas-kelas, atribut data, operasi (*methods/functions*), hak visibilitas (*encapsulation*), serta relasi asosiasi dan dependensi antar kelas. Sistem mengadopsi pola arsitektur *Clean Component-Controller*: memisahkan lapisan **Presentation (UI)**, **Controller (State Management)**, **Entity (Domain Models)**, dan **Service (Backend Gateway)**.

---

## 2. Class Diagram Arsitektur Checkout sNaps

```mermaid
classDiagram
    %% PRESENTATION & CONTROLLER LAYER
    class CheckoutScreen {
        +MarketPost product
        +createState() State~CheckoutScreen~
    }

    class CheckoutController {
        -SupabaseOrderService _orderService
        +List~SchoolMeetingPoint~ meetingPoints
        +SchoolMeetingPoint? selectedPoint
        +String buyerNote
        +bool isLoading
        +bool isSubmitting
        +loadMeetingPoints() Future~void~
        +selectMeetingPoint(SchoolMeetingPoint point) void
        +setBuyerNote(String note) void
        +submitCodOrder(String postId) Future~bool~
    }

    class CheckoutBottomBar {
        +int price
        +bool isOrdering
        +VoidCallback onOrderSubmit
        +build(BuildContext context) Widget
    }

    %% DOMAIN ENTITY / MODEL LAYER
    class UserProfile {
        +String id
        +String nis
        +String username
        +String fullName
        +String? avatarUrl
        +String role
        +String classGroup
        +String? bio
        +UserProfile.fromJson(Map~String, dynamic~ json)
        +toJson() Map~String, dynamic~
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
        +MarketPost.fromJson(Map~String, dynamic~ json)
    }

    class SchoolMeetingPoint {
        +String id
        +String name
        +String code
        +String areaZone
        +String description
        +String? photoUrl
        +bool isActive
        +SchoolMeetingPoint.fromJson(Map~String, dynamic~ json)
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
        +DateTime? completedAt
        +OrderTransaction.fromJson(Map~String, dynamic~ json)
    }

    %% DATA SERVICE & BACKEND GATEWAY LAYER
    class SupabaseOrderService {
        -SupabaseClient _client
        +fetchActiveMeetingPoints() Future~List~SchoolMeetingPoint~~
        +createAtomicCodOrder(String postId, String meetingPointId, String note) Future~OrderTransaction~
        +verifyProductStock(String postId) Future~int~
        +updateOrderStatus(String orderId, String status) Future~void~
    }

    %% RELASI & DEPENDENSI OOP
    CheckoutScreen --> CheckoutController : "binds & observes"
    CheckoutScreen *-- CheckoutBottomBar : "contains"
    CheckoutController --> SupabaseOrderService : "calls business logic"
    
    CheckoutController o-- SchoolMeetingPoint : "holds selected"
    CheckoutController ..> OrderTransaction : "creates instance"
    
    SupabaseOrderService ..> SchoolMeetingPoint : "deserializes"
    SupabaseOrderService ..> OrderTransaction : "persists to Supabase"
    SupabaseOrderService ..> MarketPost : "checks stock"
    
    OrderTransaction --> MarketPost : "references"
    OrderTransaction --> SchoolMeetingPoint : "delivered at"
    OrderTransaction --> UserProfile : "involves buyer & seller"
```

---

## 3. Rincian Hak Akses & Metode Utama

### 3.1 Lapisan Controller (`CheckoutController`)
- `- _orderService`: Properti instansiasi private untuk membatasi interaksi query database hanya melalui layer service resmi.
- `+ submitCodOrder(String postId)`: Memvalidasi ketersediaan input catatan dan titik kumpul sebelum memicu pemrosesan transaksi pesanan.
- `+ loadMeetingPoints()`: Mengambil daftar spot titik kumpul resmi sekolah dari database Supabase untuk ditampilkan di peta interaktif mobile.

### 3.2 Lapisan Model (`MarketPost` & `OrderTransaction`)
- `+ bool get isOutOfStock`: Properti *getter* komputasi cepat yang mengembalikan nilai `true` jika nilai atribut `stock <= 0` untuk menonaktifkan tombol pemesanan di antarmuka siswa.
- `+ fromJson(...)` & `+ toJson(...)`: Metode serialisasi dan deserialisasi data format JSON antara Dart Object dan payload REST API Supabase.

### 3.3 Lapisan Service Gateway (`SupabaseOrderService`)
- `+ createAtomicCodOrder(...)`: Mengeksekusi RPC (*Remote Procedure Call*) transaksi atomik pada PostgreSQL Supabase agar verifikasi stok dan penyimpanan pesanan terjadi dalam satu siklus aman (*thread-safe*).
