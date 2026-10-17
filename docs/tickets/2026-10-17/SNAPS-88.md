# [SNAPS-88] fix(ui): unify canvas and container background colors across profile and feed

> **Ticket Metadata**:
> - **Sequence**: SNAPS-88
> - **Priority**: MEDIUM
> - **Domain**: `ui / design_tokens / theme / profile / feed`
> - **Status**: DONE

---

## 1. Problem Statement & User Context

- **Kondisi Sebelumnya**:
  Terdapat perbedaan rona warna latar belakang pada mode terang (*Light Mode*):
  - Layar Feed dan kartu postingan (`MarketPostCard`) menggunakan putih bersih (*Pure White* `#FFFFFF`).
  - Layar Profil atas (`ProfileInfoHeader` & `ProfileActionButtons`) duduk di atas `Scaffold` yang menggunakan `AppColors.adaptiveCanvas(context)` dengan nilai `AppColors.canvas = Color(0xFFFAFAFA)` (abu-abu pudar / *off-white*).
  - Komponen `ProfileTabBar` dan `ProfileReplyThreadCard` menggunakan `Colors.white` dan border `Color(0xFFF1F5F9)` yang di-hardcode.
  - Akibatnya, pada halaman profil terlihat belang: bagian header profil tampak kusam/abu-abu pudar dibanding tab bar dan kartu postingan di bawahnya.
- **Kebutuhan**:
  Penyelarasan menyeluruh warna latar kanvas dan kontainer:
  - Pada *Light Mode*, seluruh latar kanvas menjadi putih murni (`Colors.white` `#FFFFFF`).
  - Pada *Dark Mode*, tetap OLED *pure black* (`#000000`) dan card surface (`#161717`).
  - Menghilangkan hardcoded color di `ProfileTabBar` dan `ProfileReplyThreadCard` agar adaptif Dark Mode.

---

## 2. Target File Scope

| File Path | Peran & Perubahan |
| :--- | :--- |
| [`lib/core/theme/app_colors.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/theme/app_colors.dart) | Mengubah `canvas` menjadi `Colors.white` (`Color(0xFFFFFFFF)`) |
| [`lib/features/profile/components/profile_tab_bar.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/components/profile_tab_bar.dart) | Menggunakan `AppColors.adaptiveSurface`, `AppColors.adaptiveDivider`, `adaptiveText`, & `adaptiveMuted` |
| [`lib/features/profile/components/profile_reply_thread_card.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/components/profile_reply_thread_card.dart) | Menggunakan `AppColors.adaptiveSurface` dan `AppColors.adaptiveDivider` |
| [`lib/features/feed/screens/home_feed_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/screens/home_feed_screen.dart) | Menggunakan `AppColors.adaptiveCanvas(context)` alih-alih ternary manual |
| [`lib/features/activity/screens/activity_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/activity/screens/activity_screen.dart) | Mengganti hardcoded `Color(0xFFFAFAFA)` dengan `AppColors.adaptiveCanvas(context)` |

---

## 3. Step-by-Step Technical Approach

1. **Ubah Token Global**: Ubah `AppColors.canvas` ke `Colors.white` di `app_colors.dart`.
2. **Refactor ProfileTabBar**: Jadikan latar, border pembatas, indikator aktif, dan teks tab sepenuhnya adaptif terhadap tema terang dan gelap.
3. **Refactor ProfileReplyThreadCard**: Ganti warna hardcoded putih dan border menjadi token adaptif.
4. **Refactor HomeFeedScreen & ActivityScreen**: Konsistensikan pemanggilan background dengan `AppColors.adaptiveCanvas(context)`.

---

## 4. Definition of Done (DoD)

- [x] Latar atas profil dan feed linimasa sama-sama putih murni (`#FFFFFF`) tanpa belang di Light Mode.
- [x] Di Dark Mode, kontainer tab bar dan profil berlatar OLED black / dark surface yang konsisten.
- [x] Validasi path arsitektur `./scripts/verify-agent-map.sh` sukses 100%.
- [x] Ukuran file tetap di bawah batas aman $\le 250$–$300$ baris.
