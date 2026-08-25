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
- **SOP 5-Langkah Wajib AI Agent Laptop B**:
  1. **Tulis SQL & RLS**: Catat skema tabel baru & Row Level Security (RLS) di `/docs/supabase-guide.md`.
  2. **Update Type Contract**: Tambahkan interface Row/Insert/Update di `src/types/supabase.ts`.
  3. **Buat API Service**: Buat/update fungsi query di `src/services/api/<feature>Service.ts` dengan return type yang ketat.
  4. **Type Check**: Jalankan `npx tsc --noEmit && npm run build` untuk memastikan 0 error.
  5. **Push ke Git**: Lakukan `git commit` & `git push` agar Laptop A bisa langsung `git pull`.

---

## 🚨 ATURAN EMAS SINKRONISASI AI AGENT (MANDATORY WORKFLOW)

Setiap AI Agent (Antigravity, Cursor, Claude, Copilot, dll.) **WAJIB MEMATUHI 2 PROTOKOL SINKRONISASI BERIKUT**:

### 1. 📥 PROTOKOL PRE-TASK: `git pull origin main` SEBELUM Mulai
- **KAPAN**: Sebelum memulai analisis, membuat file baru, atau mengedit fitur apapun.
- **AKSI**: Jalankan perintah `git pull origin main`.
- **TUJUAN**: Memastikan repositori lokal 100% up-to-date dengan commit terbaru dari laptop/rekan workstation lain untuk mencegah *merge conflict* dan *outdated context*.

### 2. 🚀 PROTOKOL POST-TASK: Auto `git commit` & `git push` Setelah Selesai
- **KAPAN**: Segera setelah pekerjaan selesai dan lolos verifikasi build.
- **URUTAN EKSEKUSI**:
  1. `npx tsc --noEmit && npm run build` $\rightarrow$ Pastikan **0 Error**.
  2. `git add .`
  3. `git commit -m "<type>(<scope>): <deskripsi perubahan>"`
  4. `git push -u origin main`
- **TUJUAN**: Menjamin hasil kerja langsung ter-deploy otomatis di Vercel dan siap di-`git pull` oleh workstation lain secara instan.

---

## 🔄 WORKFLOW KOLABORASI GIT (FRONTEND & BACKEND SYNC)

```
[SEBELUM MULAI TASK] ───> 📥 git pull origin main (WAJIB SINKRON AWAL)
                                │
[LAPTOP B - BACKEND]            │               [LAPTOP A - FRONTEND]
 1. Update Skema di Supabase    │                1. Gunakan tipe dari src/types/supabase.ts
 2. Update SQL di docs/guide    │                2. Buat/Update UI Komponen & Pages di src/ui/
 3. Update src/types/supabase.ts│                3. Lakukan pengujian tampilan & responsive
                                │
[SETELAH TASK SELESAI] ─────────┴───────────────> 🚀 Build Check (tsc + vite) -> git commit & push (WAJIB AUTO PUSH)
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
- [/docs/stitch-guide.md](file:///home/rayhan/Windows-D/project/snapan-market-mobile/docs/stitch-guide.md)
