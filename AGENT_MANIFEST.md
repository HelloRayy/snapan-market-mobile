# AGENT_MANIFEST.md — Single Source of Truth

> **Kompas Tunggal AI Agent**: Baca file ini di Turn 1 untuk mengunci konteks, aturan mutlak, dan rute file dalam **1 tool call** (< 80 baris, < 1.000 token). Dilarang membaca rantai file `.md` lain.

---

## 1. Aturan Mutlak & Pantangan Arsitektur (Invariants)

- **Design Tokens**: Wajib gunakan `AppColors.*` dari [`lib/core/theme/app_colors.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/theme/app_colors.dart). Dilarang menulis nilai hex manual. Hit area interaktif minimal 44x44 dp dengan `HapticFeedback.lightImpact()`.
- **Verifikasi Urgensi & UX Friksi (Pelajaran SNAPS-33)**: Dilarang langsung membuat layar interstitial yang menginterupsi alur utama (misal: onboarding form paksa pasca-register). Wajib verifikasi urgensi & fatigue pengguna terlebih dahulu. Lebih utamakan **Contextual In-App Nudge / Progress Reminder** di layar tujuan daripada memblokir jalan masuk user.
- **Autentikasi Siswa (SNAPS-64)**: Login berbasis NIS/Username, **BUKAN email Google**. Format email sintetis: `$identifier@snapan.id` atau RPC `lookup_login_email`.
- **Keamanan & Suspensi**: Validasi `SuspensionService.instance.getCurrentUserSuspensionStatus()` pasca-login. Jika ditangguhkan, paksa logout dan tampilkan banner/screen akun suspend.
- **Pemisahan Lapisan**: Dilarang menjalankan query Supabase langsung di dalam method `build()`. Delegasikan ke Controller atau Service.
- **Batas Ukuran File**: Target $\le 250$ baris (hard cap 300). Dilarang helper `_buildHeader()`, `_buildCard()` monolitik di file screen. Pecah selalu ke subkomponen.

---

## 2. Peta Rute Parent-to-Leaf (Dual-Read Coupling)

> **Protokol Baca Fleksibel (Interface-First)**:
> - **Jika tugas murni styling / UI visual**: Baca HANYA file **Leaf Component** (deklarasi konstruktor props + method `build()`). Jangan membuang token membaca Controller!
> - **Jika tugas melibatkan alur data / event / state**: Baca pasangan **[Parent / Controller] + [Leaf Component]** secara bersamaan dalam 1 batch call untuk menjaga kontrak parameter.

| Domain Fitur | Parent Orchestrator / State Controller | Leaf Component (Target Edit) |
| :--- | :--- | :--- |
| **Feed: Kartu Postingan** | [`lib/features/feed/controllers/home_feed_controller.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/controllers/home_feed_controller.dart) | [`lib/features/feed/components/post_card/market_post_card.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_card/market_post_card.dart) |
| **Feed: Avatar & Badge** | [`lib/features/feed/components/post_card/market_post_card.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_card/market_post_card.dart) | [`lib/features/feed/components/post_card/post_author_avatar.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_card/post_author_avatar.dart) |
| **Feed: Action Bar (Like/Share)** | [`lib/features/feed/controllers/home_feed_controller.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/controllers/home_feed_controller.dart) | [`lib/features/feed/components/post_card/post_action_bar.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_card/post_action_bar.dart) |
| **Feed: Polling Suara** | [`lib/core/services/poll_sync_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/poll_sync_service.dart) | [`lib/features/feed/components/post_card/post_poll_section.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_card/post_poll_section.dart) |
| **Feed: Utas / Thread Chain** | [`lib/features/feed/components/post_card/market_post_card.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_card/market_post_card.dart) | [`lib/features/feed/components/post_card/post_thread_chain_section.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_card/post_thread_chain_section.dart) |
| **Post Detail: Bottom Bar** | [`lib/features/feed/controllers/post_detail_controller.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/controllers/post_detail_controller.dart) | [`lib/features/feed/components/detail/post_detail_bottom_bar.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/detail/post_detail_bottom_bar.dart) |
| **Post Detail: Komentar** | [`lib/features/feed/controllers/post_detail_controller.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/controllers/post_detail_controller.dart) | [`lib/features/feed/components/comment/post_comment_item.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/comment/post_comment_item.dart) |
| **Auth: Tab Login Siswa** | [`lib/features/auth/controllers/auth_controller.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/auth/controllers/auth_controller.dart) | [`lib/features/auth/components/auth_login_tab.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/auth/components/auth_login_tab.dart) |
| **Auth: Tab Pendaftaran** | [`lib/features/auth/controllers/auth_controller.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/auth/controllers/auth_controller.dart) | [`lib/features/auth/components/auth_register_tab.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/auth/components/auth_register_tab.dart) |
| **Auth: Combobox NIS** | [`lib/core/services/student_registry_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/student_registry_service.dart) | [`lib/features/auth/components/student_nis_combobox.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/auth/components/student_nis_combobox.dart) |
| **Checkout: Bottom Bar** | [`lib/features/checkout/screens/checkout_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/checkout/screens/checkout_screen.dart) | [`lib/features/checkout/components/checkout_bottom_bar.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/checkout/components/checkout_bottom_bar.dart) |
| **Checkout: Catatan Pembeli** | [`lib/features/checkout/screens/checkout_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/checkout/screens/checkout_screen.dart) | [`lib/features/checkout/components/checkout_buyer_note_card.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/checkout/components/checkout_buyer_note_card.dart) |
| **Checkout: Rincian Biaya** | [`lib/features/checkout/screens/checkout_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/checkout/screens/checkout_screen.dart) | [`lib/features/checkout/components/checkout_price_breakdown.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/checkout/components/checkout_price_breakdown.dart) |
| **COD: Spot Card Lokasi** | [`lib/core/services/meeting_point_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/meeting_point_service.dart) | [`lib/features/locations/components/location_spot_card.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/locations/components/location_spot_card.dart) |
| **COD: Detail Spot Sheet** | [`lib/core/services/meeting_point_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/meeting_point_service.dart) | [`lib/features/locations/components/location_spot_detail_sheet.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/locations/components/location_spot_detail_sheet.dart) |
| **Map: Kanvas 2D Blueprint** | [`lib/features/map/screens/campus_map_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/map/screens/campus_map_screen.dart) | [`lib/features/map/components/campus_2d_blueprint_painter.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/map/components/campus_2d_blueprint_painter.dart) |
| **Profil: Header & Bio** | [`lib/features/profile/controllers/profile_controller.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/controllers/profile_controller.dart) | [`lib/features/profile/components/profile_info_header.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/components/profile_info_header.dart) |
| **Profil: Tombol CTA 50:50** | [`lib/features/profile/controllers/profile_controller.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/controllers/profile_controller.dart) | [`lib/features/profile/components/profile_action_buttons.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/components/profile_action_buttons.dart) |
| **Profil: Form Edit Data** | [`lib/features/profile/screens/edit_profile_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/screens/edit_profile_screen.dart) | [`lib/features/profile/components/edit_profile_form_fields.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/components/edit_profile_form_fields.dart) |
| **Pesan: Ruang Obrolan DM** | [`lib/features/messages/services/direct_messages_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/messages/services/direct_messages_service.dart) | [`lib/features/messages/screens/chat_conversation_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/messages/screens/chat_conversation_screen.dart) |

---

## 3. Protokol Eksekusi Cepat (The 3-Step Rule)

1. **Turn 1 (Peta & Aturan)**: Periksa baris domain di tabel atas.
2. **Turn 2 (Dual-Read / Leaf-Read)**: Baca file target (Leaf saja jika styling visual, atau Parent + Leaf jika mengubah event/state).
3. **Turn 3 (Surgical Edit)**: Modifikasi kode menggunakan `replace_file_content`. Selesai dalam < 20 detik!
