# Rencana Implementasi: In-Page Discovery & Related Feed untuk Low Search Results

## 1. Ringkasan & Tujuan UX
- **Latar Belakang**: Saat pengguna mencari kata kunci spesifik (seperti *"web"*), jumlah postingan yang cocok sangat sedikit (misal: 1 postingan). Kondisi ini menyebabkan bagian bawah layar kosong melompong (*dead end*).
- **Tujuan UX**: Menjaga pengguna tetap berada di **Search Page** dengan menyajikan rekomendasi lanjutan (*in-page discovery*) yang relevan, chip pencarian terkait 1-tap, dan feed rekomendasi lanjutan yang dapat di-scroll tanpa batas.

---

## 2. Spesifikasi Desain & Tampilan UI Secara Detail

### A. Layout Struktur Halaman
```
┌──────────────────────────────────────────────────────────┐
│ [ ← ] [ 🔍 web                                   ✕ ]     │
├──────────────────────────────────────────────────────────┤
│  [ Terpopuler (Active) ]     [ Terbaru ]      [ Profil ] │
├──────────────────────────────────────────────────────────┤
│ ┌──────────────────────────────────────────────────────┐ │
│ │ [👤 Raymond Chin • 1j]                           ··· │ │
│ │ Ada kenalan website designer / UI engineer...?       │ │ <── Exact Matching Post (Hasil Utama)
│ │ [ ❤️ 466 ]  [ 💬 2 ]  [ 🔁 9 ]  [ ✈️ ]               │ │
│ └──────────────────────────────────────────────────────┘ │
├──────────────────────────────────────────────────────────┤
│ ✨ UTAS LAIN YANG MUNGKIN ANDA SUKA        Rekomendasi   │ <── Section Divider Elegan (44px)
├──────────────────────────────────────────────────────────┤
│ [ 🔍 #frontend ] [ 🔍 #coding ] [ 🔍 #desain ] [ 🔍 #dkv ]│ <── Horizontal Topic Refinement Chips
├──────────────────────────────────────────────────────────┤
│ ┌──────────────────────────────────────────────────────┐ │
│ │ [👤 Zura • 3j]                                   ··· │ │
│ │ Rekomendasi tools buat bikin landing page cepet...   │ │ <── Continuous Feed Rekomendasi
│ │ [ ❤️ 180 ]  [ 💬 14 ]  [ 🔁 5 ]  [ ✈️ ]              │ │     (Edge-to-edge divide-neutral-200)
│ └──────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
```

### B. Rincian Komponen UI:
1. **Section Divider (`InPageDiscoveryHeader`)**:
   - **Tinggi**: `44px`
   - **Styling**: `bg-neutral-50/90 backdrop-blur-xs border-y border-neutral-200/70 px-4 flex items-center justify-between`
   - **Ikon & Tipografi**:
     - Kiri: Ikon `<Sparkles className="w-3.5 h-3.5 text-[#1d64ec]" />` + teks `text-[12px] font-bold text-slate-700 uppercase tracking-wider` ("Utas Lain yang Mungkin Anda Suka").
     - Kanan: Badge `text-[11px] text-neutral-400 font-medium` ("Rekomendasi").
2. **Horizontal Query Refinement Chips (`TopicRefineBar`)**:
   - **Styling**: `flex items-center gap-2 overflow-x-auto no-scrollbar py-2.5 px-4 bg-white border-b border-neutral-100`
   - **Item Chip**:
     - Tombol pill kapsul: `px-3 py-1.5 rounded-full bg-neutral-100/90 hover:bg-neutral-200/80 active:scale-95 text-[12.5px] font-medium text-slate-800 transition-all cursor-pointer flex items-center gap-1.5`
     - Ikon: `<Search className="w-3 h-3 text-[#1d64ec]" />`
     - Aksi: Saat di-tap, langsung mengganti kata kunci pencarian seketika (*instant in-place search*) dan memberikan efek haptik ringan (`triggerHaptic('light')`).
3. **Continuous Feed Rekomendasi**:
   - Menggunakan `MarketPostCard` dengan styling *edge-to-edge* (`divide-y divide-neutral-200 pt-0`) identik dengan Home feed.

---

## 3. Logika & Algoritma Data (Data Flow)
- Pada `SearchPage.tsx`:
  - Hitung `recommendedPosts` menggunakan `useMemo`: memfilter seluruh postingan dari `MOCK_MARKET_POSTS` yang belum termasuk di dalam `scoredPosts`.
  - Jika `scoredPosts.length < 4`, tampilkan `InPageDiscoveryHeader` dan `TopicRefineBar` di bawah hasil utama, dilanjutkan dengan `recommendedPosts`.
  - Jika `scoredPosts.length >= 4`, hasil pencarian penuh tetap diprioritaskan.

---

## 4. Rencana Verifikasi
- `npx tsc --noEmit && npm run build` (0 TypeScript errors).
- Uji alur pencarian:
  1. Cari kata kunci spesifik (contoh: *"web"*).
  2. Pastikan 1 hasil pencarian utama tampil di atas.
  3. Pastikan di bawahnya langsung muncul divider rekomendasi, chips topik terkait, dan feed postingan lanjutan.
  4. Klik salah satu chip topik (misal: *#coding*) $\rightarrow$ Pastikan pencarian langsung berganti kata kunci secara instan di tempat.
