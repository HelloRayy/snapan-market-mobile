# [SNAPS-39] Rilis Base Version v1.0.18: Kumulatif Perbaikan & Peningkatan Stabilitas dari v1.0.3

> **Ticket Metadata**:
> - **Plane ID**: `10273906-2b56-4142-bf30-4fb29b3f3be7`
> - **Sequence**: SNAPS-39
> - **Priority**: URGENT
> - **State Group**: unstarted
> - **Domain**: `release / build / ota`

---

## 1. Problem Statement & User Context
- **Deskripsi Asli Plane**:
> Please read this first. Apakah ssemua dari rangkuman ini sudah ada di apps kita? dan kita bisa releasse ini ke public sebagai BETA VERSION..? jika masi ada issue untuk release ke beta version, please tunda dan berikan beberapa root cause nya. analisa edge case yang mungkin out of scope dari rangkuman ini. berikan berbagai potensi yang Out of Scope yang mungkin saya kelewatan. Kita harus release beta layaknya Stable Release. note: JANGAN OVERCLAIM, JIKA MEMANG BELUM. BILANG BELUM, DAN KITA EVALUASI. Daftar rangkuman peningkatan dan perbaikan kumulatif dari v1.0.3 menuju rilis publik baru yang benar-benar stabil (Base Version v1.0.18+20): This is Crucial Phase dari development ini. Pastikan semua berjalan lancar, beirkan ke saya hasil report, buatkan claim dari tim developer untuk release beta version ini. All feature works, OTA In update works, Notification works, dan berbagai macam feature crucial lainnya. Lakukan audit dulu, Goodluck. 1. Sistem Notifikasi, FCM, & Background Engine    Realtime Lifecycle Sync: Memperbaiki listener Supabase Realtime agar ter-subscribe ulang saat login dan badge unread langsung ter-fetch.    Auto-Sync Token on Login: Token perangkat langsung tersimpan ke user_fcm_tokens saat login tanpa perlu aksi manual.    Validasi Token Transparan: Bottom sheet panduan notifikasi menampilkan status akun dan mencegah false-positive.    Dual Payload FCM: Mengirim payload notification dan data agar notifikasi tembus saat HP mati atau Doze mode.    Auto-Pruning Expired Tokens: Web Admin otomatis membersihkan token UNREGISTERED/NOT_FOUND.    AndroidNotificationAction: Tombol aksi kustom di notification tray status bar.    Expandable BigTextStyle: Notifikasi pengumuman panjang dapat dibuka-tutup langsung dari tray Android. 2. Direct Chat & Pesan    Header chat sejajar kiri dengan 2 kolom (Username & Kelas).    Lebar bubble chat proporsional dan tidak memenuhi layar.    Input field chat konsisten dengan kolom komentar feed.    Status unread tersinkronisasi akurat dengan Supabase. 3. Feed, Komentar, & Polling    Penyempurnaan comment tree Instagram-style (tidak reset hierarki saat back).    Tata letak tombol Balas & Suka sejajar rapi.    Fitur hapus komentar dengan sheet konfirmasi & optimistic sync.    Interactive polling single-choice dengan 1-tap vote change & persentase rapi.    Media lightbox full-width edge-to-edge. 4. UI, Avatar, & Sistem Keamanan    Standardisasi avatar default silhouette abu-abu netral di mobile dan web admin.    Tipografi Apple SF Pro dan sistem icon Cupertino konsisten.    Drawer push motion 285px halus dengan background dimming.    Deteksi akun suspended saat login dengan detail alasan dan durasi.    Single active device lock. 5. Langkah Rilis Base Version    Bump version di pubspec.yaml ke 1.0.18+20.    Build APK release bersih: flutter build apk --release.    Upload rilis APK ke GitHub Releases.    Daftarkan di tabel app_versions Supabase sebagai versi aktif.

- **Akar Masalah Teknis**: Pelepasan Base Version v1.0.18+20 sebagai rilis publik BETA stabil. Seluruh perbaikan kumulatif (Realtime sync, FCM tray action, direct chat layout, polling, OTA cache auto-clean, single device lock) harus diaudit secara menyeluruh dan tidak boleh overclaim.

---

## 2. Target File Scope (Interface-First Coupling)
> Rujukan arsitektur berdasarkan `AGENT_MANIFEST.md`:

| Peran File | Path File di Repositori | Keterangan Peran |
| :--- | :--- | :--- |
| **Config & Versioning** | [`pubspec.yaml`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/pubspec.yaml) | Nomor versi aplikasi (wajib bump ke 1.0.18+20) |
| **Automated Release Script** | [`scripts/auto_release.sh`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/scripts/auto_release.sh) | Script orkestrasi build APK, GitHub release, dan injeksi OTA Supabase |
| **Update Service** | [`lib/core/services/app_update_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/app_update_service.dart) | Pengecekan versi update in-app dan pembersihan file APK installer usang |
| **Update Bottom Sheet** | [`lib/core/components/update_info_bottom_sheet.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/components/update_info_bottom_sheet.dart) | UI modal informasi versi baru dan progress bar unduhan |
| **Notification Engine** | [`lib/core/services/global_notification_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/global_notification_service.dart) | Channel FCM, expandable big text, dan action tray buttons |

---

## 3. Step-by-Step Technical Approach (Untuk AI Agent Eksekutor)
1. Jalankan audit komprehensif pada fitur-fitur kritis (Auth NIS, Feed Polling, Direct Messages, FCM Notification, OTA Update).
2. Verifikasi pembersihan file cache installer (.apk) di direktori aplikasi agar storage siswa tidak membengkak.
3. Bump nomor versi di pubspec.yaml menjadi 1.0.18+20.
4. Eksekusi rilis menggunakan ./scripts/auto_release.sh 1.0.18 20 "Rilis Beta v1.0.18".
5. Verifikasi bahwa entri baru masuk ke tabel app_versions Supabase dan memicu popup OTA pada versi terdahulu.

---

## 4. Key Decisions & Questions Needed
- ❓ Apakah build release ini ditujukan untuk staging testing internal OSIS terlebih dahulu atau langsung broad release ke seluruh siswa?
- ❓ Apakah fitur mandatory update diaktifkan (is_mandatory: true) untuk memaksa versi di bawah 1.0.18 melakukan update?

---

## 5. Definition of Done (DoD)
- [ ] Build APK release lolos tanpa error kompilasi (flutter build apk --release).
- [ ] Asset APK terunggah di GitHub Releases dan metadata tercatat di tabel app_versions.
- [ ] In-App update popup muncul dan proses unduh serta install berhasil tanpa crash.

