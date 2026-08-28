# 📱 PANDUAN LENGKAP MIGRASI TECH STACK KE KOTLIN (ANDROID / JETPACK COMPOSE)
## Snapan Market Mobile — SMKN 8 Jakarta
> **Dokumentasi Prosedur Migrasi 1:1 UI/UX Parity (React PWA $\rightarrow$ Kotlin Native)**  
> *Dibuat khusus sebagai acuan teknis, panduan belajar fundamental Kotlin/Compose, dan roadmap eksekusi.*

---

## 📌 DAFTAR ISI
1. [Latar Belakang & Filosofi 1:1 UI Parity](#1-latar-belakang--filosofi-11-ui-parity)
2. [Kamus Mental Model: React Web vs Jetpack Compose](#2-kamus-mental-model-react-web-vs-jetpack-compose)
3. [Arsitektur Target & Struktur Folder Android](#3-arsitektur-target--struktur-folder-android)
4. [Desain Sistem & Spesifikasi Token 1:1 (SnapanTheme)](#4-desain-sistem--spesifikasi-token-11-snapantheme)
5. [Bedah Komponen Atomic UI Reusable](#5-bedah-komponen-atomic-ui-reusable)
6. [Integrasi Backend Supabase Kotlin (Auth, DB, Realtime, Storage)](#6-integrasi-backend-supabase-kotlin)
7. [Prosedur Eksekusi Langkah-demi-Langkah (Roadmap)](#7-prosedur-eksekusi-langkah-demi-langkah-roadmap)
8. [Checklist Verifikasi Kualitas & Paritas Visual](#8-checklist-verifikasi-kualitas--paritas-visual)

---

## 1. Latar Belakang & Filosofi 1:1 UI Parity

Aplikasi **Snapan Market Mobile** saat ini berjalan menggunakan React 18 + Vite + Tailwind CSS v4 + Zustand + Supabase.

Tujuan utama migrasi ke **Kotlin (Android Native dengan Jetpack Compose)**:
- **Performa Native Penuh**: Animasi 120 FPS tanpa frame drop, start-up instan, dan integrasi hardware (Haptics, Kamera, Notifikasi).
- **1:1 UI Parity**: Tampilan visual, palet warna, tipografi, micro-interaction, popup dialog, bottom sheet, dan alur transaksi COD tetap identik 100% tanpa mengubah estetika visual sedikit pun.
- **Kemudahan Belajar (Beginner-Friendly)**: Menggunakan Jetpack Compose yang memiliki pola pikir (mental model) deklaratif yang sama persis dengan React.

---

## 2. Kamus Mental Model: React Web vs Jetpack Compose

Jika kamu sudah terbiasa dengan React, mempelajari Jetpack Compose sangat mudah karena konsepnya identik:

| Fitur / Konsep | Di React Web (Saat Ini) | Di Kotlin (Jetpack Compose) | Penjelasan & Cara Kerja |
| :--- | :--- | :--- | :--- |
| **Komponen Tampilan** | `function Button() { return <button>...</button>; }` | `@Composable fun SnapanButton() { ... }` | Fungsi dengan anotasi `@Composable` yang otomatis menggambar UI ke layar. |
| **Layout Vertikal** | `<div className="flex flex-col gap-4">` | `Column(verticalArrangement = Arrangement.spacedBy(16.dp))` | Menyusun elemen dari atas ke bawah. |
| **Layout Horizontal** | `<div className="flex flex-row items-center">` | `Row(verticalAlignment = Alignment.CenterVertically)` | Menyusun elemen berdampingan dari kiri ke kanan. |
| **Layering / Tumpukan** | `<div className="relative"> <div className="absolute inset-0">` | `Box { ... }` | Menumpuk elemen di atas elemen lain (misal badge di atas avatar). |
| **Teks & Tipografi** | `<p className="text-sm font-bold text-black">` | `Text(text = "...", fontSize = 14.sp, fontWeight = FontWeight.Bold)` | Menampilkan teks dengan format font dan warna. |
| **Styling & Margin/Padding** | `className="p-4 bg-white rounded-xl shadow-md"` | `Modifier.padding(16.dp).background(Color.White).clip(RoundedCornerShape(12.dp))` | Modifier adalah cara menyusun gaya, ukuran, padding, klik, dan animasi. |
| **State Lokal** | `const [likes, setLikes] = useState(0);` | `var likes by remember { mutableStateOf(0) }` | State lokal yang otomatis me-re-render UI saat nilainya berubah. |
| **Efek Samping (Mount/Async)** | `useEffect(() => { fetchFeed(); }, []);` | `LaunchedEffect(Unit) { feedRepo.getFeed() }` | Menjalankan coroutines saat halaman pertama kali dibuka. |
| **Global State** | Zustand (`cartStore.ts`) | `ViewModel` + `StateFlow` | Menyimpan data aplikasi agar tidak hilang saat HP diputar atau pindah layar. |
| **Backend SDK** | `@supabase/supabase-js` | `io.github.jan-tennert.supabase` (`supabase-kt`) | SDK resmi Supabase untuk Kotlin (Auth, DB, Realtime). |

---

## 3. Arsitektur Target & Struktur Folder Android

Proyek Android ditempatkan dalam folder `/android` di repositori ini:

```
android/
├── app/
│   ├── build.gradle.kts                  # Dependensi library (Compose, Supabase, Coil)
│   └── src/main/
│       ├── AndroidManifest.xml           # Izin (Internet, Haptics) & Konfigurasi App
│       ├── res/                          # Icon, font Inter, drawables
│       └── java/com/snapan/market/
│           ├── MainActivity.kt           # Entry point utama & theme wrapper
│           ├── ui/
│           │   ├── theme/                # Token desain resmi (Warna, Tipografi, Shape)
│           │   ├── components/           # Komponen atomic (Button, Card, Input, Badge, Toast)
│           │   ├── screens/              # Layar lengkap (Home, Detail, Buat Post, Chat, Profil)
│           │   └── navigation/           # NavGraph & rute halaman
│           └── data/
│               ├── model/                # Data Class Kotlin (MarketPost, Product, User)
│               ├── remote/               # Supabase Client & Repositories
│               └── local/                # DataStore (Cache offline & session)
```

---

## 4. Desain Sistem & Spesifikasi Token 1:1 (`SnapanTheme`)

### A. Palet Warna Resmi
- **Brand Primary (Electric Indigo)**: `#3D38F5`
- **Brand Hover**: `#312BD9`
- **Brand Pastel (Wash Background)**: `#EEF0FF`
- **Brand Border**: `#D8DBFE`
- **Canvas Mist**: `#F2F4F5`
- **Pure White**: `#FFFFFF`
- **Ink Black**: `#000000`
- **Faint Border**: `#EBEBEB`
- **Muted Gray**: `#787574`
- **Price Amber**: Background `#FEF3C7`, Teks `#D97706`
- **Stock Green**: Background `#DCFCE7`, Teks `#16A34A`
- **Ruby Red (Like Icon)**: `#E11D48`

### B. Tipografi Font Inter
- **Display Title**: 20sp Bold (700), Line Height 26sp
- **Body Large**: 15sp Normal (400), Line Height 22sp
- **Body Medium**: 14sp Normal (400), Line Height 20sp
- **Caption**: 12sp Medium (500), Line Height 16sp
- **Price Tag**: 14sp SemiBold (600) Tabular Numbers

---

## 5. Bedah Komponen Atomic UI Reusable

1. **`SnapanButton`**:
   - **Primary**: Background gradasi biru `#3b82f6` $\rightarrow$ `#1d64ec`, border `#154ec1`, efek tekan mikro (`scale: 0.97`).
   - **Secondary**: Putih bersih dengan border halus `#ebebeb`.
   - **Danger**: Warna merah `#dc2626` untuk aksi destruktif.
2. **`SnapanCard`**:
   - Kontainer putih dengan sudut melengkung 16dp dan border 1dp `#ebebeb`.
3. **`SnapanBadge`**:
   - **Verified Badge**: Centang putih di lingkaran biru elektrik untuk siswa terverifikasi.
   - **Price Badge**: Label harga oranye amber `Rp 45.000`.
   - **Stock Badge**: Label hijau sisa stok `Sisa 2`.
4. **`ToastBar`**:
   - Floating capsule toast hitam mengambang di atas layar dengan icon sukses & auto-dismiss 2.5 detik.
5. **`ConfirmActionDialog`**:
   - Bottom sheet konfirmasi sebelum membuang draf atau menghapus postingan.
6. **`ChatBubble`**:
   - Gelembung obrolan biru elektrik untuk pesan sendiri dan abu-abu muda untuk lawan bicara.

---

## 6. Integrasi Backend Supabase Kotlin

Inisialisasi Client di Kotlin:
```kotlin
val client = createSupabaseClient(
    supabaseUrl = "https://your-project.supabase.co",
    supabaseKey = "your-anon-key"
) {
    install(Auth)
    install(Postgrest)
    install(Realtime)
    install(Storage)
}
```

Model Data dengan `@Serializable`:
- `MarketPostItem`: ID, judul, deskripsi, harga, foto, penjual, jumlah like/komentar.
- `Product`: Data katalog jualan siswa.
- `Order`: Pesanan COD, titik kumpul di sekolah, catatan.
- `UserProfile`: Data profil, kelas (misal `XII PPLG 1`), NISN, badge verifikasi.

---

## 7. Prosedur Eksekusi Langkah-demi-Langkah (Roadmap)

### 📌 Langkah 1: Persiapan Environment & Android Studio
1. Install **Android Studio Ladybug / Koala** atau versi terbaru.
2. Install **JDK 17** atau **JDK 21**.
3. Buka folder `/android` di Android Studio dan biarkan Gradle melakukan *Sync Project*.

### 📌 Langkah 2: Setup Desain Sistem & Komponen Dasar
1. Bangun `Color.kt`, `Type.kt`, `Shape.kt`, dan `Theme.kt` di package `ui.theme`.
2. Uji komponen atomic (`SnapanButton`, `SnapanCard`, `SnapanBadge`) menggunakan `@Preview` di Android Studio tanpa perlu menjalankan emulator.

### 📌 Langkah 3: Integrasi Data & Supabase Repository
1. Buat data class di package `data.model`.
2. Buat repository untuk Auth, Feed, Order, dan Chat di package `data.remote`.
3. Hubungkan ke database Supabase untuk mengambil data postingan dan user.

### 📌 Langkah 4: Bangun Layar (Screens) Secara Bertahap
1. **Onboarding & Login OTP**: Layar 4 slide pengenalan dan form input nomor HP / OTP.
2. **Home Feed**: Feed postingan dengan tab Untuk Anda / Produk, tombol like interaktif, dan pull-to-refresh.
3. **Detail Postingan**: Utas lengkap dengan pohon komentar bertingkat (*nested replies*).
4. **Transaksi COD & Beli**: Bottom sheet jumlah barang, pilih titik temu di sekolah, dan konfirmasi pesan.
5. **Buat Postingan / Jual**: Form buat postingan dengan toggle mode jualan dan unggah foto.
6. **Pencarian**: Pencarian live dengan tag topik tren.
7. **Pesan Langsung (Chat)**: Daftar chat dan ruang obrolan dengan kartu produk tersemat.
8. **Profil**: Tampilan profil siswa, tab Utas/Jualan, dan modal edit profil.

---

## 8. Checklist Verifikasi Kualitas & Paritas Visual

- [ ] **Warna & Layout**: Warna Indigo `#3D38F5` dan border `#EBEBEB` sama persis dengan versi web.
- [ ] **Tipografi**: Menggunakan font Inter dengan ukuran dan ketebalan yang proporsional.
- [ ] **Animasi & Haptic**: Tombol dan icon like memiliki feedback getaran lembut saat ditekan.
- [ ] **Koneksi Supabase**: Data postingan, like, dan pesanan COD tersimpan langsung di Supabase.
- [ ] **Build APK**: Menjalankan `./gradlew assembleDebug` menghasilkan file APK yang dapat di-install di HP Android.
