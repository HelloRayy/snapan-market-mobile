# 🏛️ Panduan Arsitektur Clean Code & Long-Term Maintainability
**Proyek: Snapan Market Mobile PWA**  
*Standar Rekayasa Perangkat Lunak untuk Kemudahan Perawatan Jangka Panjang & Optimalisasi AI Coding Agent*

---

## 📑 1. RINGKASAN EKSEKUTIF (*Executive Summary*)

Arsitektur **Snapan Market Mobile** dirancang berdasarkan prinsip **Clean Architecture**, **Single Responsibility Principle (SRP)**, dan **Explicit Dependency Inversion**. Tujuannya adalah memastikan bahwa:
1. **Kode Modular & Terisolasi**: Perubahan pada layer tampilan (UI) tidak akan merusak kontrak data (Types) atau logika API (Services).
2. **Optimal untuk AI Coding Agent**: Struktur direktori yang terprediksi, penamaan deskriptif, dan *strict TypeScript typing* meminimalisir *context token overhead* dan mencegah halusinasi AI hingga 0%.
3. **Kinerja Tinggi & Skalabel**: Siap untuk penambahan puluhan fitur baru (seperti Side Drawer, Realtime Chat, Payment Gateway, Push Notification) tanpa penumpukan *technical debt*.

---

## 📂 2. PETA STRUKTUR LAYER APLIKASI (*Directory & Layer Breakdown*)

```
snapan-market-mobile/
├── docs/                             # 📚 Single Source of Truth untuk Developer & AI Agent
│   ├── architecture.md               # Panduan struktur folder & dependency rules
│   ├── clean-code-architecture.md    # Standar arsitektur clean code & maintainability
│   ├── coding-standards.md           # Standar penulisan clean code & styling Tailwind
│   ├── multi-laptop-setup.md         # Protokol kolaborasi Laptop A (FE) vs Laptop B (BE)
│   ├── pwa-guide.md                  # Panduan PWA & Service Worker
│   └── supabase-guide.md             # Skema database SQL & RLS policies
│
├── src/
│   ├── types/                        # 🏷️ [LAYER 1: DOMAIN & CONTRACTS]
│   │   ├── marketFeed.ts             # Model data feed, post, komentar, seller
│   │   ├── product.ts                # Model produk katalog & kategori
│   │   └── supabase.ts               # Generated schema types dari Supabase
│   │
│   ├── services/                     # 🔌 [LAYER 2: INFRASTRUCTURE & DATA]
│   │   ├── api/
│   │   │   ├── supabase.ts           # Supabase Client singleton
│   │   │   ├── authService.ts        # Layanan autentikasi & profile
│   │   │   └── marketPostService.ts  # Layanan query feed & postingan
│   │   └── pwa/                      # Service Worker registration & PWA update
│   │
│   ├── utils/                        # 🛠️ [LAYER 3: PURE HELPERS]
│   │   ├── cn.ts                     # Classname merger (clsx + tailwind-merge)
│   │   └── formatters.ts             # Pure function (formatRupiah, timeAgo, dsb)
│   │
│   └── ui/                           # 🎨 [LAYER 4: PRESENTATION]
│       ├── components/
│       │   ├── ui/                   # Atomic UI dasar (ButtonPrimary, Modal, dsb)
│       │   ├── marketplace/          # Komponen domain e-commerce (PostCard, BottomNav, Header)
│       │   ├── profile/              # Komponen halaman profil (EditProfileModal, SettingsSheet)
│       │   └── pwa/                  # Banner install & offline indicator
│       ├── hooks/                    # Custom React hooks (useAuth, usePWA, useOnlineStatus)
│       ├── store/                    # Global state management (Zustand)
│       └── pages/                    # Container views (HomePage, ProfilePage, PostDetailPage)
│
├── AGENTS.md                         # 🤖 System Instructions Wajib untuk Seluruh AI Agent
└── tailwind.config.js / vite.config  # ⚙️ Konfigurasi build & style
```

---

## 🔒 3. ATURAN KETERGANTUNGAN (*Dependency Flow Rules*)

