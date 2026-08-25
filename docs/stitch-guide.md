# 🎨 GOOGLE STITCH MCP & VISUAL IDEATION GUIDE
## Snapan Market Mobile PWA — Design & Layouting Exploration Rules

---

## 📌 1. FILOSOFI & TUJUAN PENGGUNAAN GOOGLE STITCH

> [!IMPORTANT]
> **PERAN UTAMA GOOGLE STITCH**:
> Google Stitch digunakan secara eksklusif sebagai **Alat Eksplorasi Visual & Layouting Cepat (Rapid Visual Ideation & Wireframing)** untuk memberikan gambaran arsitektur UI kepada tim/pengembang.
> 
> **STITCH BUKAN PATOKAN KODE PRODUKSI**:
> - Kode/desain yang dihasilkan oleh Stitch **bukan acuan styling kaku**.
> - Kode final produksi **wajib** mengikuti standar internal: **React 18 + Vite + Tailwind CSS v4 + Kumo UI Button System + Electric Indigo (`#3d38f5`)**.

---

## 🤖 2. ATURAN WAJIB AI AGENT SAAT BERHUBUNGAN DENGAN GOOGLE STITCH

Setiap AI Agent (Antigravity, Cursor, Claude, Copilot, dll.) **WAJIB MEMATUHI 4 ATURAN EMAS BERIKUT**:

### 1. Format Prompt "Ready-to-Paste"
Ketika diminta membuat rancangan layout untuk Stitch, AI Agent wajib menyusun prompt terstruktur yang siap langsung di-copy-paste oleh user ke antarmuka Google Stitch / MCP tool `generate_screen_from_text`.

### 2. Standar Struktur Prompt Stitch (7-Block Blueprint)
Setiap prompt untuk Stitch **harus** memiliki 7 elemen berikut:
1. **Device Target**: *Mobile-first viewport (iPhone / Android 390px-420px width)*.
2. **Theme & Background**: *Clean modern neutral slate `#f8fafc` / `#ffffff` with high contrast*.
3. **Primary Signature Color**: *Electric Indigo `#3d38f5` with soft pastel tint `#eef0ff`*.
4. **Header Navigation**: *Sticky permanent top bar `h-14` with Back arrow, centered title, action badge*.
5. **Core Content Structure**: *Visual cards, layout blocks, spacing (8pt/16pt grid), typography hierarchy*.
6. **Bottom Thumb Zone**: *Sticky edge-to-edge dock bar (`fixed bottom-0`) or floating Kumo action button*.
7. **Micro-Interactions & State Details**: *Active highlight states, badges, rating stars, pills*.

### 3. Ekstraksi Data Proyek Otomatis
AI Agent tidak boleh membuat prompt umum/generik. Prompt wajib mengikutsertakan konteks nyata proyek **Snapan Market Mobile SMKN 8 Semarang** (jurusan PPLG/DKV, titik COD Kantin/Lobi/Lab, harga rupiah, dan etika privasi siswa).

---

## 🏢 3. INFORMASI UTAMA PROJEK (PROJECT CONTEXT SHEET)

Bagi AI Agent dan tools eksternal, berikut ringkasan seluruh entitas sistem:

### A. Visi & Target Pengguna
- **Aplikasi**: Snapan Market Mobile PWA.
- **Tujuan**: Platform marketplace C2C intra-sekolah mobile-first terpercaya untuk siswa dan guru SMKN 8 Semarang.
- **Safety Policy**: 100% In-App Chat, dilarang kontak WhatsApp/telepon eksternal untuk perlindungan privasi siswa.

### B. Design System & Design Tokens
- **Signature Brand Color**: Electric Indigo `#3d38f5` (WCAG Contrast 6.45:1).
- **Brand Hover**: `#312bd9` | **Pastel Tint**: `#eef0ff` | **Border**: `#d8dbfe`.
- **Background**: Pure White `#ffffff` & Slate Gray `#f8fafc`.
- **Button System**: **Kumo UI Button** (Dual-layer gradient fill, top highlight specular border, subtle shadow depth, active tactile scale 0.97).
- **Typography**: GT Standard / System Sans (Bold headings, compact subtitles, tabular numbers for currency).

---

## 📋 4. KATALOG PROMPT "READY-TO-PASTE" UNTUK GOOGLE STITCH

Berikut kumpulan prompt yang sudah dioptimasi untuk kamu paste langsung ke Google Stitch:

---

### 🌟 PROMPT 1: Halaman Denah COD 2D Interaktif (Campus Map COD Picker)

```text
Create a modern mobile-first interactive 2D Campus Map & COD Meeting Point Selector screen for a school marketplace app called "Snapan Market Mobile (SMKN 8 Semarang)".

Device: Mobile screen (390px width), clean iOS/Android app aesthetic.
Design Style: Minimalist architectural vector blueprint, crisp lines, modern tech vibe.

Layout Structure:
1. Top Sticky Navigation Bar:
   - Clean white header (h-14) with subtle bottom border.
   - Left: Rounded squircle Back button [ ← ].
   - Center: Bold title "Denah COD SMKN 8" with subtitle "Pilih Titik Temu Pesanan".
   - Right: Minimalist Compass status icon.

2. Interactive Map Viewport (Main Center Area):
   - Full 2D Top-down architectural vector layout representing SMKN 8 Semarang grounds.
   - Road on the left marked "Jl. Pandanaran 2" with clean asphalt gray and white dashed markings.
   - L-Shaped Main School Building on top/left with distinct room partitions: [LOBI UTAMA], [RUANG GURU], [KELAS PPLG], [PERPUSTAKAAN].
   - Central building: [AULA UTAMA SERBAGUNA] with subtle joglo roof lines.
   - Right building: [STUDIO ANIMASI DKV].
   - Bottom-right angled building: [KANTIN PUJASERA] with small picnic tables.
   - Center green lawn courtyard with a mini basketball/futsal court.
   - Floating Floor Selector pill at top-right with [Lt 1] (active in Electric Indigo #3d38f5) and [Lt 2].
   - Selected Room State: "Kantin Utama" highlighted in soft pastel indigo (#eef0ff) with Electric Indigo (#3d38f5) border and a glowing pulsing radar pin.

3. Floating Bottom Detail Sheet (Thumb Zone):
   - Frosted glass white card with rounded 24px corners and subtle drop shadow.
   - Category Badge: "🥪 Kantin & Makanan" in pastel indigo tag.
   - Title: "Kantin Utama & Pujasera Siswa" (Bold 16px).
   - Hint: "Titik COD paling ramai saat jam istirahat. Dekat stan minuman jus."
   - Action Button: Full-width modern Kumo UI button in Electric Indigo (#3d38f5) with checkmark icon and text "Gunakan Titik Temu Ini".
```

