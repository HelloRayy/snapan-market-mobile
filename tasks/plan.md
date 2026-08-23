# Rencana Implementasi: Redesign Smooth Micro-Interactions Action Bar (Like, Comment, Repost, Share)

## 1. Ringkasan & Tujuan
Mengimplementasikan animasi mikro (*micro-interactions*) dan fisika sentuhan halus setara aplikasi kompetitor (Meta Threads, Instagram, Twitter/X) saat tombol aksi (Love, Comment, Repost, Share) ditekan atau dalam status aktif.

---

## 2. Rincian Desain Gerak (*Motion Design System*)

### A. ❤️ Love / Like (Elastic Heart Burst)
- **Animasi Ikon**: `scale: [1, 1.45, 0.88, 1.15, 1]`, `rotate: [0, -12, 12, -4, 0]` dengan spring physics (`stiffness: 500, damping: 15`).
- **Efek Aura**: Gelombang radial halus (*halo ripple*) yang membesar dan menghilang di balik ikon.
- **Transisi Angka Counter**: Animasi naik vertikal (`y: [-6, 0]`, `opacity: [0, 1]`) saat angka bertambah/berkurang.
- **Warna & Latar**: Warna crimson rose pekat `text-rose-500 fill-rose-500` tanpa border kotak kaku.

### B. 💬 Comment / Reply (Squish & Bounce)
- **Animasi Ikon**: Kompresi pegas elastis `scale: [1, 0.85, 1.2, 0.95, 1]` dan geseran mikro `y: [0, -2, 0]`.
- **Feedback Sentuhan**: Aura lingkaran lembut dengan `bg-sky-50 text-sky-600`.

### C. 🔁 Repost / Retweet (180° Elastic Spin)
- **Animasi Ikon**: Putaran 180 derajat elastis `rotate: [0, 180]`, `scale: [1, 1.3, 0.9, 1.05, 1]`.
- **Warna & Latar**: Warna hijau zamrud `text-emerald-500 bg-emerald-50`.

### D. ✈️ Share / Send (Paper Plane Flight)
- **Animasi Ikon**: Efek meluncur serong `x: [0, 4, -1, 0]`, `y: [0, -4, 1, 0]`, `scale: [1, 1.2, 1]`.
- **Feedback Sentuhan**: Background pill lembut `bg-neutral-100`.

---

## 3. Daftar File yang Diubah
- `src/ui/components/marketplace/MediaLightboxModal.tsx`
- `src/ui/components/marketplace/MarketPostCard.tsx`
- `src/ui/components/marketplace/ReplyThreadCard.tsx`

---

## 4. Rencana Verifikasi
- `npx tsc --noEmit && npm run build` (0 TypeScript errors).
- Uji klik tombol aksi di feed dan di dalam Lightbox Modal untuk memastikan animasi berjalan 60-120 FPS tanpa lag.
