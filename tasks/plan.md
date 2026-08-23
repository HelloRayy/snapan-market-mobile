# Rencana Implementasi: Eliminasi Redundansi Input Bar Komentar (Pola Single Bottom Dock Sesuai Standar Threads & X)

## 1. Analisis Masalah (Root Cause)
- **Masalah Saat Ini**:
  - Saat tombol "Balas" ditekan pada komentar `lisayayaa_`, terjadi **duplikasi 2 input bar**:
    1. Input Bar Inline di dalam pohon komentar (`PostCommentItem.tsx`).
    2. Floating Capsule Input Bar di dasar layar (`PostDetailPage.tsx`).
  - Akibatnya, saat user mengetik di bilah bawah, bilah inline di atas tetap kosong. Tampilan menjadi tumpang tindih, boros ruang, dan membingungkan pengguna.
- **Standar UX Global (Threads, X, Instagram, TikTok)**:
  - **Hanya ada 1 (SATU) Input Bar di dasar layar**.
  - Saat klik "Balas", bilah melayang di bawah langsung aktif dengan chip `Membalas @username [Batal]`.
  - Tidak ada form input lokal di tengah-tengah daftar komentar.
  - Setelah tombol Kirim ditekan, komentar balasan langsung otomatis disisipkan di bawah komentar target dengan garis konektor utas.

---

## 2. Rincian Perubahan File
- **`src/ui/components/marketplace/PostCommentItem.tsx`**:
  - Hapus blok input inline `{isReplying && (<form ...>)}` di dalam `PostCommentItem.tsx`.
  - Hapus state lokal `replyDraftText`, `inputRef`, dan `handleInlineSubmit` yang tidak lagi diperlukan.
  - Cukup trigger `onReplyClick(username, commentId)` agar bilah Floating Capsule di dasar layar menangani pengetikan dan pengiriman secara terpusat.
- **`src/ui/pages/PostDetailPage.tsx`**:
  - Pastikan saat `handleReplyClick` dipanggil, bilah Floating Capsule di bawah langsung fokus (`autoFocus`) dengan target `replyToUser` dan `replyToCommentId`.
  - Saat dikirim via `handleAddComment(text, replyToCommentId)`, balasan langsung bersarang di bawah komentar target.

---

## 3. Rencana Verifikasi
- `npx tsc --noEmit && npm run build` (0 TypeScript errors).
- Uji alur membalas komentar:
  1. Klik "Balas" pada komentar siapapun.
  2. Pastikan hanya ada 1 bilah input yang aktif di bawah dengan chip `Membalas @username [Batal]`.
  3. Ketik dan kirim balasan.
  4. Pastikan balasan langsung muncul tersambung dengan garis utas di bawah komentar yang dibalas.
