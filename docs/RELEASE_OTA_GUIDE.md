# Standar Operasional Prosedur (SOP) Rilis In-App Update (OTA) & APK Publik
**Snapan Market Mobile (Snaps)** — Solusi Anti-Downgrade & Anti-Looping (SNAPS-56)

---

## 📌 1. Prinsip Utama Versioning Android di Snaps

Sistem operasi Android (terutama Android 12, 13, 14, 15 pada Samsung OneUI, MIUI, ColorOS) menerapkan **Downgrade Protection**:
> **Android akan menolak secara diam-diam (silent reject) instalasi APK jika:**  
> `versionCode` APK baru $\le$ `versionCode` APK yang sedang terpasang di HP.

### Aturan Skema `versionCode`
1. Karena rilis v1.0.19 sebelumnya sempat menggunakan `--split-per-abi`, HP berarsitektur 64-bit (`arm64-v8a`) telah menyimpan `versionCode = 2021`.
2. Oleh karena itu, seluruh rilis universal berikutnya **DIWAJIBKAN** memiliki `versionCode >= 2000`.
3. Di `android/app/build.gradle.kts`, kalkulasi `versionCode` telah diproteksi dengan guard:
   ```kotlin
   val baseCode = flutter.versionCode
   versionCode = if (baseCode < 2000) (2000 + baseCode) else baseCode
   ```
4. Di tabel Supabase `app_versions`, kolom `version_code` **harus selalu sama persis** dengan `versionCode` biner APK (misal: `2024`, `2025`, dst).

---

## 🚀 2. Prosedur Rilis Cepat (Otomatis & Satu Perintah)

Gunakan script root `update_release.sh` yang sudah dilengkapi auto-tagging, GitHub release hosting, dan inject REST API Supabase:

```bash
./update_release.sh <VERSION_NAME> <VERSION_CODE> "<CHANGELOG>"
```

### Contoh:
```bash
./update_release.sh 1.0.22 24 "Penyempurnaan flow download OTA anti-stuck & perbaikan downgrade protection versionCode"
```

### Apa yang Dilakukan Script Ini Secara Otomatis:
1. Memperbarui `version: 1.0.22+24` di `pubspec.yaml`.
2. Mengompilasi APK release universal: `flutter build apk --release --no-pub`.
3. Mengkalkulasi `versionCode = 2024` di Android binary.
4. Melakukan Git commit, membuat tag `v1.0.22`, dan push ke branch `main`.
5. Mengunggah `app-release.apk` ke GitHub Releases.
6. Mendaftarkan versi baru ke database Supabase `app_versions` dengan `version_code: 2024`, `is_mandatory: true`, dan `is_active: true`.

---

## 📋 3. Checklist Pre-Release Verification

Sebelum membagikan tautan rilis ke publik atau menyebarkan APK:

- [ ] **Cek Binary Badging**:
  Jalankan verifikasi untuk memastikan `versionCode >= 2024`:
  ```bash
  $ANDROID_HOME/build-tools/35.0.0/aapt dump badging build/app/outputs/flutter-apk/app-release.apk | grep -E "versionCode|versionName"
  ```
- [ ] **Cek Supabase Record**:
  Buka Supabase Dashboard > Table Editor > `app_versions`, pastikan baris teratas memiliki:
  - `version_code`: `2024` (atau sesuai rilis)
  - `version_name`: `1.0.22`
  - `is_mandatory`: `true`
  - `is_active`: `true`
- [ ] **Uji Update di HP Fisik (End-to-End)**:
  - Buka aplikasi versi lama di HP.
  - Dialog update akan muncul secara instan.
  - Klik **Perbarui Sekarang**.
  - Bar progres menampilkan animasi berjalan hingga 100%.
  - Pop-up Android *"Apakah Anda ingin memperbarui aplikasi ini?"* muncul -> Tap **Update**.
  - Buka kembali aplikasi -> **Aplikasi langsung membuka tampilan feed terbaru tanpa looping bottom sheet!**

---

## 🛠️ 4. Panduan Troubleshooting Cepat

| Gejala Masalah | Penyebab | Solusi |
|---|---|---|
| **Stuck di 0% saat klik download** | Handshake SSL CDN GitHub lambat atau jaringan provider throttling. | UI kini menampilkan indeterminate pulse. Jika tetap macet > 30 detik, tap tombol *Buka di Browser* yang otomatis tersedia. |
| **Aplikasi auto-close setelah klik update, tapi saat dibuka muncul lagi popup (Looping)** | `versionCode` APK baru lebih rendah atau sama dengan APK di HP. | Pastikan `versionCode` di APK baru dan Supabase bernilai `> 2021` (gunakan format `2024+`). |
| **Error: Izin pemasangan aplikasi belum aktif** | Android memblokir instalasi APK pihak ketiga dari dalam app. | Buka Pengaturan HP > Aplikasi > Snaps > Izinkan "Instal aplikasi tidak dikenal". |
