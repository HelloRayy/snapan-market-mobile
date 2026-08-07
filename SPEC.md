# 📋 Feature Specification — Post Detail & Threads-Style Threaded Comments (`PostDetailPage.tsx`)

Dokumen spesifikasi ini mengatur arsitektur navigasi, struktur data, antarmuka UI/UX, dan balasan komentar bersarang (*threaded comments*) saat pengguna mengetuk kartu postingan dari Feed Utama.

---

## 🎯 1. Objective & Target User Experience

- **Tujuan**: Memberikan halaman detail postingan yang fokus (*focused post view*) lengkap dengan pohon komentar bersarang (*threaded comment tree*) bergaris penghubung vertikal (`|`), badge pembuat/penjual, dan kolom balasan cepat (*reply bar*) persis seperti **Threads by Instagram**.
- **Pemicu Navigasi**: Mengetuk area mana saja pada kartu postingan di `HomePage.tsx` (atau tombol "Lihat Detail") akan berpindah secara halus (*slide-left SPA transition*) ke `PostDetailPage.tsx`.
- **Header Navigation**: Header atas dengan tombol kembali `←`, judul "Postingan", dan tombol opsi `...`.

---

## 🏗️ 2. Architectural Design & Component Boundaries

### File Structure Changes:

- **[NEW] `src/ui/pages/PostDetailPage.tsx`**: Halaman utama detail postingan & daftar komentar thread.
- **[NEW] `src/ui/components/marketplace/ThreadCommentItem.tsx`**: Komponen balasan komentar individual dengan dukungan garis penghubung vertikal (`|`), avatar 36px, badge "Pembuat" / "Penjual", tombol Like & Balas.
- **[NEW] `src/ui/components/marketplace/CommentInputBar.tsx`**: Baris input balasan melayang di bagian bawah dengan avatar user & tombol "Kirim".
- **[MODIFY] `src/types/marketFeed.ts`**: Menambahkan interface `ThreadComment`.
- **[MODIFY] `src/data/mockMarketData.ts`**: Menambahkan mock data komentar bersarang per postingan.
- **[MODIFY] `src/App.tsx` / `HomePage.tsx`**: Menghubungkan state navigasi berpindah antara `HomePage` dan `PostDetailPage`.

---

## 🗄️ 3. Data Schema & Contracts (`ThreadComment` Interface)

```typescript
export interface ThreadComment {
  id: string;
  postId: string;
  user: {
    id: string;
    name: string;
    avatar: string;
    username: string;
    classGroup: string;
    isVerified?: boolean;
    isAuthor?: boolean; // Badge 'Pembuat' / 'Penjual'
  };
  content: string;
  timestamp: string;
  likesCount: number;
  isLiked?: boolean;
  replies?: ThreadComment[]; // Balasan bersarang (nested replies)
}
```

---

## 🎨 4. Design Guidelines (Kumo UI & Threads Compliance)

1. **Header Navigation**:
   - Left: `←` Back Button (`w-9 h-9 rounded-full hover:bg-neutral-100 flex items-center justify-center`).
   - Center: "Postingan" (`font-semibold text-base text-slate-900`).
2. **Main Post Display**:
   - Menampilkan `MarketPostCard` dalam posisi paling atas tanpa garis tepi bawah.
3. **Threaded Comment Tree**:
   - Garis Penghubung Vertikal: `w-[2px] bg-neutral-200 dark:bg-neutral-800` membentang dari avatar induk ke balasan di bawahnya.
   - Badge Pembuat: `px-2 py-0.5 rounded-full bg-neutral-100 text-[11px] text-slate-600 font-medium` ("Pembuat" / "Penjual").
   - Ikon Interaksi Komentar: `[❤️ Suka]` `[💬 Balas]` `[🔁 Repost]` `[✈️ Bagikan]`.
4. **Bottom Reply Input Bar**:
   - Sticky bottom bar: `fixed bottom-0 left-0 right-0 max-w-xl mx-auto bg-white/95 backdrop-blur-md border-t border-neutral-200 p-3 flex items-center gap-2.5 z-40`.
   - Input: `placeholder="Ketik balasan untuk Raymond..."` + Tombol "Kirim" Kumo `ButtonPrimary`.

---

## 🧪 5. Testing & Verification Plan

1. **Automated Verification**:
   - Run `npm run build` — Memastikan 0 error TypeScript dan kompilasi Vite 100% clean.
2. **Manual Navigation & Interaction Testing**:
   - Klik post di Feed ➔ Masuk `PostDetailPage` ➔ Klik `←` Kembali ke Feed.
   - Ketik komentar baru ➔ Tambah ke daftar komentar secara instan (*optimistic update*).
