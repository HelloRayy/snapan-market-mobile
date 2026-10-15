# [SNAPS-85] feat(empty-state): polish contextual empty states and action recoveries across screens

> **Ticket Metadata**:
> - **Sequence**: SNAPS-85
> - **Priority**: MEDIUM
> - **Domain**: `ui / empty_state / search / feed / profile`
> - **Status**: Ticket (Ready to Implement)

---

## 1. Problem Statement & User Context

- **Kondisi Saat Ini**:
  Ketika suatu halaman atau tab tidak memiliki data (misalnya: tab "Pasar" masih kosong di awal pembukaan sekolah, pencarian siswa tidak ditemukan, atau profil siswa baru belum mengunggah utas), layar menampilkan teks mati yang monoton dengan warna hardcoded hitam `Color(0xFF0F172A)` tanpa aksi pemulihan (*recovery CTA*).
- **Kebutuhan Beta Release**:
  Siswa baru yang pertama kali mengunduh aplikasi harus disambut dengan antarmuka yang membimbing (*onboarding touchpoint*). Empty state harus memiliki ikon ilustrasi halus, deskripsi ramah, dan tombol aksi yang jelas:
  - Di Tab Pasar kosong: Tombol *"Mulai Jual Karyamu"* (langsung membuka modal create post mode jual).
  - Di Pencarian kosong: Tombol *"Reset Pencarian"* atau rekomendasi tag populer.
  - Di Tab Utas kosong: Tombol *"Segarkan Linimasa"* atau *"Tulis Utas Pertama"*.
  - Warna adaptif Dark Mode (tidak ada teks hitam di layar gelap).

---

## 2. Target File Scope

| File Path | Peran & Perubahan |
| :--- | :--- |
| [`lib/core/components/snaps_empty_state.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/components/snaps_empty_state.dart) | **(Baru/Standarisasi)** Komponen universal empty state dengan ikon squircle bertema, teks judul, deskripsi adaptif, dan tombol aksi opsional |
| [`lib/features/feed/components/home_feed_scrollable_list.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/home_feed_scrollable_list.dart#L330-L360) | Mengganti empty state feed manual dengan `SnapsEmptyState` + tombol aksi buat postingan/refresh |
| [`lib/features/profile/components/profile_content_tabs.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/components/profile_content_tabs.dart#L75-L120) | Memperbaiki hardcoded color `Color(0xFF0F172A)` di tab utas/balasan profil menjadi adaptif |
| [`lib/features/search/components/search_results_view.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/search/components/search_results_view.dart) | Mengintegrasikan tombol reset dan pesan panduan ketika pencarian kata kunci nihil |

---

## 3. Step-by-Step Technical Approach

### Langkah 1: Membangun `SnapsEmptyState` Universal
Buat widget mandiri di `lib/core/components/snaps_empty_state.dart`:
```dart
class SnapsEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SnapsEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });
  // Menggunakan AppColors.adaptiveText(context), AppColors.adaptiveMuted(context),
  // dan KumoButton atau ElevatedButton adaptif.
}
```

### Langkah 2: Integrasi ke Feed & Tab Jualan
Di [`home_feed_scrollable_list.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/home_feed_scrollable_list.dart):
- Jika `isMarket`: Ikon tas belanja / store, judul *"Belum Ada Produk Dijual"*, deskripsi *"Jadilah yang pertama menawarkan makanan, minuman, atau karya tokomu di sini!"*, aksi *"Buka Lapak Sekarang"*.
- Jika `!isMarket`: Ikon obrolan / bubble, judul *"Linimasa Masih Sepi"*, deskripsi *"Bagikan kabar atau diskusikan hal seru seputar kegiatan sekolah."*, aksi *"Tulis Utas Pertama"*.

### Langkah 3: Integrasi ke Tab Profil & Pencarian
Ganti teks statis di `profile_content_tabs.dart` agar warna teks dinamis mengikuti Dark Mode dan tidak tenggelam di layar hitam.

---

## 4. Definition of Done (DoD)

- [ ] Seluruh halaman kosong (feed, search, profile) menggunakan visual `SnapsEmptyState` yang konsisten.
- [ ] Tombol aksi di empty state tab pasar langsung membuka modal penjualan.
- [ ] Tombol aksi di empty state linimasa membuka modal utas baru.
- [ ] Teks dan ikon memiliki kontras tinggi yang nyaman di Dark Mode dan Light Mode.
- [ ] Lolos verifikasi `flutter analyze` dengan 0 errors.
