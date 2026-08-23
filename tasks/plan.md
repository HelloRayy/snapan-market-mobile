# Rencana Implementasi: Redesign Arsitektur Input Komentar & CTA Bottom Dock (Mode Jualan vs Mode Utas)

## 1. Ringkasan & Arsitektur UX Baru
Memisahkan sistem interaksi di halaman detail postingan (`PostDetailPage.tsx`) menjadi dua mode yang bersih dan terisolasi tanpa tumpang tindih:

### 🛍️ A. Mode Jualan (Product Post) — *Unified Action Dock*
- **Di Halaman Konten**: Hapus input komentar statis di atas daftar komentar.
- **Di Dasar Layar**: Tampilkan `StickyBuyBar` melayang yang ringkas:
  - Tombol Kiri: `[ 💬 Tanya ]` $\rightarrow$ Membuka **Sheet Tanya Cepat / Komentar Produk**.
  - Tombol Kanan: `[ 💳 Beli Sekarang  Rp 150.000 ]` $\rightarrow$ Membuka `BuyBottomSheet`.

### 🧵 B. Mode Utas (Thread Post) — *Docked Bottom Bar ala Threads / X*
- **Di Halaman Konten**: Hapus input komentar statis di dalam feed agar membaca utas terasa leluasa.
- **Di Dasar Layar**: Pasang `CommentInputBar` yang *docked* melayang di dasar layar (`[Avatar] [Balas @username...] [Kirim]`) dengan integrasi Safe Area HP (`env(safe-area-inset-bottom)`).

---

## 2. Rincian Perubahan File

### 1. `src/ui/pages/PostDetailPage.tsx`
- Hapus `CommentInputBar isInline={true}` dari dalam section `#comments-section`.
- Tambahkan state `isAskQuestionOpen` untuk mengontrol sheet tanya penjual.
- Render kondisional di dasar layar:
  - Jika `post.postType === 'product'`: Render `StickyBuyBar` + `BuyBottomSheet` + `AskSellerBottomSheet`.
  - Jika `post.postType === 'thread'`: Render docked `CommentInputBar` di dasar layar dengan `pb-28`.

### 2. `src/ui/components/marketplace/CommentInputBar.tsx`
- Sempurnakan tampilan docked mode dengan glass blur `bg-white/95 backdrop-blur-md`, border halus, dan safe area bottom inset.

---

## 3. Rencana Verifikasi
- `npx tsc --noEmit && npm run build` (0 TypeScript errors).
- Uji Mode Jualan: Pastikan halaman bebas dari input statis ganda, tombol `💬 Tanya` membuka sheet pertanyaan, dan tombol `💳 Beli Sekarang` membuka sheet checkout.
- Uji Mode Utas: Pastikan input bar menempel rapi di bawah ala Threads/X dan daftar komentar dapat di-scroll penuh tanpa tertutup dock.
