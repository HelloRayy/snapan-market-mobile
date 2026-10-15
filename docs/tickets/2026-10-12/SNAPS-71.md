# [SNAPS-71] feat(notification): add notif ketika ada dm masuk

> **Ticket Metadata**:
> - **Plane ID**: `31f4216d-9937-428b-bf6e-d0be06a51d1b`
> - **Sequence**: SNAPS-71
> - **Priority**: HIGH
> - **State Group**: in_progress (Implementation Completed)
> - **Domain**: `push_notification / dm / fcm`

---

## 1. Problem Statement & User Context
- **Deskripsi Masalah di Plane.so**:
  > *"ketika user memiliki pesan masuk, dia tidak diberikan notifikasi terhadap siapa pengirim pesan. UX jelek karna tidak tau kalo ada pesanan masuk / misal dia lagi jualan"*

- **Akar Masalah Teknis**:
  1. **Absennya Trigger Notifikasi DM di Backend**: Saat pesan baru dikirim melalui [`supabase_chat_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/supabase/supabase_chat_service.dart), record hanya masuk ke tabel `direct_messages`. Tidak ada Postgres Database Webhook / Edge Function yang mengirimkan payload FCM ke token HP penerima.
  2. **Supabase Realtime Terbatas pada State Aktif**: Jika penerima sedang tidak membuka aplikasi atau layar HP terkunci, koneksi WebSocket Realtime terputus sehingga penerima sama sekali tidak mengetahui ada pesan masuk hingga membuka aplikasi secara manual.
  3. **Format Notifikasi DM Belum Terpetakan di Client**: Di [`global_notification_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/global_notification_service.dart), handler belum menangani tipe payload `type: 'dm'` untuk langsung mengarahkan user ke `ChatConversationScreen(conversationId)`.

---

## 2. Reviewer Decisions & Technical Consensus

| Pertanyaan | Keputusan Reviewer / Tim | Implementasi |
| :--- | :--- | :--- |
| **Preview Teks Pesan** | **YA, Tampilkan Cuplikan Teks** | Teks dipotong rapi maksimal 60 karakter (`...`) untuk menyeimbangkan privasi dan UX kontekstual |
| **Arsitektur Pengiriman** | **Opsi A: Database Webhook / Trigger -> Supabase Edge Function** | Menggunakan Edge Function `send-dm-push` + Database Webhook asynchronous (`net.http_post` / Webhooks) |
| **Mitigasi Tech Debt** | **Adopsi Penuh Mitigasi 1 - 4** | Caching token OAuth2 in-memory, multi-device fan-out, in-room suppression, auto-purge invalid FCM tokens |

---

## 3. Target File Scope & Changes Implemented

