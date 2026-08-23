# Rencana Implementasi: Morphing Floating Bar di Mode Jualan (StickyBuyBar ↔ Docked Comment Input)

## 1. Analisis & Konsep UX (Morphing Interaction)
- **Kondisi Sekarang**: Klik `[ 💬 ]` membuka popup modal `AskSellerBottomSheet` yang menutupi layar.
- **Keinginan User**: Jangan gunakan popup/modal. Ubah langsung bilah melayang di bawah menjadi bar input komentar/chat biasa (sama persis seperti di Mode Utas).
- **Alur Interaksi (State Switching Flow)**:
  1. **Mode Belanja (Default)**: Tampil kapsul melayang `[ 💬 ] [ 💳 Beli Sekarang Rp 150.000 ]`.
  2. **Mode Mengetik (Active Commenting)**: Saat `[ 💬 ]` diklik (atau klik "Balas" di komentar tertentu), dock berganti mulus menjadi bar input:
     `[Avatar] [ Balas postingan @penjual... ] [ Kirim 🚀 ] [ ✕ Batal ]`
     dengan keyboard langsung fokus.
  3. **Kembali ke Mode Belanja**: Saat komentar dikirim atau tombol Batal ditekan, bar kembali mulus ke `StickyBuyBar`.

---

## 2. Keuntungan UX
- **Tanpa Distraksi Modal**: Pengguna tetap bisa melihat feed komentar di atas saat mengetik.
- **Konsistensi Visual 100%**: Desain kolom chat di Mode Jualan dan Mode Utas menjadi seragam dan familiar.
- **Transisi Halus**: Memberikan pengalaman interaksi yang fluid dan hemat ruang.

---

## 3. Rincian Perubahan File
- **`PostDetailPage.tsx`**:
  - Tambahkan state `isCommentingActive` (boolean).
  - Saat `onChatClick` ditekan $\rightarrow$ `setIsCommentingActive(true)`.
  - Saat `handleReplyClick` pada komentar ditekan $\rightarrow$ `setIsCommentingActive(true)` + set target reply.
  - Render kondisional: Jika `isCommentingActive`, tampilkan `CommentInputBar` dengan tombol Batal; jika tidak, tampilkan `StickyBuyBar`.
- **`CommentInputBar.tsx`**:
  - Dukung tombol Batal/Tutup saat dalam mode jualan agar user bisa kembali ke tampilan tombol `Beli Sekarang`.

---

## 4. Rencana Verifikasi
- `npx tsc --noEmit && npm run build` (0 TypeScript errors).
- Uji klik tombol `[ 💬 ]` di Mode Jualan: Pastikan dock berubah menjadi bar input komentar dan keyboard langsung fokus.
- Uji submit & batal: Pastikan dock kembali ke `[ 💬 ] [ 💳 Beli Sekarang ]`.
