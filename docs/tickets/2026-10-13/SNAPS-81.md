# [SNAPS-81] feat(image-crop): add fitur additional ke image

> **Ticket Metadata**:
> - **Plane ID**: `dca7a947-078c-4297-a6af-e12434718518`
> - **Sequence**: SNAPS-81
> - **Priority**: MEDIUM
> - **State Group**: in_progress (Implementation Completed)
> - **Domain**: `image_picker / media / crop_editor`

---

## 1. Problem Statement & User Context

- **Deskripsi Masalah di Plane.so**:
  > *"Di berbagai apps kompetitor, setiap yang memasukan gmabar ini bisa di 'edit' oleh user sendiri. seperti crop, change photo dll. saya ingin menerapkan fungsi ini ke apps kita. contoh penerapan di add photo profile yang bsia di crop atau bisa di geser. jadi ngga fix gt lo"*

- **Keputusan Desain & Konsensus Reviewer**:
  - **Native Cropper (uCrop / TOCropViewController)**: Menggunakan package resmi `image_cropper` untuk performa GPU native yang sangat responsif (60-120 FPS), konsistensi antarmuka familiar ala WhatsApp / Twitter (*Jakob's Law*), dan tanpa beban custom canvas rendering yang berat di Flutter.
  - **MVP Scope**: Murni **Pan (geser)**, **Pinch-to-zoom (perbesar/perkecil)**, dan **1:1 Circular Masking** untuk foto profil siswa.

---

## 2. Target File Scope & Implementation

| Peran File | Path File di Repositori | Keterangan Perubahan |
| :--- | :--- | :--- |
| **Media Cropper Service (Baru)** | [`lib/core/services/media_cropper_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/media_cropper_service.dart) | Service native crop dengan konfigurasi UI Snaps (`AppColors.primary`, dark toolbar, 1:1 circle mask untuk avatar, ratio presets untuk post) |
| **Edit Profile Avatar Section** | [`lib/features/profile/components/edit_profile_avatar_section.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/components/edit_profile_avatar_section.dart) | Integrasi pemanggilan `cropAvatar` tepat setelah memilih foto sebelum diunggah ke Supabase Storage |
| **Android Manifest** | [`android/app/src/main/AndroidManifest.xml`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/android/app/src/main/AndroidManifest.xml) | Mendaftarkan native activity `com.yalantis.ucrop.UCropActivity` |
| **Dependencies** | [`pubspec.yaml`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/pubspec.yaml) | Menambahkan `image_cropper: ^13.0.0` |

---

## 3. Definition of Done (DoD) Verification
- [x] Tersedia native activity saat user memilih foto avatar (kamera/galeri) yang memungkinkan user menggeser (*pan*) dan memperbesar/memperkecil (*zoom in/out*).
- [x] Masking lingkaran 1:1 (*circular mask*) presisi agar hasil foto profil simetris dan rapi.
- [x] Jika user menekan tombol batal (*cancel*), proses unggah dibatalkan tanpa error.
- [x] Foto hasil crop dikompresi optimal (maksimal 720p, kualitas 85%) dan diunggah ke Supabase bucket `avatars`.
- [x] Kompatibilitas `AndroidManifest.xml` terverifikasi.
- [x] Lulus analisis `flutter analyze` dengan **No issues found**.

---

## 3. Step-by-Step Technical Approach

### Langkah 1: Evaluasi Pendekatan Arsitektur (Zero-Dependency vs Plugin Natif)

Ada 2 pendekatan teknis untuk menerapkan fitur crop di Flutter:

- **Pendekatan 1: Pure Flutter In-App Cropper Modal (Zero Native Dependency - SANGAT DIREKOMENDASIKAN)**:
  * Menggunakan kombinasi `InteractiveViewer` + `CustomPainter` (Circular Clip Mask & Rule-of-Thirds Grid) + rendering snapshot menggunakan `RenderRepaintBoundary` atau manipulasi byte via library `image` (yang sudah ada/ringan).
  * **Kelebihan**:
    - **100% UI Snaps**: Tampilan, warna (`#0284C7`), ikon, dan animasi sepenuhnya seragam dengan gaya aplikasi Snaps.
    - **Bebas Masalah Build Native Android**: Tidak perlu menyentuh konfigurasi `AndroidManifest.xml` atau dependensi Gradle `UCropActivity` yang berpotensi memicu konflik build rilis / OTA.
    - **Performa Instan**: Tidak berpindah activity Android, transisi bottom sheet / dialog terasa sangat mulus.

- **Pendekatan 2: Package `image_cropper` (Native UCrop)**:
  * Membuka activity Android native bawaan `com.yalantis:ucrop`.
  * **Kelebihan**: Fitur crop natif lengkap.
  * **Kekurangan**: UI bergaya Material lawas yang terpisah dari desain Snaps, memerlukan modifikasi AndroidManifest dan dependensi Java/Kotlin ekstra.

### Langkah 2: Membangun `ImageCropEditorModal`
1. **Viewport & Masking**:
   - Menampilkan gambar di dalam `InteractiveViewer` (mendukung pan geser dengan 1 jari, pinch zoom dengan 2 jari, batas min/max scale `1.0` hingga `4.0`).
   - Lapisan atas berupa `CustomPaint` berbentuk overlay hitam semi-transparan (`#000000` alpha 0.65) dengan lubang tembus pandang lingkaran (`Rect.fromCircle`) di tengah untuk memandu posisi wajah.
   - Garis bantu kisi-kisi (*rule-of-thirds grid*) yang halus saat gambar sedang digeser.
2. **Toolbar Kontrol di Bagian Bawah**:
   - Tombol **Batal** (`Icons.close_rounded`).
   - Tombol **Reset Posisi** (`Icons.refresh_rounded`).
   - Tombol **Putar 90°** (`Icons.rotate_right_rounded`).
   - Tombol Utama **Terapkan / Potong** (tombol pill biru `AppColors.primary`).
3. **Ekstraksi Hasil Crop**:
   - Mengambil koordinat transformasi (`Matrix4`) dari `InteractiveViewer` dan memotong bitmap ke resolusi yang telah ditentukan (misal `512x512` untuk avatar).
   - Menyimpan hasil potongan ke temporary file dan mengembalikannya sebagai `XFile`.

### Langkah 3: Integrasi ke Alur Ubah Avatar Profil
- Di [`EditProfileAvatarSection`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/components/edit_profile_avatar_section.dart):
  ```dart
  final picked = await MediaUploadService.instance.pickSingleImage(source: source);
  if (picked != null && mounted) {
    // Buka crop editor modal
    final croppedFile = await ImageCropEditorModal.show(
      context: context,
      imageFile: File(picked.path),
      cropStyle: CropStyle.circle, // 1:1 circle mask untuk avatar
    );
    
    if (croppedFile != null) {
      // Unggah foto hasil crop yang sudah terpusat rapi
      await _uploadAvatar(croppedFile);
    }
  }
  ```

---

## 4. Questions for Reviewer (Harus Dijawab Reviewer)

> ❓ **Pertanyaan 1**: Apakah kamu lebih menyukai **In-App Pure Flutter Crop Modal** (desain modern 100% menyatu dengan UI Snaps, tanpa resiko build Gradle) atau memakai **Native Android Activity (`image_cropper`)**?
> - **Rekomendasi**: Pure Flutter In-App Modal karena transisinya instan, styling senada dengan Snaps, dan tidak mengubah konfigurasi Gradle native.

> ❓ **Pertanyaan 2**: Pada tahap awal rilis ini, apakah fitur crop difokuskan utama untuk **Foto Profil Avatar (1:1 Circular/Square Lock)**, atau sekaligus untuk **Foto Postingan Feed (Rasio Bebas/16:9/4:3)**?
> - **Rekomendasi**: Prioritas utama pada Foto Profil Avatar (di mana keluhan wajah terpotong paling sering terjadi), lalu dikembangkan opsi preset rasio untuk foto postingan feed.

---

## 5. Definition of Done (DoD)
- [x] Tersedia modal interaktif saat user memilih foto profil, memungkinkan user menggeser (*pan*) dan memperbesar/memperkecil (*zoom*) foto sebelum disimpan (`ImageCropEditorModal`).
- [x] Terdapat panduan visual lingkaran (*circular mask*) agar user tahu persis bagian mana yang akan tampil sebagai avatar, disertai rule-of-thirds grid saat disentuh.
- [x] Tombol rotasi 90°, flip horizontal, dan reset posisi bekerja dengan benar.
- [x] Hasil crop diekspor dengan kompresi optimal dan diunggah ke Supabase Storage.
- [x] Foto profil yang telah di-crop tampil simetris dan rapi di seluruh layar aplikasi.
- [x] Menggunakan Pure Flutter In-App Modal (Image 2 style) menggantikan UI native uCrop yang kaku (Image 1).
- [x] Lulus pengujian analisis kode `flutter analyze` dengan 0 error.
