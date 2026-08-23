# Rencana Implementasi: Standarisasi Floating Capsule Pill untuk Seluruh Input Komentar (Mode Utas & Mode Jualan)

## 1. Pemahaman & Analisis Desain
- **Masalah Saat Ini**:
  - `StickyBuyBar` di Mode Jualan berbentuk **Floating Capsule Pill** (melayang, `rounded-full`, margin samping, shadow melayang).
  - Namun `CommentInputBar` sebelumnya masih berbentuk bar kotak nempel penuh (*full-width edge-to-edge*).
  - Ketika beralih dari tombol beli ke input komentar, terjadi inkonsistensi bentuk dari kapsul melayang tiba-tiba menjadi bar kotak kaku.
- **Solusi Desain (100% Konsistensi Geometri & Visual)**:
  - Ubah `CommentInputBar` (mode docked) agar **100% mengadopsi struktur Floating Capsule Pill** yang sama persis dengan `StickyBuyBar`.
  - **Spesifikasi Kapsul Melayang yang Seragam**:
    - Lebar & Posisi: `fixed left-4 right-4 max-w-md mx-auto`
    - Jarak Bawah: `bottom: max(1rem, calc(env(safe-area-inset-bottom, 0px) + 8px))`
    - Bentuk & Material: `rounded-full bg-white/95 backdrop-blur-xl border border-neutral-200/80 shadow-[0_12px_40px_rgba(0,0,0,0.12)] p-1.5`

---

## 2. Visual Layout 3 State Kapsul Melayang (100% Seragam)

### State 1: Mode Utas (Komentar Diskusi)
```
  ┌────────────────────────────────────────────────────────┐
  │ ( [👤 Avatar]  [ Balas @username... ]     [🚀 Kirim] ) │ <── Floating Capsule Pill
  └────────────────────────────────────────────────────────┘
```

### State 2: Mode Jualan (Mengetik Pertanyaan / Chat)
```
  ┌────────────────────────────────────────────────────────┐
  │ ( [👤 Avatar]  [ Tulis pertanyaan... ] [Batal] [🚀]  ) │ <── Floating Capsule Pill
  └────────────────────────────────────────────────────────┘
```

### State 3: Mode Jualan (Belanja / Standby)
```
  ┌────────────────────────────────────────────────────────┐
  │ ( [💬 Chat]    [ 💳 Beli Sekarang          Rp 150k ] ) │ <── Floating Capsule Pill
  └────────────────────────────────────────────────────────┘
```

---

## 3. Rincian Perubahan File
- **`src/ui/components/marketplace/CommentInputBar.tsx`**:
  - Ubah `containerClasses` dan pembungkus docked mode menjadi floating pill container yang identik dengan `StickyBuyBar`.
  - Tambahkan kapsul mini `Membalas @username [Batal]` yang melayang lembut di atas kapsul utama saat membalas komentar orang.
- **`src/ui/pages/PostDetailPage.tsx`**:
  - Pastikan padding bawah `pb-32` pada halaman agar komentar terakhir tidak tertutup oleh kapsul melayang.

---

## 4. Rencana Verifikasi
- `npx tsc --noEmit && npm run build` (0 TypeScript errors).
- Uji Mode Utas: Pastikan input bar tampil sebagai kapsul melayang dengan sudut membulat sempurna dan glassmorphism.
- Uji Mode Jualan: Pastikan saat klik `[💬]`, kapsul melayang berganti menjadi kapsul input komentar dengan animasi yang sangat konsisten.
