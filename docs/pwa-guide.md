# PWA Setup & Deployment Guide

Panduan lengkap mengenai integrasi PWA (Progressive Web App) pada proyek **Snapan Market Mobile**.

---

## ⚙️ 1. Konfigurasi `vite-plugin-pwa`

Konfigurasi PWA diatur di file `vite.config.ts`:

- **Display Mode**: `"standalone"` agar web terbuka tanpa URL bar browser saat di-install di HP.
- **Service Worker**: `autoUpdate` untuk pembaruan transparan.
- **Caching**: Menyimpan file HTML, JS, CSS, dan gambar secara otomatis di browser cache.

---

## 📱 2. Pengujian PWA Secara Lokal

1. **Jalankan Build Production**:
   ```bash
   npm run build
   ```

2. **Jalankan Preview Server**:
   ```bash
   npm run preview
   ```

3. Buka URL yang dihasilkan di Chrome/Safari. Buka **Chrome DevTools (F12) -> Application -> Manifest & Service Workers** untuk memverifikasi pendaftaran PWA.

---

## 🚀 3. Langkah Deployment Web (Vercel / Netlify / Cloudflare)

1. Connect repository ini ke platform deployment pilihan Anda (Vercel / Netlify / Cloudflare Pages).
2. Set Build Command: `npm run build`
3. Set Output Directory: `dist`
4. Masukkan Environment Variables:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
5. Deploy! Aplikasi PWA Anda akan otomatis memiliki HTTPS dan siap di-install oleh pengguna di seluruh dunia.
