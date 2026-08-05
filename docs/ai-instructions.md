# Instructions for AI Coding Agents (Laptop A & Laptop B)

Dokumen ini adalah instruksi khusus untuk AI Agent yang mengerjakan atau menambah fitur pada repository **Snapan Market Mobile**.

---

## 🛑 ATURAN UTAMA UNTUK AI AGENT

1. **BACA DOKUMEN `AGENTS.md` DI ROOT REPOSITORI**:
   - AI Agent **wajib** mengikuti aturan peran di `AGENTS.md` sesuai workstation (Laptop A Frontend / Laptop B Backend).

2. **JANGAN MERUSAK STRUKTUR FOLDER**:
   - Selalu tempatkan file baru sesuai dengan pembagian folder:
     - `src/ui/` -> Halaman (`pages/`), Komponen (`components/`), State (`store/`), Hooks (`hooks/`)
     - `src/services/` -> API (`api/`), Storage (`storage/`), PWA (`pwa/`)
     - `src/types/` -> Definisi tipe TypeScript
     - `src/utils/` -> Helper murni

3. **WORKFLOW DOKUMEN & KONTRAK DATA (LAPTOP B -> LAPTOP A)**:
   - Apabila AI Agent bekerja di **Laptop B (Backend)**: Wajib memperbarui `/docs/supabase-guide.md` dan `src/types/supabase.ts` setiap ada perubahan skema database.
   - Apabila AI Agent bekerja di **Laptop A (Frontend)**: Selalu gunakan tipe data dari `src/types/` dan jangan mengubah RLS SQL.

4. **GUNAKAN PATH ALIAS `@/`**:
   - Selalu gunakan `@/ui/...`, `@/services/...`, `@/types/...`, `@/utils/...` alih-alih relative path bertingkat seperti `../../../../`.

5. **DESAIN & TAMPILAN HARUS MEMUKAU (WOW FACTOR)**:
   - Gunakan estetika modern: Dark mode (`slate-950`), aksen hijau emerald (`emerald-500`), efek glassmorphism (`glass-effect`), dan mikro-animasi.

6. **PWA & MOBILE-FIRST ALWAYS**:
   - Pastikan setiap komponen UI baru nyaman digunakan pada layar HP (touch-friendly).
