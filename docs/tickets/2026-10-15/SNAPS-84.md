# [SNAPS-84] feat(about): release status, app version info and environment sheet in settings/profile

> **Ticket Metadata**:
> - **Sequence**: SNAPS-84
> - **Priority**: MEDIUM
> - **Domain**: `settings / version / build_info`
> - **Status**: Ticket (Ready to Implement)

---

## 1. Problem Statement & User Context

- **Kondisi Saat Ini**:
  Pengguna dan penguji beta tidak memiliki tempat untuk mengecek nomor versi dan build aplikasi yang sedang terpasang di HP mereka.
  Jika terjadi masalah pada versi tertentu (misal v1.0.28 vs v1.0.30), siswa tidak tahu versi mana yang mereka jalankan, dan tombol "Periksa Pembaruan" hanya muncul secara pasif saat aplikasi baru dibuka.
- **Kebutuhan Beta Release**:
  Halaman atau bottom sheet "Tentang Snaps" yang menampilkan status rilis, badge "Beta Release", detail build aplikasi, tombol "Periksa Pembaruan Sekarang", dan tombol praktis "Salin Info Perangkat" untuk mempermudah pelaporan kendala.

---

## 2. Target File Scope

| File Path | Peran & Perubahan |
| :--- | :--- |
| [`lib/core/components/about_app_bottom_sheet.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/components/about_app_bottom_sheet.dart) | **(Baru)** Sheet informasi versi aplikasi, logo Snaps squircle, badge status build, tombol manual check update, dan footer credit PJBL SMKN 8 Jember |
| [`lib/features/feed/components/navigation/home_menu_popover.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/navigation/home_menu_popover.dart) | Menambahkan opsi "Tentang Snaps" atau menyambungkan item pengaturan |
| [`lib/features/profile/screens/profile_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/screens/profile_screen.dart) | Menambahkan tombol aksi info versi di app bar profil atau menu pengaturan profil |

---

## 3. Step-by-Step Technical Approach

### Langkah 1: Pembuatan `AboutAppBottomSheet`
1. **Header**: Logo Snaps (`SnapsLogo`), nama aplikasi "Snaps", dan badge chip `Beta Release`.
2. **Info Versi**: Mengambil informasi dinamis dari `PackageInfo.fromPlatform()`:
   - Versi: `v1.0.30`
   - Build Code: `Build 33`
   - Lingkungan: `Production / Beta Channel`
3. **Aksi Periksa Update Manual**:
   - Tombol "Periksa Pembaruan" yang memanggil `AppUpdateService.instance.checkForUpdate(isManual: true)`.
   - Jika ada pembaruan: buka langsung `UpdateInfoBottomSheet.show()`.
   - Jika sudah terbaru: munculkan SnackBar hijau *"Aplikasi Anda sudah menggunakan versi paling baru."*.
4. **Salin Info Sistem (Debug Copy)**:
   - Tombol icon salin yang menyalin string ringkas: `Snaps v1.0.30+33 | Android 14 | Model: Samsung A54` ke Clipboard untuk dikirim ke tim pengembang.

### Langkah 2: Pemasangan Entry Point
1. Tambahkan item di `HomeMenuPopover` di bawah "Laporkan masalah" atau jadikan bagian dari menu "Pengaturan".
2. Tambahkan tombol info versi di pojok header halaman profil siswa.

---

## 4. Definition of Done (DoD)

- [ ] Membuka sheet "Tentang Snaps" menampilkan versi dan nomor build aplikasi yang akurat sesuai `pubspec.yaml`.
- [ ] Tombol "Periksa Pembaruan" dapat memicu pengecekan update secara manual ke Supabase.
- [ ] Tersedia tombol "Salin Info Perangkat" yang menyalin rincian lingkungan ke clipboard.
- [ ] Seluruh tampilan mendukung Dark Mode dan Light Mode tanpa glitch warna.
- [ ] Lolos static analysis `flutter analyze` dengan 0 errors.
