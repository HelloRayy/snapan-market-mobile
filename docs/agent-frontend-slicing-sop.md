# Master SOP: Autonomous Web-to-Mobile Frontend Slicing (>= 90% Parity)

> **Dokumen Panduan & Protokol Eksekusi Otonom AI Agent (Mode `/goal`)**  
> *Target Standar: Kemiripan Visual, Spasial, dan Layout minimal **90% - 96%** terhadap Source of Truth Web React (`src/`).*

---

## 📌 1. Tujuan & Filosofi Desain

Dokumen ini adalah **aturan operasional wajib (Mandatory Protocol)** bagi seluruh Agen AI yang bekerja pada proyek **Snapan Market Mobile**. Dokumen ini mengatur tata cara memporting halaman dari **Web React 18 + TypeScript + Tailwind CSS v4** (`src/`) ke **Flutter Mobile** (`lib/`) secara presisi, terisolasi, dan bebas distraksi backend.

```
┌────────────────────────────────────────────────────────┐
│                   SOURCE OF TRUTH                      │
│            100% Web React Codebase (src/)              │
│   src/ui/pages/ & src/ui/components/ & src/index.css   │
└───────────────────────────┬────────────────────────────┘
                            │ (1:1 Token & Layout Translation)
┌───────────────────────────▼────────────────────────────┐
│               FLUTTER FRONTEND LAYER                   │
│   lib/features/<page>/screens/ & components/           │
│   (100% Typed Mock Dataset + 93%-96% Visual Parity)    │
└────────────────────────────────────────────────────────┘
```

---

## 🛡️ 2. Aturan Emas Agen AI (Mandatory Agent Execution Directives)

Setiap agen AI yang menerima perintah pembuatan halaman (misal: *"buat chatPage mirip dengan web"* pada mode `/goal`) **WAJIB mematuhi 6 aturan baku**:

### 1. **Aturan 1: Source of Truth Mutlak Adalah `src/`**
* Agen **DILARANG** mengarang desain atau berasumsi.
* Agen **WAJIB** membuka dan membaca file halaman terkait di `src/ui/pages/` dan komponen pendukungnya di `src/ui/components/` sebelum menulis 1 baris pun kode Flutter.
* Salin seluruh nilai warna hex, font-size, padding, margin, border-radius, dan icon shape langsung dari kelas Tailwind / CSS terkait.

### 2. **Aturan 2: Isolasi Cakupan Ketat (Strict Scope Boundary)**
* Agen hanya membuat **halaman yang diperintahkan secara eksplisit**.
* *Contoh:* Jika pengguna meminta `DirectMessagesPage` (daftar inbox DM), agen **DILARANG** melompat membuat `ChatRoomPage` (isi percakapan) sebelum ada instruksi khusus.
* Fokus energi pada kesempurnaan halaman target tanpa membengkak (*no scope creep*).

### 3. **Aturan 3: Kebijakan 100% Mock-Only untuk Fase Frontend**
* Selama fase slicing frontend, **DILARANG KERAS** menyentuh / membuat query ke live Supabase backend.
* Semua data wajib menggunakan **Mock Dataset Lokal Bertipe Ketat** yang disimpan di `lib/features/<feature>/models/mock_<feature>_data.dart`.
* Struktur field mock **wajib 1:1** dengan domain interface di `src/types/` dan `docs/fe-to-be-data-contract.md`.

### 4. **Aturan 4: Standardisasi Garis Pemisah (Ultra-Thin 0.5px #F1F5F9)**
* Semua garis separator antar card, divider komentar, bottom border AppBar, dan list item wajib menggunakan:
  ```dart
  border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 0.5))
  ```
* Dilarang menggunakan `width: 1.0` atau `Colors.grey` yang membuat garis terlihat tebal di layar mobile retina.

### 5. **Aturan 5: Standardisasi Ikon Lucide (Custom Painter Priority)**
* Web codebase menggunakan library **Lucide React**.
* Untuk glyph ikon khas (seperti *Lucide 3D Box*, *Curved Repost Arrows*, *Heart Outline*, *Paperplane Share*, *MapPin*), agen **WAJIB menggunakan/membuat Custom Painter** di `market_feed_icons.dart` agar bentuk lekukan ikon identik 100% dengan web.

### 6. **Aturan 6: Dilarang Menjalankan Command Test/Analyzer**
* Sesuai `AGENTS.md`, **DILARANG** menjalankan `flutter test`, `flutter analyze`, atau command verification berat yang memboroskan token dan waktu.
* Fokus 100% pada penulisan kode sintaksis yang benar secara arsitektur dalam satu kali jalan.

---

## 📊 3. Matriks Jaminan Kemiripan Visual (Visual Parity Breakdown)

