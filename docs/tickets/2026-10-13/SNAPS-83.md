# [SNAPS-83] style(notification): Redesign Notifikasi di Tab Aktivitas Pengguna

> **Ticket Metadata**:
> - **Plane Issue ID**: `4044ccee-d665-408d-aedd-6602c016f6b0`
> - **Sequence**: SNAPS-83
> - **Issue Name**: `style(notificatiom): redesign notifikasi di tab aktivitas di user.`
> - **Project**: Snaps (`143b60b2-c6f6-435a-838d-ce815b8af201`)
> - **Priority**: HIGH
> - **State Group**: `Todo` (`b76c9acb-ebbb-4155-94f2-0bc40715c611`)
> - **Domain**: `activity / notification / timeline_grouping / broadcast_tile / ui_redesign`

---

## 1. Problem Statement & Context

### Deskripsi Tiket di Plane.so
> *"user menerima / memiliki banyak sekali informasi dari annouchment / broadcast dari admin, dan ini tersimpan di page aktivitas. dengan timeline sama semua 'baru saja' padahal ini udah lama bnget notifikasi nya.*
>
> *dari segi UI: kita bisa pisahkan bebrapa misal ada headline Hari ini itu isinya khusus annouchment hari ini saja ketika di scrol kebawah ada headline kemarin dll. atau kita coba explore ui natnian aja kita mikir nanti*
>
> *fokus sekarang adalah menyaring informasi yang ditampilkan ke user, serta timeline yang asli ketika braodcast disampaikan. ketika notif broadcast, ui di aktivitas hanya menampilkan text desc saja harusnya juga menampilkan title. ini jg belum support button ui, ketika broadcast dengan button berhasil dikirim. ui aktivitas page tidak menampilkan button"*

