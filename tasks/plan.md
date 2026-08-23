# Rencana Implementasi: Perbaikan Layout Balasan Komentar & Standarisasi Motion Action Bar

## 1. Analisis Masalah
1. **Overflow / Overlapping Tepi Kanan pada Komentar Balasan (Child Replies)**:
   - Pada baris `398` di `PostCommentItem.tsx`, container child reply menggunakan kombinasi `ml-7` dan `w-full`.
   - Di CSS, `w-full + ml-7` menyebabkan elemen meluber keluar layar ke kanan sebesar 28px (`1.75rem`), sehingga tombol opsi `···` dan teks balasan terpotong / menempel di tepi kanan layar.
   - **Solusi**: Hapus `w-full` dan gunakan `ml-7 min-w-0 relative flex-1` agar lebar child reply pas dan menyisakan margin 14px di kanan.

2. **Penyelarasan Motion Action Bar (Love, Comment, Repost, Share) di Komentar**:
   - Saat ini di `PostCommentItem.tsx`, tombol Love masih menggunakan kotak pill hitam lama (`border-slate-900 bg-neutral-100/90`).
   - **Solusi**: Terapkan **Pure Icon Motion (tanpa border & tanpa background kotak)** yang identik dengan `MarketPostCard` di Home Feed pada `PostCommentItem.tsx` dan `CommentDetailPage.tsx`.

---

## 2. Rincian Perubahan File
- **`src/ui/components/marketplace/PostCommentItem.tsx`**:
  - Perbaiki child reply wrapper dari `w-full ml-7` menjadi `ml-7 min-w-0 relative` agar tidak tembus ke tepi kanan.
  - Perbarui `renderActionBar` untuk menggunakan animasi pegas murni:
    - Love: `scale: [1, 1.45, 0.88, 1.15, 1], rotate: [0, -10, 10, -4, 0]`, ruby crimson fill `fill-rose-500 text-rose-500`.
    - Comment: `scale: [1, 0.85, 1.2, 0.95, 1], y: [0, -2, 0]`.
    - Repost: `Repeat2`, `rotate: [0, 180], scale: [1, 1.3, 0.9, 1.05, 1]`, emerald green `text-emerald-500`.
    - Share: `x: [0, 4, -1, 0], y: [0, -4, 1, 0], scale: [1, 1.2, 1]`.
- **`src/ui/components/marketplace/CommentDetailPage.tsx`**:
  - Selaraskan hero comment action bar dengan pure icon motion yang sama.

---

## 3. Rencana Verifikasi
- `npx tsc --noEmit && npm run build` (0 TypeScript errors).
- Uji tampilan komentar balasan (Child Replies): Pastikan tepi kanan komentar balasan memiliki margin yang rapi dan sejajar dengan tepi parent.
- Uji interaksi tombol love, comment, repost, share di komentar: Pastikan animasi icon bergerak mulus tanpa kotak pill hitam.
