# [SNAPS-35] change(icon): icon apps sekarnag rectangle di bg base white nya, ganti dengan radius atau kasi transparant bg saja

> **Ticket Metadata**:
> - **Plane ID**: `51c3cbfd-8bc9-4683-bcd7-c96cdc7cf193`
> - **Sequence**: SNAPS-35
> - **Priority**: LOW
> - **State Group**: completed
> - **Domain**: `branding / ui / asset`

---

## 1. Problem Statement & User Context
- **Deskripsi Asli Plane**:
> Probelm Context Banyak app diluar sana sekarng menerapkan radius / background transpanart pada logo apps nya. masalah yang sedang kita hadapin sekarng Logo Apps snaps kita memiliki background white dengan NO RADIUS. jadi terlihat seperit Rectangle dengna logo tengah snaps. Kita bisa explore logo ini, mungkin dengan diberikan NO BACKGROUND at all, atau kita kasi corner radius agar sesuai dengan app yang lain

- **Akar Masalah Teknis**: Icon aplikasi dan favicon web sebelumnya memiliki background putih berbentuk persegi (rectangle) tanpa corner radius (sudut siku-siku 90° dengan corner pixel putih solid `(255, 255, 255, 255)` dan transparansi 0.0%), sehingga terlihat kaku di dashboard admin dan launcher.

---

## 2. Target File Scope (Interface-First Coupling)
> Rujukan arsitektur berdasarkan `AGENT_MANIFEST.md`:

| Peran File | Path File di Repositori | Keterangan Peran |
| :--- | :--- | :--- |
| **Generator Script** | [`scripts/generate-snaps-icons.py`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/scripts/generate-snaps-icons.py) | Generator aset ikon PWA, Favicon (ICO + SVG), dan Android Mipmap |
| **Web Entrypoint** | [`index.html`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/index.html) | Referensi favicon.svg, favicon.ico, dan apple-touch-icon.png |
| **Favicon Vector** | [`public/favicon.svg`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/public/favicon.svg) | Favicon berbasis vektor crisp untuk browser tab modern |
| **Favicon Multi-Res** | [`public/favicon.ico`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/public/favicon.ico) | Multi-resolution favicon (16, 32, 48, 64) dengan corner squircle transparan |
| **PWA Web Icons** | [`public/apple-touch-icon.png`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/public/apple-touch-icon.png), [`public/pwa-192x192.png`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/public/pwa-192x192.png), [`public/pwa-512x512.png`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/public/pwa-512x512.png) | Aset PWA ber-squircle radius 22.5% |
| **Mipmap Drawables** | [`android/app/src/main/res/mipmap-*/ic_launcher.png`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png) | Aset grafis launcher icon Android dengan corner radius halus |

---

## 3. Implementation Details (Opsi 2: Apple-Style Squircle)
1. **Supersampled Squircle Anti-Aliasing (4x)**: Menggambar rounded rectangle dengan radius 22.5% pada resolusi 4x, lalu di-downsample menggunakan filter `LANCZOS` ke ukuran target sehingga transisi kurva luar menjadi transparan sempurna `(0, 0, 0, 0)`.
2. **Dual-Format Web Favicon**:
   - `favicon.svg`: Vektor SVG 512x512 dengan `<rect rx="115" ry="115" fill="#FFFFFF"/>` dan logo Snaps presisi di tengah, memberikan tampilan ultra tajam pada monitor Retina/4K.
   - `favicon.ico`: Embedded multi-size (16x16, 32x32, 48x48, 64x64) dengan sudut transparan.
3. **PWA & Android Launcher Sync**: `apple-touch-icon.png`, `pwa-192x192.png`, `pwa-512x512.png`, dan mipmap Android (mdpi sampai xxxhdpi) ter-generate ulang dengan corner radius konsisten.

---

## 4. Definition of Done (DoD)
- [x] Favicon web dan dashboard admin tidak lagi berupa kotak persegi kaku 90°.
- [x] Corner pixel `(0, 0)` berstatus transparan `(0, 0, 0, 0)` pada favicon dan ikon PWA.
- [x] Favicon SVG ultra-tajam tersedia dan terhubung di `index.html`.
- [x] Seluruh ukuran mipmap Android dan ikon PWA ter-generate rapi.