### Temuan Audit Arsitektur Saat Ini
1. **Hardcoded Timestamp "Baru saja"**:
   - Di file [`activity_notification_model.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/activity/models/activity_notification_model.dart#L73), konstruktor `fromJson` melakukan hardcode kaku:
     ```dart
     timeAgo: 'Baru saja',
     ```
   - Properti `createdAt` (`DateTime?`) sama sekali tidak dideklarasikan pada model `ActivityNotification`. Padahal tabel Supabase `notifications` menyimpan timestamp presisi `created_at` (TIMESTAMPTZ).
   - Akibatnya, semua notifikasi (baik yang dikirim 5 menit lalu, 2 minggu lalu, maupun bulan lalu) menampilkan label yang sama persis: `• Baru saja`.

2. **Hilangnya Judul Notifikasi (`title`) pada List Tile**:
   - Di file [`activity_item_tile.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/activity/components/activity_item_tile.dart#L80-L130), baris kartu notifikasi hanya menampilkan `actorName` ("Snaps") diikuti cuplikan `notification.message`.
   - Field `notification.title` (misalnya: *"Pembaruan Versi Aplikasi v1.0.30"*, *"Jadwal Maintenance Server"*, dsb.) **sama sekali tidak dirender** pada kartu notifikasi. Pengguna kehilangan konteks inti sebelum membuka pesan.

3. **Absennya Action Button UI pada Broadcast di Tab Aktivitas**:
   - Ketika pengumuman dikirim dari dashboard admin dengan aksi interaktif (misalnya: `action_type: 'update_app'`, `external_url`, atau `post_link` dengan label tombol khusus), data `actionButtonLabel`, `actionType`, dan `actionUrl` sudah ada di database.
   - Namun di antarmuka [`activity_item_tile.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/activity/components/activity_item_tile.dart), tidak ada widget tombol/CTA sama sekali. Pengguna tidak menyadari ada aksi yang bisa diklik langsung, dan hanya bisa membuka detail lewat modal atau mengklik seluruh baris.

4. **Penyaringan Informasi Terbatas (Filter Chips)**:
   - Filter chips saat ini hanya menyediakan: `Semua` (0), `Pesanan COD` (1), dan `Interaksi` (2).
   - Pengumuman resmi dari sistem (`ActivityType.system`) tercampur di tab `Semua`, namun hilang dari tab lainnya tanpa ada tab khusus `Pengumuman` untuk melihat broadcast sekolah/admin secara terfokus.

5. **Daftar Linimasa Monolitik Tanpa Pengelompokan (Grouping)**:
   - Seluruh daftar notifikasi ditampilkan dalam satu `ListView.separated` memanjang tanpa pemisah tanggal, menyulitkan pengguna membedakan mana notifikasi baru hari ini, kemarin, minggu ini, atau yang sudah lama.

---

## 2. Target File Scope (Interface-First Coupling)

| Peran File | Path File di Repositori | Keterangan Perubahan |
| :--- | :--- | :--- |
| **Activity Notification Model** | [`lib/features/activity/models/activity_notification_model.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/activity/models/activity_notification_model.dart) | Menambahkan field `createdAt`, parsing `created_at`, helper dinamis `timeAgo`, dan kalkulator kategori pengelompokan `timelineGroup` (`Hari Ini`, `Kemarin`, `Minggu Ini`, `Lebih Lama`). |
| **Activity Item Tile (UI)** | [`lib/features/activity/components/activity_item_tile.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/activity/components/activity_item_tile.dart) | Redesain visual: menampilkan `title` tebal yang kontras, badge pengumuman resmi, cuplikan pesan rapi, dan tombol aksi (CTA Button) interaktif jika notifikasi memiliki `hasAction`. |
| **Activity Screen** | [`lib/features/activity/screens/activity_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/activity/screens/activity_screen.dart) | Menambahkan filter chip khusus `Pengumuman`, mengelompokkan notifikasi ke dalam section header linimasa tanggal (`Hari Ini`, `Kemarin`, dll.), dan menangani callback aksi tombol secara seamless. |
| **Broadcast Detail Modal** | [`lib/features/activity/components/broadcast_detail_modal.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/activity/components/broadcast_detail_modal.dart) | Menyelaraskan format timestamp tanggal dinamis (bukan string kaku) dan konsistensi tombol aksi. |
| **Global Notification Service** | [`lib/core/services/global_notification_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/global_notification_service.dart) | Memastikan instansiasi notifikasi lokal/in-flight membawa timestamp riil `createdAt: DateTime.now()`. |

---

## 3. Desain Teknis & Keputusan Arsitektur

```
┌────────────────────────────────────────────────────────┐
│               ActivityScreen (Redesign)                │
├────────────────────────────────────────────────────────┤
│ [ Semua ]  [ Pengumuman (⭐) ]  [ Interaksi ]  [ Pesanan ]│
├────────────────────────────────────────────────────────┤
│ ▼ HARI INI                                             │
│ ┌────────────────────────────────────────────────────┐ │
│ │ [Snaps Logo]  Snaps (Verified) • 15m lalu          │ │
│ │ [PENGUMUMAN] Pembaruan Aplikasi v1.0.30            │ │
│ │ Fitur baru rilis! Silakan perbarui aplikasi Anda...│ │
│ │ ┌──────────────────────┐                           │ │
│ │ │ ⬇️ Perbarui Sekarang  │                           │ │
│ │ └──────────────────────┘                           │ │
│ └────────────────────────────────────────────────────┘ │
│ ┌────────────────────────────────────────────────────┐ │
│ │ [Avatar]  @dewakoding • 2j lalu                    │ │
│ │ Mengomentari: "Keren arsitektur barunya!"          │ │
│ └────────────────────────────────────────────────────┘ │
│                                                        │
│ ▼ KEMARIN                                              │
│ ┌────────────────────────────────────────────────────┐ │
│ │ [Snaps Logo]  Snaps (Verified) • Kemarin           │ │
│ │ [PENGUMUMAN] Maintenance Server Selesai            │ │
│ │ Layanan database dan realtime telah stabil kembali.│ │
│ └────────────────────────────────────────────────────┘ │
│                                                        │
│ ▼ LEBIH LAMA                                           │
│ ┌────────────────────────────────────────────────────┐ │
│ │ ...                                                │ │
│ └────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────┘
```

### A. Pengelompokan Linimasa Dinamis (`ActivityTimelineGroup`)
Setiap notifikasi akan dievaluasi berdasarkan selisih waktu `createdAt` dengan waktu hari ini (`DateTime.now()` local timezone):
```dart
enum ActivityTimelineGroup {
  today('Hari Ini'),
  yesterday('Kemarin'),
  thisWeek('Minggu Ini'),
  older('Lebih Lama');

  final String label;
  const ActivityTimelineGroup(this.label);
}
```

Logika komputasi selisih hari:
- `diffInDays == 0` (hari kalender sama) ➔ **Hari Ini**
- `diffInDays == 1` (kemarin) ➔ **Kemarin**
- `diffInDays < 7` ➔ **Minggu Ini**
- Sisanya ➔ **Lebih Lama**

### B. Dynamic Relative Timestamp (`timeAgo`)
Format waktu dinamis cerdas:
- `< 1 menit` ➔ `"Baru saja"`
- `< 60 menit` ➔ `"${diff.inMinutes}m lalu"`
- `< 24 jam` ➔ `"${diff.inHours}j lalu"`
- `1 hari` ➔ `"Kemarin"`
- `2 - 6 hari` ➔ `"${diff.inDays}h lalu"`
- `≥ 7 hari` ➔ Format tanggal ringkas (contoh: `"12 Okt"` atau `"24 Sep"`)

### C. Redesain Komponen `ActivityItemTile`
1. **Header Row**:
   - Avatar Pengirim (Logo Snaps dengan border bulat untuk sistem, atau foto profil pengguna untuk interaksi sosial).
   - Badge aksi (Icon megaphone untuk pengumuman, heart untuk like, bubble untuk komentar, bag untuk order).
   - Nama Aktor (`Snaps` + Verified Blue Tick untuk pengumuman resmi).
   - Relative Timestamp (`• 15m lalu`).
   - Unread indicator dot (lingkaran aksen primer jika belum dibaca).
2. **Title Row (Baru)**:
   - Untuk notifikasi tipe `system` atau jika `title` memiliki nilai bermakna (bukan fallback generik), render judul dengan `FontWeight.w700`, ukuran `14.5` dp, warna `Color(0xFF0F172A)`.
   - Sertakan badge pill kecil `PENGUMUMAN` (`Color(0xFFEFF6FF)` background, `Color(0xFF1D4ED8)` text, radius 4 dp) di sebelah judul untuk identitas visual yang tajam.
3. **Body / Message Preview**:
   - Teks pesan dengan kontras optimal (`Color(0xFF475569)`), line-height `1.35`, maksimum 3 baris dengan elipsis rapi.
4. **Action Button UI (Baru)**:
   - Jika notifikasi memiliki aksi (`notif.hasAction` bernilai `true`):
     - Tampilkan tombol aksi terintegrasi di bagian bawah pesan.
     - Label tombol mengambil dari `notification.actionButtonLabel` dengan fallback intuitif (`Perbarui Aplikasi`, `Buka Tautan`, `Lihat Postingan`).
     - Ikon aksi dinamis: Download icon untuk update, Globe untuk link web, Arrow icon untuk postingan feed.
     - Menekan tombol aksi langsung memanggil `GlobalNotificationService.executeNotificationAction(context, notification)`.
     - Menekan area badan kartu di luar tombol tetap membuka modal penuh [`BroadcastDetailModal`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/activity/components/broadcast_detail_modal.dart) agar pengguna dapat membaca isi pengumuman secara komprehensif.

### D. Penambahan Filter Chips `Pengumuman`
Filter kategori di bar atas `ActivityScreen` diperluas:
- **`Semua`** (Indeks 0): Seluruh aktivitas (pengumuman, interaksi, pesanan).
- **`Pengumuman`** (Indeks 1 - Baru): Khusus notifikasi broadcast & sistem dari sekolah/admin.
- **`Interaksi`** (Indeks 2): Khusus like, komentar, mention, follow.
- **`Pesanan COD`** (Indeks 3): Khusus transaksi pesanan pasar Snaps.

---

## 4. Step-by-Step Technical Implementation Plan

### Tahap 1: Pembaharuan Model Data (`activity_notification_model.dart`)
1. Tambahkan deklarasi properti:
   ```dart
   final DateTime? createdAt;
   ```
2. Perbarui konstruktor dan `ActivityNotification.fromJson`:
   - Parse `json['created_at']` ke `DateTime.tryParse(...).toLocal()`.
   - Hitung nilai `timeAgo` secara dinamis dari `createdAt` menggunakan fungsi pembantu waktu relatif.
3. Implementasikan getter `timelineGroup`:
   ```dart
   ActivityTimelineGroup get timelineGroup {
     if (createdAt == null) return ActivityTimelineGroup.today;
     final now = DateTime.now();
     final today = DateTime(now.year, now.month, now.day);
     final itemDate = DateTime(createdAt!.year, createdAt!.month, createdAt!.day);
     final diffDays = today.difference(itemDate).inDays;
     if (diffDays <= 0) return ActivityTimelineGroup.today;
     if (diffDays == 1) return ActivityTimelineGroup.yesterday;
     if (diffDays < 7) return ActivityTimelineGroup.thisWeek;
     return ActivityTimelineGroup.older;
   }
   ```
4. Tambahkan `createdAt` ke metode `toJson` dan `copyWith`.

### Tahap 2: Redesain Kartu Aktivitas (`activity_item_tile.dart`)
1. Tambahkan penanganan tampilan `title` di atas pesan notifikasi:
   - Tampilkan judul notifikasi jika bertipe `ActivityType.system` atau `title` berbeda dari teks fallback.
   - Tambahkan chip badge `PENGUMUMAN` untuk identifikasi instan pengumuman resmi.
2. Tambahkan widget inline **Action Button**:
   - Jika `notification.hasAction` bernilai `true`:
     ```dart
     Padding(
       padding: const EdgeInsets.only(top: 8.0),
       child: SizedBox(
         height: 32.0,
         child: ElevatedButton.icon(
           onPressed: onActionTap,
           style: ElevatedButton.styleFrom(
             backgroundColor: AppColors.primary,
             foregroundColor: Colors.white,
             elevation: 0,
             padding: const EdgeInsets.symmetric(horizontal: 12.0),
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
           ),
           icon: Icon(_getActionIcon(notification.actionType), size: 14.0),
           label: Text(
             notification.actionButtonLabel?.isNotEmpty == true
                 ? notification.actionButtonLabel!
                 : _getDefaultActionLabel(notification.actionType),
             style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w700),
           ),
         ),
       ),
     )
     ```
3. Pisahkan event tap:
   - Tap tombol aksi ➔ Mengeksekusi aksi terkait (buka link / update app / buka post).
   - Tap body tile ➔ Membuka `BroadcastDetailModal` untuk sistem, atau navigasi detail untuk interaksi feed.

### Tahap 3: Implementasi Grouping & Filter di `activity_screen.dart`
1. Perbarui state `_activeTabIndex`:
   - `0: Semua`
   - `1: Pengumuman` (`n.type == ActivityType.system`)
   - `2: Interaksi` (`like, comment, mention, follow`)
   - `3: Pesanan COD` (`order`)
2. Kelompokkan data yang terfilter ke dalam `Map<ActivityTimelineGroup, List<ActivityNotification>>`:
   ```dart
   Map<ActivityTimelineGroup, List<ActivityNotification>> get _groupedNotifications {
     final map = <ActivityTimelineGroup, List<ActivityNotification>>{};
     for (final notif in _filteredNotifications) {
       final group = notif.timelineGroup;
       map.putIfAbsent(group, () => []).add(notif);
     }
     return map;
   }
   ```
3. Render list dengan section headers:
   - Tampilkan header section (`Hari Ini`, `Kemarin`, `Minggu Ini`, `Lebih Lama`) dengan tipografi clean slate (12px, font weight w700, padding vertikal seimbang).
   - Pisahkan setiap section dengan rapi tanpa visual glitch atau CLS (*Cumulative Layout Shift*).

### Tahap 4: Sinkronisasi Realtime & Global Notification Service
1. Di [`activity_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/activity/screens/activity_screen.dart), saat callback realtime `SupabaseService.instance.subscribeToNotifications` menerima payload baru:
   - Pastikan objek `ActivityNotification.fromJson(newRecord)` membawa `created_at: DateTime.now().toIso8601String()` jika record realtime belum memiliki timestamp lengkap.
   - Insert ke index `0` list notifikasi dan picu re-grouping otomatis.
2. Di [`global_notification_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/global_notification_service.dart), pastikan `fakeNotif` yang dibuat untuk in-app top banner dan OS notification menyertakan `createdAt: DateTime.now()`.

---

## 5. Definition of Done (DoD) Checklist

- [ ] **Timestamp Akurat**: Tidak ada lagi tulisan kaku `"• Baru saja"` pada notifikasi lama; notifikasi menampilkan selisih waktu asli (`15m lalu`, `2j lalu`, `Kemarin`, atau tanggal kalender).
- [ ] **Grouping Timeline Berfungsi**: Notifikasi terbagi jelas ke dalam kategori timeline (`Hari Ini`, `Kemarin`, `Minggu Ini`, `Lebih Lama`) dengan header sub-judul yang elegan.
- [ ] **Judul Pengumuman Ditampilkan**: Notifikasi broadcast menampilkan judul tebal yang jelas di atas isi pesan.
- [ ] **Dukungan Action Button**: Jika broadcast membawa konfigurasi tombol aksi (`action_button_label`), tombol muncul di kartu aktivitas dan dapat dieksekusi secara langsung.
- [ ] **Filter Kategori Pengumuman**: Tersedia tombol filter khusus `Pengumuman` berdampingan dengan `Semua`, `Interaksi`, dan `Pesanan COD`.
- [ ] **Realtime Konsisten**: Notifikasi baru yang masuk secara realtime langsung masuk ke grup "Hari Ini" secara instan.
- [ ] **Lolos Static Analysis**: `flutter analyze` tidak menghasilkan error atau warning baru.
- [ ] **Unit / Integration Tests**: Uji deserialisasi `ActivityNotification.fromJson` dengan berbagai format tanggal lulus pengujian.

---

## 6. Rencana Verifikasi & Uji Manual

1. **Uji Notifikasi dengan Berbagai Rentang Waktu**:
   - Data uji notifikasi hari ini (< 1 jam & beberapa jam lalu).
   - Data uji notifikasi kemarin (1 hari lalu).
   - Data uji notifikasi minggu ini (3-5 hari lalu).
   - Data uji notifikasi lama (> 7 hari lalu).
2. **Uji Broadcast Berisi Tombol Aksi**:
   - Kirim broadcast dengan `action_type: 'external_url'` dan `action_button_label: 'Buka Web Sekolah'`.
   - Verifikasi tombol muncul pada kartu di tab Aktivitas.
   - Klik tombol dan pastikan browser eksternal terbuka.
3. **Uji Filter Tab**:
   - Klik tab `Pengumuman`: pastikan hanya broadcast/sistem yang tampil.
   - Klik tab `Interaksi`: pastikan hanya like/komentar/follow yang tampil.
   - Klik tab `Pesanan COD`: pastikan hanya notifikasi pesanan yang tampil.
