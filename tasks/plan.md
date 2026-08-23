# Implementation Plan: Fix MediaLightboxModal Fullscreen Viewport Stacking Bug

## 1. Overview & Root Cause Analysis
- **Akar Masalah**: Komponen `MediaLightboxModal.tsx` di-render langsung di dalam tag `<article className="feed-card-perf overflow-x-hidden">` milik `MarketPostCard.tsx` tanpa menggunakan **React Portal** (`createPortal(..., document.body)`).
- **Dampak**: Properti CSS `position: fixed inset-0` terperangkap di dalam *containing block* kartu feed lokal, sehingga modal tidak dapat menutupi Header Atas (`Snapan Market`), Tab Bar (`Untuk Anda`), dan Bottom Navigation Bar (`MarketBottomNav`).
- **Solusi**: Bungkus `MediaLightboxModal` menggunakan `createPortal(..., document.body)` dan berikan dimensi eksplisit `w-screen h-[100dvh] fixed inset-0 z-[99999] bg-white` agar me-mount langsung ke level `document.body` dan menutupi 100% seluruh layar secara mutlak.

---

## 2. Task List

### Phase 1: React Portal & Fullscreen Viewport Fix
- [ ] Task 1: Impor `createPortal` dari `react-dom` di `MediaLightboxModal.tsx` dan portal modal ke `document.body`.
- [ ] Task 2: Tambahkan `w-screen h-[100dvh]` serta isolasi z-index `z-[99999]` agar menutupi seluruh viewport dari ujung atas (0px) hingga ujung bawah (100dvh).

### Phase 2: Verifikasi & Build
- [ ] Task 3: Jalankan `npx tsc --noEmit && npm run build` untuk memastikan 0 error.
- [ ] Task 4: Git commit & push ke main.
