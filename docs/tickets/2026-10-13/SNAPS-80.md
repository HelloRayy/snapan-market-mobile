# [SNAPS-80] fix(image): when image open, ini memiliki ui yang sama semua.

> **Ticket Metadata**:
> - **Plane ID**: `1a72f2be-65db-4b3e-91ab-c1ae98b189b1`
> - **Sequence**: SNAPS-80
> - **Priority**: MEDIUM
> - **State Group**: unstarted (Ticket)
> - **Domain**: `ui / lightbox / jacobs_law / avatar_viewer`

---

## 1. Problem Statement & User Context

- **Deskripsi Masalah di Plane.so**:
  > *"Ada beberapa issue UI ketika image ini di buka (img detailed page) yang tidak menerapkan Jacobs Law, contohnya seperti profile picture ketika di click → expandable image → ini malah sama seperti media feed biasa. coba audit lengkap hal yang serupa seperti ini"*

- **Prinsip Desain (Jakob's Law)**:
  > *"Users spend most of their time on other sites/apps. This means that users prefer your app to work the same way as all the other apps they already know."*
  
  Di aplikasi media sosial populer (Instagram, WhatsApp, Telegram, Twitter/X):
  - **Membuka Foto Profil**: Menampilkan modal dialog avatar terfokus dengan latar belakang gelap transparan (*cinema dark backdrop*), bentuk foto lingkaran/squircle terpusat, menampilkan nama pengguna dan handle, serta gestur cubit zoom atau unduh. **Bukan** carousel horizontal dengan counter feed "1 / 1", tombol love/repost, atau background putih terang.
  - **Membuka Media Postingan Feed**: Menampilkan full-screen media lightbox dengan gestur pinch-to-zoom, swipe horizontal antar-foto (jika multi-foto), serta action bar kontekstual (like, repost, komentar, bagikan).

- **Akar Masalah Teknis di Codebase**:
  1. **Monolitik `MediaLightboxDialog`**:
     Di [`media_lightbox_dialog.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/lightbox/media_lightbox_dialog.dart), komponen ini dipakai untuk *semua* tipe gambar tanpa membedakan konteks pengguna:
     - Di [`profile_screen.dart` (L318)](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/screens/profile_screen.dart#L318): saat user menekan avatar, dipanggil `MediaLightboxDialog.show(context: context, images: [user.avatar], initialIndex: 0)`.
     - Di [`chat_app_bar_title.dart` (L32)](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/messages/components/chat_app_bar_title.dart#L32): saat menekan avatar lawan bicara di chat, dipanggil dialog yang sama.
  2. **UI Anomali pada Avatar Viewer**:
     - Memiliki [`LightboxTopHeader`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/lightbox/lightbox_top_header.dart) yang menampilkan teks indikator paging `"1 / 1"` (aneh untuk foto profil tunggal).
     - Memiliki [`LightboxNavArrows`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/lightbox/lightbox_nav_arrows.dart) tombol chevron navigasi kiri-kanan.
     - Latar belakang default menggunakan warna putih terang (`Colors.white.withValues(alpha: bgOpacity)`), yang terasa menyilaukan dan berbeda 180° dari standar industri yang memakai dark backdrop untuk inspeksi foto.

---

## 2. Target File Scope (Interface-First Coupling)

| Peran File | Path File di Repositori | Keterangan Peran |
| :--- | :--- | :--- |
| **Avatar Viewer Dialog (Baru)** | [`lib/core/components/avatar_viewer_dialog.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/components/avatar_viewer_dialog.dart) | Dialog khusus inspeksi foto profil (dark backdrop, lingkaran/squircle terpusat, info user, Hero animation) |
| **Profile Screen** | [`lib/features/profile/screens/profile_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/screens/profile_screen.dart) | Mengganti trigger avatar tap agar memanggil `AvatarViewerDialog.show(...)` |
| **Chat App Bar Title** | [`lib/features/messages/components/chat_app_bar_title.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/messages/components/chat_app_bar_title.dart) | Mengganti trigger tap avatar lawan bicara ke `AvatarViewerDialog.show(...)` |
| **Media Lightbox Dialog** | [`lib/features/feed/components/lightbox/media_lightbox_dialog.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/lightbox/media_lightbox_dialog.dart) | Optimasi lightbox media feed: sembunyikan nav arrows jika hanya 1 gambar, dukung dark backdrop adaptif |
| **Lightbox Top Header** | [`lib/features/feed/components/lightbox/lightbox_top_header.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/lightbox/lightbox_top_header.dart) | Sembunyikan counter `"1 / 1"` jika total gambar hanya 1 item |

---

## 3. Step-by-Step Technical Approach

### Langkah 1: Buat Komponen Khusus `AvatarViewerDialog`
Membangun widget dialog mandiri yang menerapkan standar industri (*Jakob's Law* - pola WhatsApp / Instagram / Telegram):
1. **Latar Belakang**: Hitam pekat transparan (*dimmed backdrop*, misal `Colors.black.withOpacity(0.92)`).
2. **Animasi Transisi**: `Hero` tag transisi mulus dari widget avatar di halaman asal ke tengah layar dialog.
3. **Bingkai Gambar**: Lingkaran atau squircle proporsional (diameter ~320 dp) dengan opsi full zoom interaktif (`InteractiveViewer`).
4. **Header Kontekstual**:
   - Menampilkan nama pengguna (`displayName`) dan username (`@username`).
   - Tombol tutup (`Icons.close_rounded`) di pojok kanan atau kiri.
5. **Aksi Cepat di Bagian Bawah**:
   - Tombol "Bagikan Profil" atau "Simpan Foto" (opsional).
6. **Gestur Natural**:
   - Swipe down to dismiss dengan spring physics.
   - Ketuk di luar area gambar untuk langsung menutup dialog.

### Langkah 2: Refactor Pemanggilan di Seluruh Titik Profil
Arahkan seluruh pemicu tap avatar ke `AvatarViewerDialog`:
- Di [`ProfileScreen`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/screens/profile_screen.dart#L318):
  ```dart
  AvatarViewerDialog.show(
    context: context,
    imageUrl: user.avatar,
    title: user.displayName,
    subtitle: '@${user.username}',
    heroTag: 'profile_avatar_${user.id}',
  );
  ```
- Di [`ChatAppBarTitle`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/messages/components/chat_app_bar_title.dart#L32):
  ```dart
  AvatarViewerDialog.show(
    context: context,
    imageUrl: participantAvatar,
    title: participantName,
    subtitle: participantRole,
    heroTag: 'chat_avatar_${widget.conversationId}',
  );
  ```

### Langkah 3: Perbaiki `MediaLightboxDialog` (Post Media Feed)
1. **Kondisional Counter & Navigasi**:
   - Jika `images.length <= 1`: Sembunyikan counter `"1 / 1"` pada `LightboxTopHeader` dan jangan render `LightboxNavArrows`.
2. **Pilihan Tema Backdrop**:
   - Berikan opsi background gelap (`Colors.black87` / `Color(0xFF0F172A)`) untuk media foto agar warna dan kontras foto terlihat lebih menonjol (standar iOS Photo Viewer & Twitter).

---

## 4. Review Decisions & Architectural Mitigations

- **Keputusan Pertanyaan 1 (Bentuk Avatar Viewer)**:
  - **Dipilih**: **Lingkaran Sempurna (Circle Full)** seperti WhatsApp / Telegram.
  - Implementasi: `ClipOval` terpusat (~290dp) dengan rim border `Colors.white.withValues(alpha: 0.18)` dan dynamic shadow untuk pemisahan siluet pada latar gelap.

- **Keputusan Pertanyaan 2 (Backdrop Media Lightbox & Avatar Viewer)**:
  - **Dipilih**: **Theme-Adaptive Backdrop (Light Theme: White / Dark Theme: Dark Cinema `#0B0F17`)**.
  - **Implementasi**: Deteksi `isDark = Theme.of(context).brightness == Brightness.dark`:
    - Pada **Light Mode**: Background putih (`Colors.white.withValues(alpha: bgOpacity)`), barrier putih (`0.96`), tombol/badge putih dengan border slate halus (`#E2E8F0`), teks & ikon kontras tinggi (`#0F172A` / `#334155`), status bar `SystemUiOverlayStyle.dark`.
    - Pada **Dark Mode**: Background Dark Cinema (`#0B0F17`), barrier hitam (`0.96`), kontrol frosted dark glass, teks & ikon putih, status bar `SystemUiOverlayStyle.light`.

---

## 5. Definition of Done (DoD)
- [x] Membuka foto profil di `ProfileScreen` dan chat menampilkan dialog avatar terspesialisasi (bukan lightbox feed).
- [x] Tidak ada tulisan counter `"1 / 1"` atau panah navigasi yang tidak perlu saat melihat avatar tunggal.
- [x] Terdapat informasi nama pengguna dan tombol close yang jelas pada avatar viewer.
- [x] `MediaLightboxDialog` pada feed menyembunyikan panah navigasi dan angka counter jika postingan hanya memiliki 1 gambar.
- [x] Gestur swipe-down-to-dismiss dan pinch-to-zoom bekerja dengan responsif dan mulus.
- [x] Lulus pengujian analisis kode `flutter analyze` dengan 0 issue.