Agar kode tidak saling mengunci (*circular dependency*), seluruh kode wajib mematuhi arah panah ketergantungan satu arah berikut:

$$\text{ui/ (Tampilan)} \longrightarrow \text{services/ (API)} \longrightarrow \text{types/ (Kontrak Data)}$$
$$\text{ui/ (Tampilan)} \longrightarrow \text{utils/ (Helper Murni)}$$

| Layer | Boleh Mengimpor Dari | Dilarang Mengimpor Dari |
| :--- | :--- | :--- |
| **`types/`** | Tidak ada (Pure TypeScript) | `ui/`, `services/`, `utils/` |
| **`utils/`** | Libraries murni (`clsx`, dsb) | `ui/`, `services/` |
| **`services/`** | `types/`, `utils/`, SDK eksternal (`@supabase/supabase-js`) | `ui/` |
| **`ui/`** | `types/`, `services/`, `utils/`, `ui/components/` | File internal build tool |

---

## 🤖 4. MENGAPA STRUKTUR INI SANGAT RAMAH UNTUK AI AGENT?

1. **Deterministic Discovery**:
   - Jika AI diminta memperbaiki query data $\rightarrow$ AI langsung tahu membuka `src/services/api/`.
   - Jika AI diminta mengubah tampilan profil $\rightarrow$ AI langsung tahu membuka `src/ui/pages/ProfilePage.tsx`.
2. **Explicit Type Contracts (`src/types/`)**:
   - AI tidak perlu menebak properti objek (misal: apakah `item.price` atau `item.harga`). Tipe TypeScript yang ketat (*Strict Typing*) mencegah bug `undefined is not a function`.
3. **Standarisasi Path Alias (`@/`)**:
   - Selalu gunakan `@/ui/components/...` dibanding relative path bertingkat seperti `../../../../components/...`. Ini memudahkan AI saat me-refactor atau memindahkan file.
4. **AGENTS.md sebagai Guardrail**:
   - Setiap AI yang membaca repositori ini langsung mengetahui aturan Laptop A (Frontend) vs Laptop B (Backend) sehingga tidak akan mengubah skema database secara sembarangan.

---

## 💎 5. PRINSIP CLEAN CODE YANG DITERAPKAN DI CODEBASE

1. **Single Responsibility Principle (SRP)**:
   - Satu komponen hanya mengerjakan satu tugas utama (Contoh: `MarketHeader` hanya menangani header navigasi, `MarketBottomNav` hanya menangani navigasi bawah, `PostCommentItem` hanya merender satu baris komentar).
2. **Performance-First Motion (60-120fps)**:
   - Menggunakan animasi berbasis akselerasi GPU (`transform: translate3d(...)`, `will-change: transform`, `transform-gpu`).
   - Menghindari filter berat (`backdrop-blur`) di elemen bergerak untuk mencegah lag pada perangkat mobile low-end.
3. **Synchronous State Initialization (Zero-Flash)**:
   - State autentikasi dan onboarding dihitung secara sinkron di Frame 0 menggunakan *lazy initializer* `useState(() => ...)`, mencegah kedipan layar (*splashscreen flash*).
4. **Resilient Touch Targets (Apple HIG & Material 3 Compliant)**:
   - Semua tombol interaktif memiliki minimum hit area $44\times 44\text{ px}$.
   - Sensitivitas gesture scroll (*scroll delta*) diatur pada angka $24\text{ px}$ untuk mencegah pergeseran layout yang tidak disengaja.

---

## 🚀 6. PROTOKOL KOLABORASI MULTI-LAPTOP (LAPTOP A vs LAPTOP B)

1. **Laptop B (Backend)**:
   - Tulis SQL & RLS di `/docs/supabase-guide.md`.
   - Update tipe di `src/types/supabase.ts`.
   - Buat fungsi query di `src/services/api/<fitur>Service.ts`.
   - `git commit` & `git push`.
2. **Laptop A (Frontend)**:
   - `git pull origin main`.
   - Buat UI di `src/ui/` mengonsumsi tipe data resmi dari `src/types/supabase.ts`.
   - `git commit` & `git push`.
