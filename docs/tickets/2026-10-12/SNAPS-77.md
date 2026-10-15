# [SNAPS-77] style(ui): fix shadow berlebihan, dan ui yang tidak clean di apps

> **Ticket Metadata**:
> - **Plane ID**: `f5d3903f-59ba-4a99-b325-c19ae37da8cc`
> - **Sequence**: SNAPS-77
> - **Priority**: MEDIUM
> - **State Group**: unstarted (Ticket)
> - **Domain**: `design_system / shadow / clean_ui`

---

## 1. Problem Statement & User Context
- **Deskripsi Masalah di Plane.so**:
  > *"Banyak ui yang masi memiliki shadow yang berlebihan, tidak konsisten dengan komponen lain. sehingga menimbulkan ui yang aneh, dan over shadow. kita akan audit penggunaan shadow yang memiliki ui jelek atau overshadow untuk kita remove atau kurangi. kita juga bakal cari contoh penggunaan ui yang bagus."*

- **Akar Masalah Teknis**:
  Banyak komponen UI di Snaps mengadopsi `BoxShadow` bertumpuk dengan opasitas hitam gelap (`alpha: 0.15 - 0.25`) dan `blurRadius` tinggi:
  1. [`home_bottom_nav_bar.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/navigation/home_bottom_nav_bar.dart#L96-L105): Menggunakan 2 lapis shadow gelap yang membuat bar bawah terlihat kotor dan terputus dari feed.
  2. [`comment_input_bar.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/comment/comment_input_bar.dart#L268-L280): Input teks dan tombol kirim memiliki shadow tebal yang menutupi kontur border halus Kumo UI.
  3. [`floating_plus_squircle_button.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/navigation/floating_plus_squircle_button.dart#L60-L65): Tombol tambah memiliki drop shadow pekat bergaya Android jadul (Material 2).
  4. [`post_submenu_popover.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_card/post_submenu_popover.dart#L140-L150): Menu titik tiga memiliki shadow yang terlalu pekat sehingga mengaburkan teks pilihan di tema gelap.

---

## 2. Target File Scope (Interface-First Coupling)

| Peran File | Path File di Repositori | Keterangan Peran |
| :--- | :--- | :--- |
| **Theme Design Tokens** | [`lib/core/theme/app_colors.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/theme/app_colors.dart) | Standardisasi token shadow halus (`subtleShadow`, `elevatedShadow`) |
| **Home Bottom Nav Bar** | [`lib/features/feed/components/navigation/home_bottom_nav_bar.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/navigation/home_bottom_nav_bar.dart) | Ganti shadow tebal dengan border 1px neutral tipis + ambient shadow ultra halus |
| **Comment Input Bar** | [`lib/features/feed/components/comment/comment_input_bar.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/comment/comment_input_bar.dart) | Hapus shadow pada input field dalam, gunakan flat backdrop blur |
| **Floating Action Button** | [`lib/features/feed/components/navigation/floating_plus_squircle_button.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/navigation/floating_plus_squircle_button.dart) | Lembutkan shadow squircle agar selaras dengan estetika Threads |
| **Post Submenu Popover** | [`lib/features/feed/components/post_card/post_submenu_popover.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_card/post_submenu_popover.dart) | Standarisasi shadow floating popover |

---

## 3. Step-by-Step Technical Approach

1. **Definisikan Token Bayangan Terpusat (Anti-Overshadow)**:
   * Standar Kumo / Threads: Hindari shadow dengan opasitas > `0.06` di light mode.
   * Gunakan kombinasi: Border tipis `Border.all(color: borderSubtle, width: 0.8)` ditambah `BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: Offset(0, 4))`.
2. **Pembersihan Bottom Navigation Bar**:
   * Hapus shadow ganda ber-blur 16px di `home_bottom_nav_bar.dart`.
   * Ganti dengan border atas solid tipis `border-t border-neutral-100` dan backdrop blur 12px (glassmorphism modern).
3. **Pembersihan Input Komentar**:
   * Hapus `boxShadow` pada pill input teks di `comment_input_bar.dart`.
   * Komponen input harus berbentuk kapsul bersih berlatar belakang `neutral-100` (atau `neutral-900` di dark mode) tanpa bayangan jatuh ke dalam maupun ke luar.
4. **Pembersihan Kartu & Menu Popover**:
   * Evaluasi popover menu tiga titik: ganti bayangan tebal menjadi elevation modern yang halus dan tidak menodai konten di bawahnya.

---

## 4. Questions for Reviewer (Harus Dijawab Reviewer)

> ❓ **Pertanyaan 1**: Untuk Bottom Navigation Bar, apakah kamu lebih menyukai gaya **Pure Flat Borderless** (tanpa shadow sama sekali, hanya garis batas 1px) seperti Threads, atau tetap memakai bayangan kabut sangat halus (ambient blur 0.03)?
> 💡 **Jawaban**: Diterapkan ambient blur ultra-halus (0.04) dengan border neutral 0.8px (`#E2E8F0`), memberikan kedalaman subtle tanpa noda gelap kotor.
>
> ❓ **Pertanyaan 2**: Apakah Floating Action Button (FAB Tambah Postingan) tetap diberi aksen shadow berwarna (electric indigo shadow) atau flat?
> 💡 **Jawaban**: Diterapkan soft brand indigo glow `Color(0x333D38F5)` yang estetik dan selaras dengan aksen primary aplikasi, menggantikan drop shadow hitam kaku.

---

## 5. Definition of Done (DoD)
- [x] Tidak ada komponen yang memiliki `BoxShadow` dengan opasitas hitam di atas `0.08` pada tema terang.
- [x] Bottom Nav Bar dan Comment Input Bar terlihat bersih, modern, dan menyatu mulus dengan latar belakang aplikasi.
- [x] Header di seluruh screen 100% Flat tanpa bayangan kotor saat scroll (`appBarTheme: elevation: 0, scrolledUnderElevation: 0`).
- [x] Tombol-tombol Profile ("Ikuti", "Kirim pesan", "Edit profil") 100% Flat tanpa drop shadow offset jadul.
- [x] Container feed image bebas dari border gelap / ilusi drop shadow kotor.
