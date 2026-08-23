# Rencana Implementasi: Reposisi Badge Lokasi ke Bawah Galeri Gambar

## 1. Analisis Masalah & Manfaat UX
- **Masalah Saat Ini**: Badge lokasi (`📍 Studio DKV Gedung B`) berada tepat di atas gambar (di bawah caption bersama badge `1/2`). Saat postingan berupa utas multi-part, terjadi penumpukan elemen di bagian atas (*top-heavy clutter*).
- **Solusi Desain**: Pindahkan badge lokasi agar berada **di bawah kartu galeri gambar (antara gambar dan action bar)**.
- **Keuntungan Visual**:
  - Alur baca lebih natural: Nama $\rightarrow$ Caption/Teks $\rightarrow$ Gambar $\rightarrow$ Keterangan Lokasi $\rightarrow$ Action Bar.
  - Mencegah tumpang tindih visual antara badge nomor utas (`1/2`) dan tag lokasi.

---

## 2. Rincian Perubahan di MarketPostCard.tsx
- **Varian Detail (Lines 495-515)**: Pindahkan blok `{item.locationTag && ...}` dari atas `renderImages(true)` menjadi tepat di bawah `renderImages(true)` sebelum `renderActionBar()`.
- **Varian Feed (Lines 615-638)**: Pindahkan blok `{item.locationTag && ...}` dari atas `renderImages(false)` menjadi tepat di bawah `renderImages(false)` sebelum `renderActionBar()`.
- **Styling**: Berikan margin `pt-1.5` atau `mt-1` yang rapi dan konsisten dengan padding feed.

---

## 3. Rencana Verifikasi
- `npx tsc --noEmit && npm run build` (0 TypeScript errors).
- Uji tampilan kartu di Home Feed dan Halaman Detail untuk memastikan badge lokasi tampil rapi di bawah gambar.
