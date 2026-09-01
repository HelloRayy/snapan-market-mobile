# Snapan Market Mobile — Architecture & Codebase Guide

Dokumen ini adalah referensi arsitektur komprehensif **Snapan Market Mobile** yang dirancang agar **mudah dipahami secara instan oleh AI Agent dan Software Engineer**.

---

## 🏛️ 1. High-Level Architecture Overview

Aplikasi dibangun di atas stack modern: **React 18 + TypeScript 5.5 + Vite 5 + Tailwind CSS v4 + Zustand + Supabase + Lenis Scroll**.

```
┌────────────────────────────────────────────────────────┐
│                   React 18 Frontend                    │
│   App.tsx (Declarative Router & Layout Orchestrator)   │
│   ├── ui/navigation/useAppNavigation.ts (Route State)  │
│   ├── ui/pages/ (Home, PostDetail, Search, Profile)    │
│   ├── ui/components/ (Marketplace, Chat, Onboarding)   │
│   └── ui/store/ & ui/hooks/ (Zustand & Supabase Auth)  │
└───────────────────────────┬────────────────────────────┘
                            │ (Typed API Calls & Realtime)
┌───────────────────────────▼────────────────────────────┐
│               Service Layer (src/services/)             │
│   ├── api/index.ts (Auth, Posts, Orders, Comments)     │
│   └── cache/feedCache.ts (In-Memory 0ms Cache)         │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│                 Supabase Cloud Backend                 │
│   PostgreSQL DB + GoTrue Auth + Realtime + Storage     │
└────────────────────────────────────────────────────────┘
```

---

## 📁 2. Struktur Folder & Modul

```
src/
├── assets/                    # Asset visual SVG & ilustrasi lokal
├── data/
│   ├── mockMarketData.ts      # Dataset mock marketplace & forum (fallback/offline)
│   └── mockSchoolMapData.ts   # Blueprint top-down 2D denah SMKN 8 Semarang
├── services/
│   ├── api/                   # Modular Supabase API repository services
│   │   ├── authService.ts
│   │   ├── marketPostsService.ts
│   │   ├── ordersService.ts
│   │   ├── commentService.ts
│   │   ├── bookmarkService.ts
│   │   ├── realtimeService.ts
│   │   └── index.ts           # 📦 Canonical Barrel Export
│   └── cache/
│       └── feedCache.ts       # Cache in-memory dengan TTL 5 menit
├── types/
│   ├── marketFeed.ts          # Model postingan thread, media & penjual
│   ├── product.ts             # Model produk katalog & stok
│   ├── order.ts               # Model transaksi COD sekolah
│   ├── supabase.ts            # Definisi tabel PostgreSQL Supabase
│   └── index.ts               # 📦 Canonical Barrel Export
├── ui/
│   ├── components/
│   │   ├── chat/              # ActiveChatOverlay, ChatComposerBar, ChatTopBar
│   │   ├── map/               # Campus2DMap, Campus3DMap
│   │   ├── marketplace/       # MarketPostCard, CreatePostModal, BuyBottomSheet
│   │   │   ├── create-post/   # Header, MediaToolbar, LocationPicker, Drafts
│   │   │   └── post-card/     # PostCardHeader, PostCardMediaGallery, PostCardActionBar
│   │   ├── navigation/        # NavigationDrawer
│   │   ├── onboarding/        # OnboardingScreen, AuthSlideVisual
│   │   │   └── auth/          # AuthHeader, AuthLoginForm, AuthRegisterForm, AuthOtpSheet
│   │   ├── pwa/               # PwaLandingPage, CustomPwaInstallModal, pwaLanding.css
│   │   └── ui/                # Atomic primitives (Button, Card, Input, Toast)
│   ├── hooks/                 # Custom hooks (useAuth, usePWA, useSmoothScroll, useVirtualKeyboard)
│   ├── navigation/            # useAppNavigation.ts (URL parser & route state machine)
│   ├── pages/                 # Full screen views (Home, Profile, Search, DirectMessages, Map)
│   └── store/                 # Zustand global stores (cartStore.ts)
└── utils/
    ├── cn.ts                  # Classname merger (clsx + tailwind-merge)
    ├── formatters.ts          # Format mata uang Rupiah & smart timestamp
    └── haptics.ts             # Haptic vibration feedback (Light, Medium, Success, Error)
```

---

## 🧭 3. Routing & State Preservation (`useAppNavigation.ts`)

Aplikasi menggunakan sistem **Stateful Route Preservation**:
- Halaman **`HomePage`** dan **`SearchPage`** tetap hidup di DOM menggunakan class `block`/`hidden`. Hal ini menjaga posisi *scroll*, query pencarian yang aktif, dan filter tab agar tidak pernah hilang saat pengguna membuka postingan detail atau profil.
- URL didukung oleh dual-mode: Pathname routing (`/@username/post/:id`, `/search`, `/messages`) dan Hash routing fallback (`#post-:id`, `#map`, `#download`).
- **PWA Back Guard**: Menekan tombol *Back* pada perangkat Android / browser dilindungi dengan timer 2 detik untuk mencegah pengguna tidak sengaja keluar dari aplikasi.

---

## 🎨 4. Design Tokens & Styling (Tailwind CSS v4)

Semua token warna terpusat di `src/index.css` di bawah direct `@theme`:
- **Brand Signature**: Electric Indigo (`--color-brand-primary: #3d38f5`, hover `#312bd9`, pastel `#eef0ff`, ring `rgba(61, 56, 245, 0.15)`).
- **Neutral Canvas**: Canvas mist `#f2f4f5`, pure white `#ffffff`, slate ink `#332f2d`, muted gray `#787574`.
- **Typography**: Inter font dengan font-features tabular (`cv02, cv03, cv04, cv11, tnum`).
- **GPU Layer Utility**: Class `.feed-card-perf` (`contain: layout paint; transform: translateZ(0)`) mengisolasi layer rendering untuk animasi 120 FPS yang mulus.

---

## 🗺️ 5. Denah Arsitektural 2D (`Campus2DMap.tsx`)

Denah kampus SMKN 8 Semarang menggunakan koordinat vektor murni SVG top-down:
- **ViewBox**: `1150 x 880`, pusat di `(575, 440)`.
- **Fitur Interaktif**: Touch pan gesture, multi-level floor switcher (`Lt 1 / Lt 2`), pulsing radar hotspot pin, dan dynamic bottom sheet untuk memilih titik COD.

---

## 🛡️ 6. Rules for AI Agents

1. **Gunakan Path Alias `@/`**: Selalu gunakan `@/` yang merujuk ke `src/`. Jangan gunakan traversal relatif `../../`.
2. **Kerapian File (< 500 Baris)**: Pecah komponen besar menjadi subkomponen terfokus di subfolder yang sesuai (seperti `post-card/`, `create-post/`, `auth/`).
3. **Strict TypeScript**: Selalu gunakan typed model dari `@/types`. Hindari `any` dan pertahankan type safety 100%.
4. **Git Workflow Multi-Laptop**: Selalu lakukan `git pull origin main` sebelum mulai bekerja, dan commit dengan Conventional Commits (`feat(...)`, `fix(...)`, `refactor(...)`) lalu push ke `main`.
