# Rencana Implementasi: Perbaikan Spacing & Desain Komentar Sesuai Standar Threads

## 1. Analisis Perbedaan UI/UX
- **Masalah Gap Jelek**:
  - Di `PostCommentItem.tsx`, container kanan menggunakan `space-y-1` dan teks komentar menggunakan `pt-0.5`.
  - Kombinasi ini menghasilkan jarak vertikal ~6px–8px yang terlalu renggang antara baris nama akun dan isi komentar.
- **Standar Threads (Dari Kode Referensi)**:
  - Header akun memiliki line-height presisi: `h-[21px] leading-snug flex items-center`.
  - Teks komentar langsung menempel rapat di bawahnya dengan margin mikro: `mt-0.5` (2px) dan `leading-snug`.
  - Action bar (Like, Reply, Repost, Share) menggunakan `pt-1` tanpa border/background kaku.

---

## 2. Rincian Perubahan di `PostCommentItem.tsx`
1. **Header Row**: Jadikan `h-[21px] leading-snug flex items-center justify-between`.
2. **Comment Content Text**: Hapus `pt-0.5` dan `space-y-1`, gunakan `mt-0.5 leading-snug text-[15px] sm:text-[15.5px]`.
3. **Action Bar**:
   - Hapus border dan background klik (`border border-slate-900 bg-neutral-100/90`).
   - Terapkan animasi pegas Framer Motion murni pada ikon (Heart pop, Comment bounce, Repost spin, Share glide).
4. **Terapkan pada Semua Varian**:
   - Single comment item
   - Parent comment dengan thread branch
   - Nested child replies

---

## 3. Rencana Verifikasi
- `npx tsc --noEmit && npm run build` (0 TypeScript errors).
- Uji tampilan komentar: Pastikan gap antara username dan teks komentar menjadi rapat, rapi, dan identik dengan Threads.
