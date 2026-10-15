# [SNAPS-26] feat(ux-motion): riset tentang penggunaan swipe pada jempol untuk aplikasi, contoh untuk pindah tab dan lain-lain

> **Ticket Metadata**:
> - **Plane ID**: `b23ce4e5-8632-4b09-82e9-e1005ea861f8`
> - **Sequence**: SNAPS-26
> - **Priority**: MEDIUM
> - **State Group**: completed
> - **Domain**: `ux / motion / gestures`

---

## 1. Problem Statement & User Context
- **Deskripsi Asli Plane**:
> Problem Context User mengalami jacob law, keseringan menggunakan app serupa dengan Snaps, sehingga memiliki behaviour yang "seharusnya" kita sama dengan app yang user pakai. App kita memakai sistem yang kurang lebih mirip dengan Threads, Twitter, Instagram → lakukan analisa terhadap app tersebut mengenai UX dari thumb motion nya.

---

## 2. Post-Mortem Evaluasi: Kenapa Full-Screen Horizontal Swipe Ditolak?
Saat dicoba secara manual di *real device*, terbukti bahwa mengaktifkan gesture swipe horizontal layar penuh di linimasa feed menimbulkan resiko fatal:
1. **Ergonomi Busur Jempol (Thumb Arc & Slanted Diagonal Drift)**:
   - Gerakan jempol saat scrolling vertikal satu tangan tidak membentuk sudut 90° tegak lurus, melainkan melengkung diagonal 15°–35°.
   - Akibatnya, saat pengguna berniat scroll santai membaca postingan ke bawah, gesture arena menangkap pergerakan horizontal dan secara tidak sengaja memindahkan layar ke tab "Jualan" (*accidental tab switch*).
2. **Asimetri Frekuensi Interaksi**:
   - 95% interaksi pengguna di feed adalah konsumsi konten (vertikal). Fitur pindah ke "Jualan" adalah aksi sekunder (berkala, ~5%). Mengorbankan kenyamanan 95% interaksi demi fitur 5% adalah kesalahan UX.
3. **Pelajaran untuk Agen AI**:
   - Kesalahan ini seharusnya **dapat dan wajib dicegah sejak awal lewat analisis ergonomi pra-implementasi** tanpa perlu membuang waktu coding swipe horizontal. Aturan ini kini diabadikan di **[`AGENTS.md`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/AGENTS.md) butir 15**.

---

## 3. Solusi Akhir yang Diterapkan: Tap-Only + Polished Spring (Meta Threads Style)
Mengadopsi standar industri **Meta Threads** & **Instagram**:
1. **Feed Viewport 100% Solid & Murni Vertikal**:
   - Menghilangkan `PageView` horizontal dari area feed dan menggantinya dengan `IndexedStack`.
   - Menghilangkan recognizer horizontal drag dari viewport sehingga **0% resiko salah swipe atau terpelintir**.
   - Posisi scroll vertikal tersimpan mandiri di masing-masing tab ("Untuk Anda" & "Jualan") menggunakan `ScrollController` terpisah dan `PageStorageKey`.
2. **Polished Spring Micro-Interactions**:
   - Tab switcher atas tetap fixed 47px.
   - Pergantian tab diakses via **Tap** dengan animasi spring sliding indicator yang memuaskan (`AnimatedAlign` curve `easeOutCubic`, 220ms).
   - Dilengkapi tactile haptic feedback (`HapticFeedback.selectionClick()`) dan micro-scale press effect.

---

## 4. File Terkait & Arsitektur

| Peran File | Path File di Repositori | Keterangan Peran |
| :--- | :--- | :--- |
| **Tab Switcher** | [`lib/features/feed/components/navigation/home_feed_tab_switch.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/navigation/home_feed_tab_switch.dart) | Tap-driven spring indicator 2.5px, tactile scale, dan haptic feedback. |
| **Scrollable List** | [`lib/features/feed/components/home_feed_scrollable_list.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/home_feed_scrollable_list.dart) | `IndexedStack` murni vertikal, bebas konflik horizontal, independen scroll state. |
| **Motion Tokens** | [`lib/core/theme/app_animations.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/theme/app_animations.dart) | Standard token durasi, spring curves, dan helper haptic feedback. |
| **Test Suite** | [`test/ux_swipe_motion_test.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/test/ux_swipe_motion_test.dart) | Verifikasi unit & widget test untuk spring indicator dan isolasi scroll state. |

---

## 5. Definition of Done (DoD)
- [x] Area timeline feed 100% bebas dari konflik gesture horizontal (0% accidental tab switch).
- [x] Navigasi mode feed "Untuk Anda" dan "Jualan" berpindah dengan tap yang responsif dan spring indicator halus.
- [x] Posisi scroll tersimpan mandiri di masing-masing tab saat pengguna berpindah mode.
- [x] Tactile haptic feedback terpicu saat pengguna mengetuk tab.
- [x] Evaluasi dan protokol pencegahan analisis telah didokumentasikan di `AGENTS.md`.