| No | Aspek Visual | Bobot | Jaminan Parity | Tolok Ukur Pengukuran |
| :--- | :--- | :---: | :---: | :--- |
| **1** | **Warna & Design Tokens** | **25%** | **99% – 100%** | Seluruh kode warna hex disalin 1:1 dari `@theme` di `src/index.css` & Tailwind (`#3d38f5`, `#1d64ec`, `#f1f5f9`, `#0f172a`, dan alpha opacity). |
| **2** | **Spatial Layout & Spacing** | **25%** | **95% – 98%** | Padding, margin gap, hierarki Flexbox -> Row/Column, border-radius (`rounded-xl`/`22px`), dan ketebalan garis (`0.5px`). |
| **3** | **Iconography & Shapes** | **20%** | **95% – 98%** | Menggunakan **Custom Painter Lucide SVG paths** (bukan ikon generik Material), sehingga lekukan ikon (Heart, Box 3D, Repost, Share) 100% sama dengan web. |
| **4** | **Typography & Hierarchy** | **15%** | **90% – 94%** | Ukuran font (`text-[14.5px]`), weight (`w400`/`w600`/`w700`), tracking (`letterSpacing: -0.1`), dan line-height (`height: 1.35`). |
| **5** | **Komponen Khas Kumo UI** | **15%** | **92% – 95%** | Tombol Kumo dual-layer gradient, specular top highlight shine 1px, glow shadow pendar, dan tactile scale `0.94x`. |
| **Σ** | **TOTAL COMPOSITE PARITY** | **100%** | **93.5% – 96%** | **Target minimum 90% TERLAMPAUI.** |

---

## ⚠️ 4. Katalog Risiko & Faktor Kegagalan Parity (Parity Failure Modes)

Berikut adalah 7 faktor teknis utama yang berpotensi menggagalkan target kemiripan 90% jika agen tidak berhati-hati:

```
┌────────────────────────────────────────────────────────────────────────────┐
│                   7 PARITY PITFALLS & GUARDRAILS                           │
├────────────────────────────────────────────────────────────────────────────┤
│ 1. Line-Height & Font Baseline:                                            │
│    Web `leading-relaxed` != Flutter default. Wajib set `height: 1.35` dan   │
│    `letterSpacing: -0.1`. Gunakan `Text.rich` (hindari raw `RichText`).     │
├────────────────────────────────────────────────────────────────────────────┤
│ 2. Separator Line Thickness:                                               │
│    `1.0px` di mobile terlihat tebal. Selalu gunakan `width: 0.5` #F1F5F9.   │
├────────────────────────────────────────────────────────────────────────────┤
│ 3. Missing Specular Highlight on Kumo Buttons:                             │
│    Jangan buat tombol flat. Pasang gradient [0xFF3B82F6 -> 0xFF1D64EC] +   │
│    top shine 1px white (0.35 alpha) + border 0xFF154EC1 + glow shadow.     │
├────────────────────────────────────────────────────────────────────────────┤
│ 4. Generic Material Icons:                                                 │
│    Hindari `Icons.favorite` default. Gunakan Lucide Custom Painter.        │
├────────────────────────────────────────────────────────────────────────────┤
│ 5. Keyboard & Viewport Occlusion:                                          │
│    Gunakan `viewInsets.bottom` pada dock mengambang + touch-outside unfocus│
├────────────────────────────────────────────────────────────────────────────┤
│ 6. Image Overflow & Aspect Distortion:                                     │
│    Wajib gunakan `ClipRRect(borderRadius: 14px)` + `BoxFit.cover` +        │
│    `AspectRatio` atau `BoxConstraints(maxHeight: 220)`.                    │
├────────────────────────────────────────────────────────────────────────────┤
│ 7. Dirty Heavy Box Shadows:                                                │
│    Gunakan soft shadow: `BoxShadow(color: Color(0x14000000), blur: 16.0)`. │
└────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 5. Siklus Validasi Ganda Mandiri (Self-Audit Protocol)

Sebelum menandai tugas selesai atau melakukan commit, agen AI **WAJIB menjalankan 2 tahapan audit**:

### 🔍 Tahap 1: Codebase Inspection Audit
Bandingkan file `src/ui/pages/<Page>.tsx` vs `lib/features/<feature>/screens/<page>_screen.dart`:
- [ ] Apakah warna background utama sama (`#FFFFFF` atau `#F2F4F5`)?
- [ ] Apakah seluruh font size, weight, dan tracking sudah cocok?
- [ ] Apakah semua border memakai `0.5px #F1F5F9`?
- [ ] Apakah tombol aksi sudah mengadopsi Kumo Button spec?

### 📱 Tahap 2: Visual & Ergonomics Audit
- [ ] Apakah halaman terhubung dengan benar di Bottom Nav / Drawer / Router?
- [ ] Apakah tata letak elemen muat dengan rapi di viewport HP tanpa *overflow pixel warning*?
- [ ] Apakah keyboard dismiss berfungsi saat area luar disentuh?

---

## 🚀 6. Otomasi Git Workflow
Setelah audit mandiri lolos:
1. `git add .`
2. Commit dengan format Conventional Commit:
   ```bash
   git commit -m "<type>(<scope>): <deskripsi perubahan>"
   ```
3. Push ke remote repository:
   ```bash
   git push origin main
   ```
