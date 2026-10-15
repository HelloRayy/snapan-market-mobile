# [SNAPS-83] feat(activity): redesign tab notifikasi aktivitas pengguna & broadcast pengumuman

> **Ticket Metadata**:
> - **Issue Key**: SNAPS-83
> - **Issue ID**: `6138e245-6b1b-450c-aa8c-dcc9a988fa28`
> - **Project ID**: `4c2b9a79-0524-4f27-bc85-5df40b54fc5b`
> - **Domain**: `activity / notifications / broadcast / timeline`
> - **Status**: DONE (Implemented & Verified with Unit Tests)

---

## 1. Problem Statement & Root Cause

1. **Waktu Notifikasi Selalu "Baru saja" (Hardcoded)**:
   - Field `created_at` dari Supabase tidak diparsing sama sekali di model `ActivityNotification`. Nilai `timeAgo` di-hardcode mati ke `'Baru saja'`, membuat notifikasi berminggu-minggu lalu tampak seperti baru dikirim beberapa detik lalu.
2. **Judul Pengumuman/Notifikasi Terpotong / Hilang**:
   - Komponen `ActivityItemTile` mengabaikan `notification.title`, langsung menampilkan pengirim lalu loncat ke pesan cuplikan `message`. User tidak dapat membedakan mana pengumuman resmi berkepentingan tinggi dengan notifikasi biasa.
3. **Tombol Tindakan (CTA) Tidak Hadir di Tile**:
   - Meskipun data action (`action_type`, `action_url`, `action_button_label`) tersedia di database, user harus membuka notifikasi atau menebak-nebak tanpa adanya tombol aksi langsung di tile.
4. **Linimasa Datar Tanpa Pengelompokan (Grouping)**:
   - Seluruh daftar notifikasi digabung dalam satu list panjang tanpa pemisah tanggal (*Hari Ini*, *Kemarin*, *Minggu Ini*, *Lebih Lama*).
5. **Ketiadaan Tab Filter "Pengumuman"**:
   - Tab filter hanya memiliki *Semua*, *Pesanan COD*, dan *Interaksi*. Pengumuman resmi sekolah/admin terselip di dalam tab *Semua*.

---

## 2. Implementasi & Solusi

### A. Dynamic Timestamp & Timeline Grouping
- Menambahkan field `final DateTime? createdAt;` pada [`ActivityNotification`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/activity/models/activity_notification_model.dart).
- Menambahkan fungsi helper `formatRelativeTime(DateTime dt)` yang menghasilkan representasi waktu relatif bahasa Indonesia akurat:
  - `< 60 detik` ➔ `"Baru saja"`
  - `< 60 menit` ➔ `"Xm lalu"`
  - `< 24 jam (hari yang sama)` ➔ `"Xj lalu"`
  - `Hari kemarin` ➔ `"Kemarin"`
  - `< 7 hari` ➔ `"Xh lalu"`
  - `> 7 hari` ➔ `"D MMM"` (misal: `"12 Okt"` atau `"15 Agu 2024"`)
- Menambahkan enum `ActivityTimelineGroup` (`today`, `yesterday`, `thisWeek`, `older`) dengan getter otomatis `timelineGroup`.

### B. Redesain Tile `ActivityItemTile`
- Tampilan sender badge adaptif Light/Dark mode.
- Render judul tebal + badge pill `PENGUMUMAN` (`#EEF0FF` / `#3D38F5`) untuk tipe sistem/broadcast resmi sekolah.
- Tombol aksi interaktif inline (**CTA Button**) di bawah pesan cuplikan jika memiliki aksi (seperti *"Perbarui Aplikasi"*, *"Buka Tautan"*, atau label kustom admin).
- Support Dark Mode penuh dengan token warna adaptif `AppColors`.

### C. Redesain Tab & Linimasa di `ActivityScreen`
- Menambahkan tab filter **"Pengumuman"** (indeks 1) di bar kategori dengan horizontal scrollable container anti-overflow.
- Mengelompokkan item dengan *Timeline Section Headers* (HARI INI, KEMARIN, MINGGU INI, LEBIH LAMA).
- Menambahkan fungsionalitas `markSingleNotificationAsRead` di `SupabaseSocialService` dan `SupabaseService` sehingga saat notifikasi atau tombol aksi diklik, status dibaca langsung tersinkron ke Supabase dan UI lokal secara reaktif.

---

## 3. Berkas yang Diubah / Dibuat

| Berkas | Perubahan |
| :--- | :--- |
| [`lib/features/activity/models/activity_notification_model.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/activity/models/activity_notification_model.dart) | Parsing `created_at`, kalkulasi waktu dinamis, enum `ActivityTimelineGroup`. |
| [`lib/features/activity/components/activity_item_tile.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/activity/components/activity_item_tile.dart) | Tampilkan judul, badge `PENGUMUMAN`, inline CTA action button, dark mode adaptif. |
| [`lib/features/activity/screens/activity_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/activity/screens/activity_screen.dart) | Tab filter "Pengumuman", timeline sections flattening, mark single read. |
| [`lib/core/services/supabase/supabase_social_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/supabase/supabase_social_service.dart) | Penambahan method `markSingleNotificationAsRead`. |
| [`lib/core/services/supabase_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/supabase_service.dart) | Delegasi `markSingleNotificationAsRead`. |
| [`test/activity_notification_redesign_test.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/test/activity_notification_redesign_test.dart) | Unit test verifikasi parsing tanggal, relative time, dan timeline categorization. |

---

## 4. Definition of Done (DoD) & Verifikasi

- [x] Tanggal notifikasi tidak lagi selalu "Baru saja", melainkan menampilkan waktu dinamis asli.
- [x] Judul pengumuman dan badge pill `PENGUMUMAN` tampil jelas di daftar.
- [x] Tombol aksi CTA inline hadir di kartu jika pengumuman memiliki action.
- [x] Daftar dikelompokkan berdasarkan seksi linimasa (Hari Ini, Kemarin, Minggu Ini, Lebih Lama).
- [x] Tab filter "Pengumuman" berfungsi memfilter pengumuman sistem/sekolah.
- [x] `flutter analyze` pada modul terkait lulus dengan **0 errors/warnings**.
- [x] Unit test `test/activity_notification_redesign_test.dart` lulus 100%.
