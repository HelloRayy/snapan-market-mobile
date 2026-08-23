# Rencana Implementasi: Standarisasi Padding Edge-to-Edge pada Comment Section Sesuai Home Feed

## 1. Analisis & Masalah
- **Masalah Saat Ini**:
  - Di `PostDetailPage.tsx`, seluruh `<section id="comments-section">` dibungkus dengan `px-4`.
  - Hal ini menyebabkan container komentar **mengecil / menyusut ke dalam (*inset*)**, garis pemisah (*border-b*) terpotong tidak menyentuh ujung layar, dan avatar komentar tidak lurus dengan avatar postingan di atasnya.
- **Standar Home Feed (Desain yang Benar & Konsisten)**:
  - Setiap postingan di Home Feed menggunakan `w-full border-b border-neutral-200 px-3.5 py-3`.
  - Garis pemisah menyentuh ujung tepi layar (*edge-to-edge*).
  - Avatar berada tepat pada jarak `14px` (`px-3.5`) dari tepi kiri.

---

## 2. Solusi Desain
1. **Di `PostDetailPage.tsx`**:
   - Ubah `<section id="comments-section" className="px-4 pt-2">` menjadi `<section id="comments-section" className="w-full pt-2">`.
   - Berikan `px-3.5 py-2.5` pada header `Komentar (3) | Urutkan dari Terbaru`.
   - Hapus `divide-y divide-neutral-200` pada list container karena setiap `PostCommentItem` sudah memiliki `border-b border-neutral-200` sendiri.
2. **Di `PostCommentItem.tsx`**:
   - Standarkan padding outer item menjadi `px-3.5 py-3 border-b border-neutral-200` (sama persis dengan `MarketPostCard`).
   - Hapus offset `-mx-2 px-2` yang mengacaukan keselarasan tepi.

---

## 3. Rencana Verifikasi
- `npx tsc --noEmit && npm run build` (0 TypeScript errors).
- Uji tampilan Detail Post: Garis pemisah komentar dan posisi avatar sekarang 100% lurus presisi dengan postingan utama di atasnya dan identik dengan Home Feed.