| Peran File | Path File di Repositori | Keterangan Perubahan |
| :--- | :--- | :--- |
| **Supabase Edge Function** | [`supabase/functions/send-dm-push/index.ts`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/supabase/functions/send-dm-push/index.ts) | Menangani webhook DB, fetch token FCM penerima (`user_fcm_tokens`), cache Google OAuth2 token, kirim via FCM HTTP v1, dan auto-purge token invalid (`UNREGISTERED`, `NOT_FOUND`) |
| **SQL Migration & Trigger** | [`supabase/migrations/supabase_snaps71_dm_push_notification.sql`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/supabase/migrations/supabase_snaps71_dm_push_notification.sql) | DDL trigger `AFTER INSERT ON direct_messages` yang memanggil Edge Function secara async |
| **Global Notification Service** | [`lib/core/services/global_notification_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/global_notification_service.dart) | Registrasi Android Channel `snaps_direct_messages` (High Priority), in-room suppression, tap deep-link ke chat room, dan in-app banner kustom |
| **Direct Messages Service** | [`lib/features/messages/services/direct_messages_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/messages/services/direct_messages_service.dart) | Melacak `activeConversationId` untuk suppression, serta menambahkan `getOrFetchConversation(conversationId)` |
| **Chat Conversation Screen** | [`lib/features/messages/screens/chat_conversation_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/messages/screens/chat_conversation_screen.dart) | Mengikat lifecycle layar ke `DirectMessagesService.instance.activeConversationId` (`initState` & `dispose`) |
| **Supabase Chat Service** | [`lib/core/services/supabase/supabase_chat_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/supabase/supabase_chat_service.dart) | Menambahkan fungsi `fetchConversationById(conversationId)` dengan join profil & post terkait |
| **Supabase Service Facade** | [`lib/core/services/supabase_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/supabase_service.dart) | Mengekspos delegasi `fetchConversationById(conversationId)` |

---

## 4. Cara Deploy & Aktivasi

### 1. Deploy Supabase Edge Function
Jalankan perintah berikut di terminal:
```bash
# 1. Simpan secret Firebase Service Account ke Supabase Secrets
supabase secrets set FIREBASE_SERVICE_ACCOUNT="$(cat src/admin/firebase-service-account.json)"

# 2. Deploy edge function send-dm-push
supabase functions deploy send-dm-push --no-verify-jwt
```

### 2. Pasang Trigger di Database Supabase
Buka **SQL Editor** pada Supabase Dashboard (`https://supabase.com/dashboard/project/lcwsxldnoqjdfqxqcqja/sql`) dan eksekusi skrip dari:
[`supabase/migrations/supabase_snaps71_dm_push_notification.sql`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/supabase/migrations/supabase_snaps71_dm_push_notification.sql)

Atau pasang melalui menu **Database Webhooks**:
- **Name**: `send-dm-push-on-insert`
- **Table**: `public.direct_messages`
- **Events**: `INSERT`
- **Type**: `Supabase Edge Function` (`send-dm-push`)

---

## 5. Definition of Done (DoD) Verification
- [x] **Backend Dispatch**: Supabase Edge Function `send-dm-push` siap menerima webhook insert pesan dan menembak FCM HTTP v1.
- [x] **Preview Teks Terbatas**: Pesan teks ditruncate maksimal 60 karakter dengan format elipsis (`...`).
- [x] **Identitas Pengirim**: Notifikasi mencantumkan nama lengkap pengirim atau `@username`.
- [x] **In-Room Suppression**: Jika user sedang berada di ruang chat yang sama (`activeConversationId == conversationId`), notifikasi banner dan OS notification diredam secara otomatis agar tidak spamming.
- [x] **Deep Linking**: Mengetuk notifikasi (foreground banner maupun OS status bar) langsung membuka `ChatConversationScreen(conversation)` secara akurat via `getOrFetchConversation`.
- [x] **Kualitas Kode**: Lulus verifikasi analisis Dart (`flutter analyze lib/core/services/ lib/features/messages/`) dengan **0 error dan 0 warning**.

---

## 6. Edge-Case Evaluation: 1 Device 2 Akun (Self-Learning & Tech Debt Awareness)

### Masalah yang Ditemukan saat Pengujian Developer:
> *"Ketika 1 HP memiliki Akun A dan Akun B, lalu Akun A mengirim DM ke Akun B di HP yang sama, notifikasi tidak muncul."*

### Keputusan Tim & Arsitektur: **DITOLAK / TIDAK DIIMPLEMENTASIKAN**

1. **Bukan Kebutuhan Pengguna Nyata**:
   * Kasus ini adalah ilusi pengujian developer (*testing edge-case*). Di ekosistem nyata SMKN 8 Semarang, setiap siswa menggunakan HP fisik masing-masing. Siswa A mengirim DM ke Siswa B di HP lain terbukti berfungsi normal 100%.
2. **Alasan Penolakan Demi Mencegah Tech Debt**:
   * **Potensi Bocornya Privasi Pengguna (Zombie Session)**: Jika 1 token FCM tetap dipertahankan untuk akun yang sudah logout, siswa yang meminjamkan HP ke temannya akan membocorkan cuplikan chat privat di status bar/lockscreen.
   * **Auth Session Conflict (Crash RLS)**: Jika notifikasi Akun B diklik saat layar sedang aktif membuka Akun A, deep-link akan gagal dibuka (error 403 Forbidden) karena token JWT global Flutter saat itu adalah milik Akun A.
   * **Menghindari Overengineering Prematur**: Mendukung multi-account notification menuntut perombakan total dari *Single-Account Auth* menjadi *Multi-Session Keyring Store* (seperti Instagram/Slack) yang belum menjadi ruang lingkup rilis Snaps saat ini.
3. **Prosedur Pengujian Resmi**: Pengujian notifikasi DM **wajib** dilakukan menggunakan 2 perangkat fisik berbeda (atau 1 HP fisik + 1 Web/Emulator).
