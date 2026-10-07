# Flutter & Dart Coding Standards for Long-Term Maintainability
**Project: Snapan Market Mobile (sNaps)**  
*Standar Rekayasa Perangkat Lunak untuk Pengembang & AI Agent Baru*

---

## 🧭 1. Prinsip Utama (Core Philosophy)

1. **Maintainability Over Cleverness**:
   - Tulis kode yang mudah dibaca, dipahami, dan dipelihara oleh AI maupun developer lain 6 bulan ke depan. Hindari kode "pintar" atau *one-liner* rumit yang sulit di-debug.
2. **Single Responsibility Principle (SRP)**:
   - Satu file dan satu widget hanya memiliki **satu tanggung jawab utama**.
   - Layar (`screens/`) hanya sebagai *orchestrator* tata letak level tinggi.
   - Komponen visual berada di `components/`.
   - Logika bisnis dan pemanggilan API berada di `controllers/` atau `services/`.
3. **Flutter-First Focus (`lib/`)**:
   - Seluruh pekerjaan utama aplikasi berada di folder `lib/`. File web di `src/` hanya untuk portal web admin atau referensi visual.

---

## 🧱 2. Batasan Ukuran File & Aturan Dekomposisi (Anti-Monolith)

### A. Batas Keras 250–300 Baris Per File
- **Target Ideal**: <= 200 baris.
- **Batas Keras**: Maksimal 250–300 baris.
- Jika sebuah file screen atau widget mendekati 250 baris, **WAJIB** dipecah ke dalam sub-komponen terpisah di `<feature>/components/`.

### B. Larangan Menumpuk Private Helper Methods
❌ **DILARANG**:
Menulis ratusan baris private methods di dalam satu file screen, misalnya:
```dart
// BURUK: Membuat screen membengkak menjadi 700+ baris
Widget _buildHeader() { ... }
Widget _buildProductCard() { ... }
Widget _buildCommentSection() { ... }
Widget _buildActionButtons() { ... }
```
✅ **WAJIB**:
Pecah setiap bagian menjadi kelas widget terpisah di file terpisah:
```dart
// BAIK: Bersih, modular, dan mudah di-maintain
// lib/features/feed/components/home_feed_header.dart
class HomeFeedHeader extends StatelessWidget { ... }

// lib/features/feed/components/market_post_card.dart
class MarketPostCard extends StatelessWidget { ... }
```

---

## 🎨 3. Standar UI, Token Desain & Konsistensi Visual

### A. Color Tokens (`lib/core/theme/app_colors.dart`)
- **Wajib menggunakan token resmi**, jangan menulis warna hex sembarangan:
  - Brand Primary: `AppColors.primary` (`#3D38F5` Electric Indigo)
  - Dark Surface / Teks: `const Color(0xFF0F172A)` / `const Color(0xFF1E293B)`
  - Muted Text: `const Color(0xFF64748B)`
  - Border Halus: `const Color(0xFFE2E8F0)`
  - Background Lembut: `const Color(0xFFF8FAFC)`
  - Status: Emerald (`#10B981`), Danger (`#EF4444`), Warning (`#F59E0B`)

### B. Ikon & Logo Resmi
- **Ikon**: Selalu gunakan paket `lucide_icons_flutter` (`LucideIcons.*`) untuk konsistensi garis dan ketebalan.
- **Logo Brand**: Selalu gunakan `SnapsLogo` dari `lib/core/components/snaps_logo.dart`. Jangan pernah mengimpor aset SVG mentah secara manual di berbagai tempat.

### C. Touch Targets & Haptics (Rasa Penggunaan Nyata)
- **Minimum Hit Area**: Setiap tombol, icon button, dan kartu interaktif wajib memiliki area sentuh minimal **44x44 dp** (standar Apple HIG & Material 3) agar nyaman ditekan jempol di HP.
- **Mikro-Interaksi Haptic**:
  - Sentuhan tombol/tab: `HapticFeedback.lightImpact()` atau `selectionClick()`
  - Aksi konfirmasi/hapus: `HapticFeedback.mediumImpact()` atau `vibrate()`
- **Scroll Physics**: Selalu gunakan `const BouncingScrollPhysics()` untuk kenyamanan gestur di perangkat mobile.

---

## ⚡ 4. Best Practices Dart & Flutter Performance

1. **Optimasi `const` Constructor**:
   - Selalu tambahkan kata kunci `const` pada widget statis. Ini mencegah rebuild yang tidak perlu dan menjaga frame rate stabil di 60/120 FPS.
2. **Explicit Null Safety**:
   - Hindari penggunaan tanda seru `!` (force unwrap) secara membabi buta. Gunakan defensive checks (`if (student != null) ...` atau null coalescing `??`).
3. **Penyusunan Form & Keyboard Safety**:
   - Selalu bungkus form dengan `SingleChildScrollView` dan pasang penutup keyboard otomatis via `GestureDetector(onTap: () => FocusManager.instance.primaryFocus?.unfocus())`.
   - Gunakan `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag`.
4. **State Management Ringan**:
   - Gunakan controller berbasis `ChangeNotifier` atau `ValueNotifier` bersama `ListenableBuilder` untuk merender ulang **hanya bagian yang berubah**, bukan seluruh pohon widget screen.

---

## 🗄️ 5. Komunikasi Data & Service Layer

1. **UI Tidak Boleh Query Database Mentah**:
   - Widget dilarang menulis query Supabase langsung di dalam `build()`. Seluruh pemanggilan database harus melalui `Service` (contoh: `SupabaseService.instance`, `StudentRegistryService.instance`).
2. **4 Kondisi UI yang Wajib Ditangani**:
   Setiap tampilan yang memuat data asinkron **wajib** memiliki 4 status visual yang jelas:
   - **Loading**: Shimmer skeleton atau circular indicator yang rapi.
   - **Empty**: Tampilan kosong ramah pengguna (*empty state illustration & text*).
   - **Error**: Pesan error manusiawi disertai tombol coba lagi (*retry*).
   - **Success**: Konten utama.
3. **Single Source of Truth**:
   - Data siswa dan validasi identitas sekolah selalu berpusat pada **NIS** via `StudentRegistryService`.

---

## 🌐 6. Standar Web Admin (`src/admin/`)

Jika dan hanya jika ditugaskan mengerjakan Web Admin:
- Gunakan **Strict Mode TypeScript** tanpa tipe `any`.
- Gunakan Tailwind CSS utility classes dengan helper `cn()`.
- Semua service admin berada di `src/admin/services/`.
- Jangan pernah mengimpor file `lib/` (Dart) ke dalam file `src/` (Web/TypeScript), dan sebaliknya.
