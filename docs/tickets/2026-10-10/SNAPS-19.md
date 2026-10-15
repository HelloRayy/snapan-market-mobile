# [SNAPS-19] feat(motion): add motion on action button - love like dll, dan bebrapa interactive touch

> **Ticket Metadata**:
> - **Plane ID**: `c303adc2-22dd-4678-bfa0-2ddc6ce03085`
> - **Sequence**: SNAPS-19
> - **Priority**: MEDIUM
> - **State Group**: unstarted
> - **Domain**: `motion / interactions / micro_animations`

---

## 1. Problem Statement & User Context
- **Deskripsi Asli Plane**:
> Problem Context Relates dengan snaps26, mengenai jacob law dll. tapi ini lebih kearah motion action untuk Love, Comment, Repost, Send. di apps kita masi belum ada macem2 fitur tersebut, focusing right now is Love n Comment. Tujuannya kita fokus peningkatan UI dan Motion dari action Love n Comment tersebut, mirip dengan apps kompetitor kita.

- **Akar Masalah Teknis**: Tombol aksi Like (Love) dan Comment pada feed post card terasa kaku dan tanpa rasa interaksi (lacks feedback). Di aplikasi sejenis (Instagram, Threads, Twitter), tombol like memiliki efek micro-bounce, pop particle, dan haptic tactile response yang memuaskan.

---

## 2. Target File Scope (Interface-First Coupling)
> Rujukan arsitektur berdasarkan `AGENT_MANIFEST.md`:

| Peran File | Path File di Repositori | Keterangan Peran |
| :--- | :--- | :--- |
| **Feed Post Action Bar** | [`lib/features/feed/components/post_card/post_action_bar.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_card/post_action_bar.dart) | Barisan tombol aksi (Like, Comment, Share, Bookmark) |
| **Feed Controller** | [`lib/features/feed/controllers/home_feed_controller.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/controllers/home_feed_controller.dart) | Optimistic toggle like state |
| **Motion Utilities** | [`lib/core/theme/app_animations.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/theme/app_animations.dart) | Konfigurasi tween scale bounce animasi (0.8 -> 1.2 -> 1.0) |

---

## 3. Step-by-Step Technical Approach (Untuk AI Agent Eksekutor)
1. Buat widget leaf modular like_bounce_button.dart di lib/features/feed/components/post_card/ dengan AnimationController kustom.
2. Terapkan kurva animasi elastis saat like diaktifkan: skala mengecil ke 0.8, membesar ke 1.25 dengan warna AppColors.error, lalu kembali ke ukuran 1.0.
3. Tambahkan HapticFeedback.mediumImpact() saat like ditekan dan HapticFeedback.lightImpact() saat unlike.
4. Pastikan animasi berjalan optimis di UI tanpa menunggu respons jaringan Supabase selesai.

---

## 4. Key Decisions & Questions Needed
- ❓ Apakah double-tap pada foto postingan juga perlu memicu animasi hati besar di tengah gambar (Instagram-style)?
- ❓ Apakah tombol komentar juga memerlukan subtle scale bounce saat diklik?

---

## 5. Definition of Done (DoD)
- [ ] Tombol Like memiliki animasi bounce yang halus dan haptic feedback responsif.
- [ ] State like ter-toggle secara optimis tanpa lag.
- [ ] Kode animasi modular dan tidak melebihi batas 250 baris per file.

