# [SNAPS-70] fix(notification): sometimes button pada notification tidak muncul

> **Ticket Metadata**:
> - **Plane ID**: `ebb3d674-5c69-4674-91d9-5594510cb174`
> - **Sequence**: SNAPS-70
> - **Priority**: HIGH
> - **State Group**: started / in_progress (Ticket)
> - **Domain**: `notification / broadcast / action_button / fcm / database`

---

## 1. Problem Statement & User Context
- **Deskripsi Masalah User (Plane.so)**:
> *"admin sudah kirim broadcast notification dengan button, notif berhasil dikirim. namun tanpa button, padahal jelas sudah di set untuk url dan btn label nya"*

- **Akar Masalah Teknis**:
  1. **Hilangnya `action_button_label` di Database Insert**:
     Pada [`src/admin/services/adminService.ts`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/src/admin/services/adminService.ts#L790), objek yang di-insert ke tabel Supabase `notifications` HANYA menyertakan:
     ```ts
     {
       user_id: u.id,
       actor_id: payload.adminId || null,
       type: 'system',
       title: payload.title,
       message: payload.message,
       action_url: payload.actionUrl || null,
       action_type: payload.actionType || 'none',
       is_read: false,
     }
     ```
     Kolom `action_button_label` **TIDAK PERNAH DISIMPAN** ke database!
     Akibatnya:
     - Ketika siswa membuka notifikasi dari daftar aktivitas di dalam aplikasi ([`broadcast_detail_modal.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/activity/components/broadcast_detail_modal.dart)), `notification.actionButtonLabel` selalu bernilai `null`.
     - Ketika Supabase Realtime menembakkan record ke client, payload record tidak membawa `action_button_label`.
  2. **Android FCM Native Notification Tidak Menampilkan Action Button**:
     Di [`src/admin/services/adminFcmService.ts`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/src/admin/services/adminFcmService.ts), payload yang dikirim ke Google FCM menyertakan blok `notification: { title, body }`.
     Ketika aplikasi di background atau ditutup, OS Android merender notifikasi menggunakan **Google Play Services bawaan**. Notifikasi native Android dari blok `notification` FCM standar **TIDAK MENDUKUNG interactive action buttons** kecuali didelegasikan ke data-only payload atau diproses oleh local notification builder.
     Saat background handler memeriksa `if (message.notification != null) return;`, pembuatan action button lokal dilewati, sehingga notifikasi di status bar tidak memiliki tombol aksi.
  3. **Inkonsistensi State Button Modal**:
     Pada [`broadcast_detail_modal.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/activity/components/broadcast_detail_modal.dart), tombol hanya ditampilkan jika `actionType != 'none'`, namun label tombol jatuh ke fallback kaku jika `actionButtonLabel` bernilai `null` atau kosong.

---

## 2. Target File Scope (Interface-First Coupling)
> Rujukan arsitektur berdasarkan `AGENT_MANIFEST.md`:

| Peran File | Path File di Repositori | Keterangan Peran |
| :--- | :--- | :--- |
| **Admin Service (Web)** | [`src/admin/services/adminService.ts`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/src/admin/services/adminService.ts) | Menyimpan `action_button_label` ke tabel Supabase `notifications` dan sinkronisasi batch insert |
| **Admin FCM Service (Web)** | [`src/admin/services/adminFcmService.ts`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/src/admin/services/adminFcmService.ts) | Memformat payload data FCM dan memastikan action label terkirim konsisten ke perangkat |
| **Notification Service (Flutter)** | [`lib/core/services/global_notification_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/global_notification_service.dart) | Membaca `action_button_label` dari FCM/Realtime dan membangun action button di status bar Android |
| **Broadcast Detail Modal (Flutter)** | [`lib/features/activity/components/broadcast_detail_modal.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/activity/components/broadcast_detail_modal.dart) | Merender tombol aksi dinamis di modal broadcast aktivitas pengguna |
| **Activity Notification Model (Flutter)** | [`lib/features/activity/models/activity_notification_model.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/activity/models/activity_notification_model.dart) | Parser model deserialisasi field `action_button_label` dari JSON/Database |

---

## 3. Step-by-Step Technical Approach (Untuk AI Agent Eksekutor)

### Langkah 1: Migrasi Database / Kolom `action_button_label`
1. Pastikan tabel `public.notifications` memiliki kolom `action_button_label text`:
   ```sql
   ALTER TABLE public.notifications 
   ADD COLUMN IF NOT EXISTS action_button_label text;
   ```
2. Pada [`src/admin/services/adminService.ts`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/src/admin/services/adminService.ts#L790), tambahkan field `action_button_label` ke dalam objek batch insert:
   ```ts
   const rows = users.map((u) => ({
     user_id: u.id,
     actor_id: payload.adminId || null,
     type: 'system',
     title: payload.title,
     message: payload.message,
     action_url: payload.actionUrl || null,
     action_type: payload.actionType || 'none',
     action_button_label: payload.actionButtonLabel || null,
     is_read: false,
   }));
   ```

### Langkah 2: Pemrosesan Action Buttons pada Status Bar Android (FCM & Local Notif)
1. Di [`lib/core/services/global_notification_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/global_notification_service.dart):
   - Di `_showOsNotification`: pastikan pengecekan tombol aksi tidak hanya bergantung pada `action_type == 'external_url'`, tapi juga mendukung `action_type == 'update_app'` dan `action_type == 'post_link'`.
   - Di background FCM handler (`_firebaseMessagingBackgroundHandler`): jika pesan memiliki `action_type != 'none'`, pastikan tombol aksi (`AndroidNotificationAction`) selalu diinjeksi ke notification details dengan label fallback cerdas jika label kustom tidak diisi (`'Kunjungi Tautan'`, `'Perbarui Aplikasi'`, atau `'Lihat Postingan'`).
   - Di handler foreground `onMessage.listen`: pastikan `fakeNotif` membaca `action_button_label` dan meneruskannya ke `_showOsNotification` serta banner mengambang.

### Langkah 3: Render Button di In-App Broadcast Detail Modal
Di [`lib/features/activity/components/broadcast_detail_modal.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/activity/components/broadcast_detail_modal.dart):
- Validasi rendering: tombol ditampilkan jika `hasAction` bernilai `true` (`actionType != 'none'` dan `(actionUrl.isNotEmpty || actionType == 'update_app')`).
- Teks tombol:
  ```dart
  final buttonText = (notification.actionButtonLabel?.trim().isNotEmpty == true)
      ? notification.actionButtonLabel!.trim()
      : (actionType == 'update_app'
          ? 'Perbarui Aplikasi Sekarang'
          : actionType == 'post_link'
              ? 'Lihat Postingan Terkait'
              : 'Kunjungi Tautan Terkait');
  ```

---

## 4. Key Decisions & Questions Needed
- ❓ **Apakah kolom `action_button_label` sudah ada di database Supabase?**
  Perlu dijalankan `ALTER TABLE notifications ADD COLUMN IF NOT EXISTS action_button_label text;` jika belum tersedia, agar batch insert tidak gagal.
- ❓ **Perilaku Tombol Status Bar Android vs Modal In-App:**
  Apakah tombol di status bar OS dan tombol di modal in-app harus menampilkan teks kustom yang persis sama? (Ya, disinkronkan dari field `action_button_label`).

---

## 5. Definition of Done (DoD)
- [x] Arsitektur FCM diperbarui: pengiriman broadcast ber-tombol menggunakan Data-Only message sehingga background message listener di HP Android membangkitkan notifikasi lokal dengan tombol aksi interaktif (`AndroidNotificationAction`).
- [x] Tombol aksi muncul dengan label kustom di notifikasi status bar Android ketika notifikasi diterima via FCM atau Realtime.
- [x] Tombol aksi muncul dengan label kustom di modal detail pengumuman in-app (`broadcast_detail_modal.dart`).
- [x] Jika label kustom tidak diisi admin, sistem memberikan label fallback yang relevan sesuai jenis aksi (`'Kunjungi Tautan'`, `'Perbarui Aplikasi'`, `'Lihat Postingan'`), dan tombol tetap muncul selama ada URL/tipe aksi yang valid.
- [x] `npm run build` dan `flutter analyze` berjalan sukses tanpa error.
