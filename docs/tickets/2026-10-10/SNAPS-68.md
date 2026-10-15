# [SNAPS-68] fix(broadcast): Pencegahan Notifikasi Susulan Kosong 'Pengumuman Resmi'

> **Ticket Metadata**:
> - **Plane ID**: `e791fff1-3aa4-45cd-8aeb-12a6d0a7f5cc`
> - **Sequence**: SNAPS-68
> - **Priority**: HIGH
> - **State Group**: unstarted (Ticket)
> - **Domain**: `push_notification / fcm / broadcast / realtime`

---

## 1. Problem Statement & User Context
- **Deskripsi Masalah User**:
> Setelah admin mengirim pesan broadcast dari Admin Portal, siswa/perangkat kadang menerima notifikasi susulan bertuliskan *"Pengumuman Resmi"* dengan deskripsi kosong (`no desc`), padahal admin tidak pernah mengirim pesan tersebut.

- **Akar Masalah Teknis**:
  1. Terjadi **double-dispatch** notifikasi antara Google FCM v1 (push gateway) dan Supabase Realtime WebSocket listener.
  2. Saat aplikasi HP berada di background atau saat payload FCM raw diterima tanpa struktur `notification.title`, background message handler di Flutter (`_firebaseMessagingBackgroundHandler` di `lib/core/services/global_notification_service.dart`) mengeksekusi nilai fallback default:
     ```dart
     final title = message.notification?.title ?? message.data['title'] ?? 'Pengumuman Resmi';
     final body = message.notification?.body ?? message.data['message'] ?? '';
     ```
  3. Handler memanggil `FlutterLocalNotificationsPlugin().show(...)` dengan `body: ''` (kosong), sehingga memunculkan notifikasi "hantu" di status bar Android.
  4. Riwayat token FCM di tabel `user_fcm_tokens` menyimpan token usang/duplikat per user yang memicu pengiriman ganda ke perangkat yang sama.

---

## 2. Target File Scope (Interface-First Coupling)
> Rujukan arsitektur berdasarkan `AGENT_MANIFEST.md`:

| Peran File | Path File di Repositori | Keterangan Peran |
| :--- | :--- | :--- |
| **Notification Service (Flutter)** | [`lib/core/services/global_notification_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/global_notification_service.dart) | Background FCM handler, filtering payload kosong, dan deduplikasi OS status bar |
| **FCM Gateway Service (Web Admin)** | [`src/admin/services/adminFcmService.ts`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/src/admin/services/adminFcmService.ts) | Menembakkan payload FCM v1 dengan flag deduplikasi dan struktur data standar |
| **Admin Service (Web Admin)** | [`src/admin/services/adminService.ts`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/src/admin/services/adminService.ts) | Mengelola query target penerima dan token unik dari `user_fcm_tokens` |
| **Activity Screen (Flutter)** | [`lib/features/activity/screens/activity_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/activity/screens/activity_screen.dart) | Realtime listener event notifikasi in-app agar tidak bentrok dengan push OS |

---

## 3. Step-by-Step Technical Approach (Untuk AI Agent Eksekutor)

### Langkah 1: Filtering & Validasi di `_firebaseMessagingBackgroundHandler`
Di [`lib/core/services/global_notification_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/global_notification_service.dart):
- Jangan pernah memicu `_showOsNotification` jika teks pesan (`body`) kosong atau hanya memuat spasi kosong.
- Tambahkan pengecekan:
  ```dart
  final rawTitle = message.notification?.title ?? message.data['title'];
  final rawBody = message.notification?.body ?? message.data['message'];
  
  // Jika pesan kosong atau data tidak valid, abaikan agar tidak memicu notifikasi hantu
  if (rawBody == null || rawBody.trim().isEmpty) {
    debugPrint('[FCM Background] Abaikan pesan: payload body kosong.');
    return;
  }
  ```
- Jika OS Android sudah menangani blok `notification:` secara otomatis, jangan tampilkan `FlutterLocalNotificationsPlugin` secara redundan untuk pesan bertipe sama.

### Langkah 2: Normalisasi Payload FCM di Admin Portal
Di [`src/admin/services/adminFcmService.ts`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/src/admin/services/adminFcmService.ts):
- Pastikan field `title` dan `body/message` selalu di-trim dan tidak pernah dikirim jika kosong.
- Tambahkan `collapse_key: 'snaps_broadcast'` di payload Android agar FCM menimpa pesan yang sama dan tidak memicu antrian bertumpuk.

### Langkah 3: Deduplikasi Token FCM Per Device
Di query [`src/admin/services/adminService.ts`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/src/admin/services/adminService.ts):
- Lakukan `Array.from(new Set(tokens))` sebelum memanggil `sendPushNotificationToTokens` agar 1 token perangkat tidak dikirimkan 2x dalam satu batch siaran.

---

## 4. Key Decisions & Questions Needed
- ❓ Apakah admin menghendaki adanya toggle *"Hanya Push OS"* vs *"Push OS + In-App Dialog"* pada form broadcast?
- ❓ Apakah token FCM lama yang tidak aktif lebih dari 30 hari perlu otomatis di-cleanup via Supabase Cron?

---

## 5. Definition of Done (DoD)
- [x] Pengiriman broadcast dari Admin Portal hanya memunculkan tepat **1 notifikasi** di HP Android (tidak ada notifikasi kedua/susulan).
- [x] Tidak ada lagi notifikasi bersubjek default *"Pengumuman Resmi"* dengan deskripsi kosong di status bar Android.
- [x] Filter token FCM unik memastikan tidak ada duplikasi pesan per token perangkat (`Set<string>`).
- [x] Background handler Flutter memfilter dan menolak menampilkan notifikasi lokal jika body pesan kosong atau sudah ditangani secara native oleh sistem OS Android.
