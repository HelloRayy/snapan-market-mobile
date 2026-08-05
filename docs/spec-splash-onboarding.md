# Spec: Splash Screen & Onboarding UI (Mobile First & Black/White Theme)

## Objective
Mengimplementasikan tampilan awal aplikasi yaitu **Splash Screen** dan **Onboarding Screens (3 Slide)** pada **Laptop A (Frontend)** berdasarkan referensi gambar desain yang diberikan.

## Visual & Design System
- **Theme**: Monokrom (Pure Black `#000000`, Dark Gray `#18181b`, White `#ffffff`, Muted Gray `#a1a1aa`).
- **Layouting**: Mobile First (Dioptimalkan untuk tampilan layar smartphone).
- **Interactive Flow**: Splash Screen (2.5 detik atau tap) -> Onboarding Slide 1 -> Slide 2 -> Slide 3 -> Home App.

## Component Layout Breakdown

1. **Slide 1 Visual**:
   - Hero card berlatar hitam/zinc dengan aksen badge ribbon melayang.
   - Headline: *"Temukan Produk Pilihan untuk Kebutuhan Harianmu"*

2. **Slide 2 Visual**:
   - Photo card tengah dengan elemen melayang ikon sosial media (Pinterest, Facebook, Instagram, X, Threads) & hashtag chips.
   - Kotak ulasan/caption melayang.
   - Headline: *"Interaksi Langsung & Ulasan Real-Time dari Pembeli"*

3. **Slide 3 Visual**:
   - Grid 2x2 promo cards (Black Friday Sale, Tech Giveaway, Beauty Product Sales, Super Offer).
   - Headline: *"Banjir Promo E-Commerce & Flash Sale Setiap Hari"*

4. **Bottom Bar Controls**:
   - Dot indicator (3 item, 1 aktif memanjang).
   - Tombol `Skip` (Kiri).
   - Tombol `Next ›` / `"Mulai Sekarang"` (Kanan).
