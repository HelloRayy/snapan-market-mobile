# Multi-Laptop Workstation Setup Guide (Laptop A Frontend & Laptop B Backend)

Dokumen ini menjelaskan alur kerja dan konfigurasi terpisah antara **Laptop A (Khusus Frontend)** dan **Laptop B (Khusus Backend Supabase)**.

---

## 🎯 Pembagian Peran Workstation

### 🖥️ Laptop A (Frontend Workstation)
- **Tugas Utama**: Membangun tampilan aplikasi web & PWA mobile yang indah, responsif, dan kaya animasi.
- **Tools Utama**: React, Tailwind CSS v4, Zustand, Lucide Icons, Vite PWA.
- **Folder Utama**:
  - `src/ui/pages/`
  - `src/ui/components/`
  - `src/ui/store/`
  - `src/ui/hooks/`

### 🗄️ Laptop B (Backend Workstation)
- **Tugas Utama**: Mengelola database Supabase, skema tabel, RLS policies, autentikasi Google OAuth, dan API Client services.
- **Tools Utama**: Supabase Dashboard / SQL Editor, Supabase JS Client, TypeScript interfaces generator.
- **Folder Utama**:
  - `src/services/api/`
  - `src/types/supabase.ts`
  - `/docs/supabase-guide.md`

---

## 🔄 Alur Kolaborasi & Sinkronisasi Git (Aturan Wajib Multi-Workstation)

1. **Pre-Task (Sebelum Mulai)**: Baik Laptop A maupun Laptop B **WAJIB** menjalankan `git pull origin main` sebelum mulai mengedit/menganalisis kode:
   ```bash
   git pull origin main
   ```
2. **Laptop B (Backend)** membuat tabel baru atau mengubah skema di Supabase Dashboard.
3. **Laptop B** memperbarui script SQL di `/docs/supabase-guide.md` dan tipe data di `src/types/supabase.ts`.
4. **Laptop B** melakukan type-check (`npx tsc --noEmit && npm run build`) lalu auto `git commit` & `git push`:
   ```bash
   git add .
   git commit -m "feat(backend): update database schema for orders table"
   git push origin main
   ```
5. **Laptop A (Frontend)** melakukan `git pull origin main` untuk menerima tipe data & API contract terbaru.
6. **Laptop A** membuat/mengupdate komponen UI lalu setelah selesai dan lolos type-check, langsung melakukan auto `git commit` & `git push`:
   ```bash
   git add .
   git commit -m "feat(ui): implement orders list page with status badge"
   git push origin main
   ```

---

## ⚡ Checkpoint Pengujian Bersama

- **Uji Integrasi API**: Pastikan file `.env` di Laptop A dan Laptop B berisi `VITE_SUPABASE_URL` dan `VITE_SUPABASE_ANON_KEY` yang menunjuk ke Supabase Project yang sama.