---

### 🌟 PROMPT 2: Halaman Checkout Pesanan dengan Kartu Denah COD (Order Checkout Screen)

```text
Create a polished, mobile-first E-Commerce Checkout Screen for "Snapan Market Mobile PWA" (School Marketplace).

Device: Mobile screen (390px width), edge-to-edge layout, modern clean retail design.
Color Palette: Electric Indigo #3d38f5 as primary brand accent, crisp white #ffffff, neutral slate borders.

Layout Structure:
1. Permanent Sticky Top Header:
   - Height 56px, backdrop blur white.
   - Left: Circular back button [ ← ].
   - Center: Bold title "Checkout Pesanan".
   - Right: Like bookmark heart button.

2. Scrollable Body Content:
   - Product Summary Header: Small square product thumbnail of an item ("Kabel Type-C Braided"), title, price "Rp 25.000", seller badge "Raditya Rayhan (XI PPLG 1)".
   - In-App Seller Contact Card: Clean card with seller avatar, verified student badge, and 2 In-App action buttons: [💬 Chat Penjual] (Primary Indigo) and [👤 Lihat Profil] (Secondary White).
   - Section 1: COD Meeting Location Card (Core Feature):
     * Card title with MapPin icon: "Lokasi Titik Temu (COD)".
     * Selected location preview box: "Kantin Utama & Pujasera (Lantai 1)" with a mini 2D map thumbnail preview.
     * Secondary button: "🗺️ Ubah Titik Temu di Denah 2D".
   - Section 2: Buyer Note (Catatan untuk Penjual):
     * Clean textarea with placeholder "Contoh: Ketemu pas jam istirahat kedua ya bro di meja jus...".
   - Section 3: Ringkasan Pembayaran (Payment Summary):
     * Line items: Harga Barang (Rp 25.000), Biaya Layanan COD Siswa (Rp 0 / Gratis), Total Tagihan (Rp 25.000, bold 18px in #3d38f5).

3. Edge-to-Edge Sticky Bottom Dock Bar (Fixed Bottom-0):
   - White container with top border and subtle shadow.
   - Left: Total price label "Total Bayar" and price "Rp 25.000".
   - Right: Large primary Kumo UI action button in Electric Indigo (#3d38f5) with lock security icon: "Konfirmasi Pesanan COD 🚀".
```

---

### 🌟 PROMPT 3: Threads-Style Social Marketplace Feed (Home Feed)

```text
Create a mobile-first Social Marketplace Feed screen inspired by Instagram Threads and modern campus marketplaces for "Snapan Market Mobile".

Device: Mobile viewport (390px width), dark text on ultra-clean white background.
Style: Threads-style conversational layout, minimal border separators, high visual polish.

Layout Structure:
1. Top Header Bar:
   - Left: Hamburger Menu Drawer button.
   - Center: Bold wordmark "Snapan." with small Electric Indigo dot.
   - Right: Search magnifying glass icon and Notification bell with small unread badge.

2. Category Scroll Chips:
   - Horizontal scrollable pills: [✨ Semua], [💻 Elektronik & IT], [🥪 Jajanan Kantin], [📚 Buku & Modul], [🎨 Jasa Desain/Coding].

3. Social Feed Post Cards (Threads-Style Timeline):
   - Post 1:
     * Author Header: Student Avatar, "Budi Santoso", handle "@budikoding", badge "XI PPLG 2", time "10m".
     * Content: "Ada yang butuh modul Laravel & React PPLG semester ini? Kondisi masih mulus banget bonus stiker koding! 💻🔥".
     * Product Card Attachment: Clean inset rounded card with image of textbook, title "Buku Sakti Web Development", price tag pill "Rp 35.000", status "Tersedia".
     * Location Tag: In-app pill "📍 Titik Temu: Lab Software RPL 1".
     * Interaction Footer: [❤️ 24 Suka] [💬 8 Komentar] [🔗 Bagikan] [⚡ Beli Sekarang Button].

4. Bottom Floating Action:
   - Minimalist floating action pill at bottom center: "+ Buat Postingan Baru" in Electric Indigo (#3d38f5).
```

---

## 🛠️ 5. CARA MENGGUNAKAN DENGAN MCP STITCH SERVER

Jika MCP Server Google Stitch aktif di environment-mu:
1. AI Agent dapat memanggil tool `generate_screen_from_text` dengan menyertakan prompt di atas.
2. Hasil screen dapat dilihat dan di-tweak variannya menggunakan tool `generate_variants` atau `edit_screens`.
3. Gunakan hasil visual Stitch sebagai **referensi wireframing layout**, lalu terapkan kode final menggunakan komponen React + Tailwind CSS v4 internal kita.
