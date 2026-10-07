# Architecture & Codebase Map for AI Agents

> Dokumen ini dirancang sebagai panduan navigasi cepat dan deterministik bagi AI Agent (LLM) untuk memahami struktur, tanggung jawab folder, dan pola penamaan file di Snapan Market Mobile.

---

## 1. Directory Tree & Domain Responsibilities

```text
lib/
├── main.dart                       # Entry point aplikasi & inisialisasi Supabase
├── core/                           # Foundation layer yang dipakai lintas fitur
│   ├── components/                 # Shared UI design system
│   │   ├── avatar/                 # default_profile_avatar, oreo_avatar_helper
│   │   ├── skeleton/               # Skeleton shimmer loaders
│   │   ├── app_dropdown_field.dart
│   │   ├── glass_toolbar_top.dart
│   │   ├── kumo_button.dart
│   │   ├── notification_guide_bottom_sheet.dart
│   │   └── update_info_bottom_sheet.dart
│   ├── constants/                  # Konstanta global & konfigurasi aplikasi
│   ├── models/                     # Shared models lintas domain
│   ├── navigation/                 # AppSlidePageRoute & helper routing
│   ├── services/                   # Service layer eksternal
│   │   ├── supabase/               # Supabase database, auth, feed, poll services
│   │   └── student_registry_service.dart # Registri data siswa & pencarian NIS
│   ├── theme/                      # AppColors, typography, theme tokens
│   └── utils/                      # Formatters mata uang, tanggal, mention, validator
│
└── features/                       # Modul fitur independen berbasis domain
    ├── activity/                   # Notifikasi & riwayat aktivitas
    ├── auth/                       # Autentikasi NIS/Username, login, register, dialogs
    ├── checkout/                   # Alur pembelian, checkout, detail pesanan
    ├── create_post/                # Modal pembuatan postingan, media picker, polling
    ├── feed/                       # Beranda linimasa, interaksi, komentar, detail
    │   ├── components/             # Sub-domain modular components
    │   │   ├── feed_components.dart# Barrel export utama feed
    │   │   ├── post_card/          # Komponen kartu postingan di feed
    │   │   ├── detail/             # Komponen khusus halaman post detail
    │   │   ├── comment/            # Komponen percakapan komentar & balasan
    │   │   ├── navigation/         # Bottom bar, drawer, tab switcher, fab group
    │   │   ├── sheets/             # Modal dialog & bottom sheet (buy, report, delete)
    │   │   └── lightbox/           # Dialog penampil foto fullscreen
    │   ├── controllers/            # Controller feed & post detail
    │   ├── models/                 # Model MarketPostModel, PostCommentModel, dll
    │   └── screens/                # HomeFeedScreen & PostDetailScreen
    ├── locations/                  # Pemilihan lokasi kampus/sekolah
    ├── map/                        # Peta interaktif sekolah
    ├── messages/                   # Direct messages & chat rooms
    ├── onboarding/                 # Layar selamat datang / pengenalan
    ├── profile/                    # Profil user, riwayat posting, edit profile
    │   ├── components/             # Avatar section, form fields, chips editor
    │   ├── controllers/            # ProfileController
    │   ├── models/                 # ProfileUserModel
    │   └── screens/                # ProfileScreen, EditProfileScreen
    ├── search/                     # Pencarian postingan, filter, akun siswa
    └── splash/                     # Splash screen saat aplikasi pertama dibuka
```

---

## 2. File Naming Rules (Aturan Penamaan)

1. **Screen / Orchestrator**:
   * Nama berakhiran `_screen.dart` atau `_modal.dart` (contoh: `home_feed_screen.dart`, `create_post_modal.dart`).
   * Hanya bertugas menyusun tata letak level tinggi dan memanggil Controller.

2. **Component (UI Elements)**:
   * Nama harus spesifik mencerminkan domain dan peran (contoh: `post_card_header.dart`, `comment_reply_tile.dart`).
   * Diletakkan di sub-folder yang sesuai konteks layarnya (`navigation/`, `sheets/`, `detail/`, `comment/`).

3. **Controller / Business Logic**:
   * Nama berakhiran `_controller.dart` (contoh: `post_detail_controller.dart`, `profile_controller.dart`).

4. **Service**:
   * Nama berakhiran `_service.dart` (contoh: `student_registry_service.dart`, `supabase_feed_service.dart`).

---

## 3. Aturan Identitas & Data Siswa (Penting untuk AI)

* **NIS (Nomor Induk Siswa)**: Merupakan **Single Source of Truth** untuk identitas legal siswa di backend (`RegisteredStudent`).
* **Nama Lengkap Siswa**: Tersimpan di registri resmi sekolah berdasarkan NIS. Tidak ditampilkan secara mencolok di feed publik demi privasi dan estetika.
* **Display Name**: Nama tampilan panggilan yang bebas diedit oleh siswa di `EditProfileScreen`.
* **Username (`@username`)**: Handle unik yang digunakan secara seragam di seluruh Feed Card, Post Detail, dan Komentar.
