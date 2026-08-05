# Architecture & Folder Structure Guide

Dokumen ini menjelaskan struktur arsitektur folder **Snapan Market Mobile** yang dirancang agar **mudah dipahami**, scalable, dan siap untuk pengembangan fitur marketplace skala besar.

---

## 📁 Struktur Root Folder

```
snapan-market-mobile/
├── public/                       # Assets statis publik (favicon, icon PWA, manifest)
├── docs/                         # Dokumen konteks & panduan untuk AI Agent & Tim Developer
├── src/                          # Source code utama aplikasi
│   ├── ui/                       # [SEMUA TAMPILAN & HALAMAN]
│   ├── services/                 # [SERVIS DATA, API & PWA]
│   ├── types/                    # [DEFINISI TIPE DATA & MODEL TS]
│   └── utils/                    # [HELPER & UTILITY UNTUK KODE]
├── vite.config.ts                # Konfigurasi Vite & PWA
├── tailwind.config.js            # Konfigurasi Tailwind CSS v4
├── tsconfig.json                 # Konfigurasi TypeScript
└── package.json                  # Dependencies & script project
```

---

## 🧱 Penjelasan Layer di `src/`

### 1. `src/ui/` (Tampilan & UI)
Tempat semua komponen visual, halaman web, state management UI, dan React hooks berada.
- **`pages/`**: Halaman utama aplikasi (`HomePage.tsx`, `ProductDetailPage.tsx`, `CartPage.tsx`, `CheckoutPage.tsx`).
- **`components/`**:
  - `ui/`: Komponen atomic reusable (Button, Card, Input, Badge, Modal).
  - `marketplace/`: Komponen spesifik e-commerce (ProductCard, QuantitySelector, RatingStars, MobileBottomNav).
  - `pwa/`: Banner instalasi PWA dan indikator status koneksi offline.
- **`store/`**: Global state management menggunakan Zustand (`cartStore.ts`, `userStore.ts`).
- **`hooks/`**: Custom React hooks (`useAuth.ts`, `usePWA.ts`, `useOnlineStatus.ts`).

### 2. `src/services/` (Data & Servis)
Tempat berkomunikasi dengan pihak luar (Backend / Database Supabase / LocalStorage / Service Worker).
- **`api/`**: Client Supabase (`supabase.ts`), panggilan API produk, pesanan, dan user.
- **`storage/`**: Helper pembaca/penulis LocalStorage atau IndexedDB.
- **`pwa/`**: Service Worker updater dan PWA helpers.

### 3. `src/types/` (Model & Tipe Data)
Tempat menyimpan tipe data TypeScript murni.
- `product.ts`: Model data produk, kategori, dan filter.
- `seller.ts`: Model data toko / penjual.
- `order.ts`: Model data transaksi, item keranjang, dan pengiriman.
- `user.ts`: Model profil pengguna dan role (buyer/seller).
- `supabase.ts`: Tipe data tabel Supabase Database.

### 4. `src/utils/` (Helper & Utilities)
Fungsi pembantu yang tidak terikat pada UI atau Data tertentu.
- `cn.ts`: Classname merger (clsx + tailwind-merge).
- `formatters.ts`: Helper format mata uang Rupiah (`formatRupiah`), tanggal, dan angka.

---

## 📌 Aturan Ketergantungan (Dependency Rules)

1. `types/` tidak boleh mengimpor komponen dari `ui/` atau client dari `services/`.
2. `utils/` adalah fungsi murni (pure functions) yang berdiri sendiri.
3. `ui/` boleh mengimpor dari `services/`, `types/`, dan `utils/`.
