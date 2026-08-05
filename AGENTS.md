# 🤖 AGENTS.md — Instructions for AI Coding Agents

Dokumen ini adalah **panduan utama & aturan wajib (System Instructions)** yang dibaca oleh seluruh AI Coding Agent (Antigravity, Cursor, Copilot, Claude, dll.) saat repositori **Snapan Market Mobile** di-`git clone`.

---

## 📌 OVERVIEW PROYEK

- **Nama Proyek**: Snapan Market Mobile PWA
- **Tech Stack**: React 18 + Vite + Tailwind CSS v4 + PWA (`vite-plugin-pwa`) + Supabase Auth & Database + Zustand.
- **Tujuan**: Platform E-Commerce & Marketplace PWA mobile-first yang cepat, installable, dan berjalan offline.

---

## 💻 PEMBAGIAN ROLE WORKSTATION (LAPTOP A vs LAPTOP B)

Repositori ini dikembangkan menggunakan **Multi-Laptop Workstation Setup**:

### 1. 🖥️ LAPTOP A — FRONTEND WORKSTATION
- **Fokus Utama**: Mengembangkan tampilan UI/UX, komponen React, Halaman Web, Styling Tailwind, & PWA.
- **Area Kerja**:
  - `src/ui/pages/` (Halaman: Home, Cart, Profile, ProductDetail)
  - `src/ui/components/` (Komponen UI dasar & marketplace primitives)
  - `src/ui/store/` (State management Zustand)
  - `src/ui/hooks/` (Custom hooks UI & PWA)
  - `src/index.css` (Tailwind CSS v4 styling & theme)
- **Aturan Laptop A**:
  - **DILARANG** mengubah struktur tabel database atau SQL scripts secara sepihak.
  - **WAJIB** mengonsumsi tipe data dari `src/types/supabase.ts` yang sudah diperbarui oleh Laptop B via `git pull`.

---

### 2. 🗄️ LAPTOP B — BACKEND WORKSTATION
- **Fokus Utama**: Mengembangkan Supabase Database Schema, SQL Queries, RLS Security Policies, & API Services.
- **Area Kerja**:
  - `/docs/supabase-guide.md` (Update SQL scripts schema & RLS policy)
  - `src/services/api/` (Setup Supabase Client & API Service Functions)
  - `src/types/supabase.ts` (Update interface tipe data Supabase sesuai skema tabel terbaru)
  - `.env.example` (Konfigurasi environment variable backend)
- **Aturan Laptop B**:
  - Setiap ada perubahan skema database / tabel baru di Supabase, **WAJIB** memperbarui script SQL di `/docs/supabase-guide.md` dan men-generate/memperbarui `src/types/supabase.ts`.
  - Kemudian lakukan `git commit` dan `git push` agar Laptop A bisa melakukan `git pull` untuk mendapatkan kontrak tipe data terbaru.

---

## 🔄 WORKFLOW KOLABORASI GIT (FRONTEND & BACKEND SYNC)

```
[LAPTOP B - BACKEND]                           [LAPTOP A - FRONTEND]
 1. Buat/Update Tabel di Supabase               1. git pull
 2. Update SQL Script di /docs/supabase-guide   2. Gunakan tipe dari src/types/supabase.ts
 3. Update src/types/supabase.ts                3. Buat UI Komponen & Pages di src/ui/
 4. git commit & push                            4. git commit & push UI
```

---

## 🚨 DONTs (HAL YANG TIDAK BOLEH DILAKUKAN AI AGENT)

1. ❌ **Jangan menghapus atau merusak struktur folder**:
   - `ui/` -> Tampilan
   - `services/` -> API & Data Fetching
   - `types/` -> Interfaces TypeScript
   - `utils/` -> Helper murni
2. ❌ **Jangan membuat mock data lokal palsu** saat Supabase Client sudah tersedia di `src/services/api/supabase.ts`.
3. ❌ **Jangan menggunakan relative path bertingkat** (seperti `../../../../`). Gunakan path alias `@/` (contoh: `@/ui/components/ui/Button`).
4. ❌ **Jangan mengabaikan tipe data TypeScript**. Gunakan strict typing murni.

---

## ⚡ PETUNJUK MEMULAI (POST GIT CLONE)

Setelah `git clone`, jalankan langkah berikut:

```bash
# 1. Install dependencies
npm install

# 2. Buat file .env dari template
cp .env.example .env

# 3. Jalankan server lokal
npm run dev
```

Untuk detail teknis lebih lanjut, baca dokumen pendukung di folder `/docs/`:
- [/docs/architecture.md](file:///home/rayhan/Windows-D/project/snapan-market-mobile/docs/architecture.md)
- [/docs/multi-laptop-setup.md](file:///home/rayhan/Windows-D/project/snapan-market-mobile/docs/multi-laptop-setup.md)
- [/docs/coding-standards.md](file:///home/rayhan/Windows-D/project/snapan-market-mobile/docs/coding-standards.md)
- [/docs/pwa-guide.md](file:///home/rayhan/Windows-D/project/snapan-market-mobile/docs/pwa-guide.md)
- [/docs/supabase-guide.md](file:///home/rayhan/Windows-D/project/snapan-market-mobile/docs/supabase-guide.md)
