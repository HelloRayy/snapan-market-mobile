# Rencana Implementasi: Standarisasi Tampilan Feed Hasil Pencarian (Search Feed vs Homepage Feed)

## 1. Analisis Masalah
- **Perbedaan Feed Pencarian vs Homepage Feed**:
  - Pada `HomePage.tsx`, container feed menggunakan `<main className="max-w-xl mx-auto divide-y divide-neutral-200 pt-0">` tanpa horizontal padding (`px-0`), sehingga setiap kartu `MarketPostCard` tampil *edge-to-edge* (rapat ke tepi layar) dengan garis pemisah `border-b border-neutral-200` dan padding internal kartu `px-3.5`.
  - Pada `SearchPage.tsx`, container feed dibungkus oleh `<main className="max-w-xl mx-auto px-4 pt-3 space-y-4">` dan `<div className="space-y-3">`. Akibatnya, kartu postingan di tab **Terpopuler** dan **Terbaru** menyempit karena terkena padding `px-4`, serta memiliki celah vertikal antar-kartu yang tidak konsisten dengan Home feed (seperti yang terlihat pada screenshot user).

---

## 2. Rincian Perubahan File
- **`src/ui/pages/SearchPage.tsx`**:
  - Untuk tab **Terpopuler** (`top`) dan **Terbaru** (`latest`): Gunakan layout *edge-to-edge* dengan `divide-y divide-neutral-200 pt-0 -mx-4` (atau `px-0` pada container feed) agar kartu postingan tampil 100% identik dengan `HomePage.tsx`.
  - Pertahankan padding `px-4` hanya pada tahap saran akun / trending tags dan tab **Profil** yang membutuhkan card rounded.
  - Selaraskan styling header tab (Terpopuler, Terbaru, Profil) dengan border pemisah bawah yang rapi dan konsisten dengan tab Home.

---

## 3. Rencana Verifikasi
- `npx tsc --noEmit && npm run build` (0 TypeScript errors).
- Uji Halaman Pencarian:
  1. Buka tab Search, ketik kata kunci (misal: "website") dan tekan Enter / klik Lanjutkan.
  2. Buka tab **Terpopuler** & **Terbaru**: Pastikan kartu postingan tampil *edge-to-edge* dengan pemisah garis neutral-200, 100% konsisten dengan Home feed.
  3. Buka tab **Profil**: Pastikan daftar akun tetap berjarak rapi dan fungsional.
