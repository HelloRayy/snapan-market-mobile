# [SNAPS-79] fix(image-ratio): issue image di feed page ketika di upload tidak sesuai dengna ratio yang ada..

> **Ticket Metadata**:
> - **Plane ID**: `9f2da4a8-b1f9-42f7-8a40-73ea279e88cf`
> - **Sequence**: SNAPS-79
> - **Priority**: HIGH
> - **State Group**: in_progress (Implementation Completed)
> - **Domain**: `feed / post_media / aspect_ratio`

---

## 1. Problem Statement & User Context

- **Deskripsi Masalah di Plane.so**:
  > *"Image media ketika udah di post, dan muncul di feed home page ini ≠ tidak sesuai dengan ratio ketika mengambil foto tersebut. biasanya ini terjadi dan mentrigger ketika user mengupload > 2 photo.
  > example: photo 1 = 16:9, photo 2 = 4:3 maka kedua foto tersbeut nanti akan memaksa untuk ngikut dari sallah satu ratio tersebut. hal ini meyebabkan ui jelek karna foto yang seharusnya bisatampil 16:9 malah menjadi ratio di photo lainnya"*

- **Keputusan Desain & Konsensus Reviewer**:
  - Mengadopsi arsitektur **WYSIWYG Parity**: Preview saat memilih/menambahkan foto di form pembuatan postingan (`CreatePostImagesPreview`) memiliki rasio dan tampilan yang **100% persis** dengan kartu carousel di feed postingan (`PostMediaSection`).
  - Menerapkan **Variable-Width Adaptive Carousel**: Setiap kartu menghitung lebarnya secara mandiri berdasarkan rasio natural aslinya (`height * naturalRatio`) sehingga foto berasio 9:16 tetap langsing vertikal, dan foto 16:9 tetap melebar horizontal tanpa ada pemotongan paksa (*zero-cropping*).

---

## 2. Target File Scope (Interface-First Coupling)

| Peran File | Path File di Repositori | Keterangan Perubahan |
| :--- | :--- | :--- |
| **Adaptive Carousel Card (Baru)** | [`lib/features/feed/components/post_card/adaptive_carousel_card.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_card/adaptive_carousel_card.dart) | Komponen penghitung aspect ratio otomatis dengan caching memori in-flight dan opsi `customWidth` |
| **Post Media Section** | [`lib/features/feed/components/post_card/post_media_section.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_card/post_media_section.dart) | Layout dinamis: 50%-50% grid saat 2 foto portrait muat penuh, dan horizontal adaptive carousel saat 3+ foto / beda rasio |
| **Create Post Media Preview** | [`lib/features/create_post/components/create_post_media_preview.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/create_post/components/create_post_media_preview.dart) | Menggunakan `AdaptiveCarouselCard` berstandar sama sehingga preview input persis dengan hasil post |

---

## 3. Implementasi Dual Layout: Dynamic Grid (2 Foto) & Adaptive Carousel (3+ Foto)
- **Tepat 2 Foto (Pola Dynamic Grid 50% - 50%)**:
  - Diterapkan pada [`post_media_section.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_card/post_media_section.dart).
  - Ketika postingan memiliki 2 gambar (misal 2 portrait 9:16 seperti pada *Image 1*), tata letak otomatis beralih menjadi `Row` dengan 2 kartu `Expanded(child: ...)` berjarak `8.0` dp.
  - Setiap kartu mengisi tepat 50% lebar kolom kartu, **menghilangkan ruang kosong/void putih di sisi kanan secara sempurna**.
- **Foto Berbeda Rasio / 3+ Foto (Pola Adaptive Carousel)**:
  - Foto tetap mempertahankan rasio naturalnya (seperti pada *Image 3*: satu portrait 9:16 dan satu landscape 16:9), bergulir mulus tanpa terpotong (*zero cropping*).

---

## 4. DoD (Definition of Done) Verification
- [x] Mendukung rasio beragam (1:1, 4:3, 16:9, 9:16) secara proporsional.
- [x] Jika ada 2 foto portrait (9:16), mengisi penuh lebar kartu (50% - 50%) tanpa void kosong di sisi kanan.
- [x] Tidak ada *Cumulative Layout Shift (CLS)* karena tinggi kartu terkontrol (`230.0` dp feed / `250.0` dp detail / `220.0` dp preview).
- [x] Zero unhandled exceptions atau rendering overflow (`LayoutBuilder` + `Expanded`).
- [x] Scrolling horizontal carousel tetap mulus dengan scrolling physics bouncing.
- [x] Kompatibel dengan fitur *double-tap to like* dan tap to open lightbox.
- [x] `flutter analyze` 0 issues.
- [x] Suite test `test/feed_optimization_test.dart` lulus 100%.

---

## 3. Step-by-Step Technical Approach

### Langkah 1: Evaluasi & Pemilihan Pola Desain Aspect Ratio Multi-Foto
Ada 2 pola standar industri untuk menangani multi-foto dengan rasio bervariasi:

- **Pola A (Dominant Leading Aspect Ratio - Standar Instagram & Threads)**:
  * Tinggi seluruh carousel ditentukan oleh rasio foto pertama (`images[0]`), dengan batas batas aman (`clamped` antara `4:5` / `0.8` minimum hingga `16:9` / `1.78` maksimum).
  * Foto kedua dan seterusnya menggunakan `BoxFit.contain` dengan background subtle blur/letterbox atau `BoxFit.cover` terpusat.
  * **Kelebihan**: Scroll horizontal sangat mulus, tinggi kartu stabil dan konsisten sepanjang feed.

- **Pola B (Fixed Container Height dengan Variable Card Width - Standar Galeri Komparasi)**:
  * Tinggi carousel diset konstan (misal `300.0` dp di feed), dan setiap kartu memiliki lebar dinamis:  
    `cardWidth = 300.0 * imageAspectRatio`.
  * Foto 16:9 akan tampil melebar, foto 4:3 tampil proporsional, dan foto 1:1 tampil bujur sangkar.
  * Gambar tidak terpotong sama sekali (`zero cropping`).
  * **Kelebihan**: 100% menghormati rasio setiap foto tanpa ada pemotongan.

- **Pola C (Dual Aspect Ratio Card Container)**:
  * Menggunakan `AspectRatio` container yang ditentukan oleh mayoritas orientasi (Landscape vs Portrait). Jika gambar pertama adalah potret, seluruh kartu carousel menggunakan rasio potret (`4:5`), bukan 16:9.

### Langkah 2: Implementasi Caching Aspek Rasio (Optimasi Render)
- Saat mengunduh gambar melalui URL Supabase, simpan aspect ratio yang telah dihitung ke dalam cache memori ringan (`Map<String, double> _aspectRatioCache`) di `DynamicFeedImage` agar saat user scrolling ke atas dan ke bawah tidak terjadi layout jumping / re-layout overhead.

### Langkah 3: Update `PostMediaSection`
- Ubah baris hardcoded `cardHeight = cardWidth * (9 / 16)` menjadi dinamis berdasarkan opsi yang disepakati (misal: adaptif mengikuti rasio terdeteksi atau batas clamp 1:1 / 4:5 saat foto berorientasi tegak).

---

## 4. Questions for Reviewer (Harus Dijawab Reviewer)

> ❓ **Pertanyaan 1**: Untuk multi-image carousel (2+ foto dengan rasio berbeda), pendekatan mana yang paling diinginkan untuk Snaps Mobile?
> - **Opsi 1 (Rekomendasi - Leading Aspect Ratio ala Threads/IG)**: Tinggi carousel mengikuti rasio foto pertama (antara 4:5 hingga 16:9), foto lainnya menyesuaikan dengan fit yang rapi.
> - **Opsi 2 (Variable Width ala Pinterest/Galeri Horizontal)**: Tinggi container tetap (~280-320 dp), namun lebar tiap foto menyesuaikan rasio aslinya (16:9 lebar, 1:1 kotak, 3:4 ramping tanpa terpotong sama sekali).
> - **Opsi 3 (Adaptive Multi-Grid ala Twitter/X)**: 2 foto dibagi 50:50, 3 foto dibagi 1 besar + 2 kecil, 4 foto grid 2x2.

> ❓ **Pertanyaan 2**: Apakah rasio vertikal ekstrem (seperti screenshot dokumen 9:16) harus di-clamp maksimal di 4:5 agar tidak memakan seluruh layar beranda siswa saat scrolling?

---

## 5. Definition of Done (DoD)
- [ ] Multi-image post tidak lagi memaksa rasio 16:9 jika gambar yang diunggah berbentuk potret (3:4, 4:5) atau bujur sangkar (1:1).
- [ ] Foto potret tidak terpotong bagian atas dan bawahnya secara agresif.
- [ ] Scrolling horizontal carousel tetap mulus tanpa layout shift / stutter (60 FPS).
- [ ] Kompatibel dengan fitur *double-tap to like* dan tap to open lightbox.
- [ ] Lulus pengujian `flutter test` dan `flutter analyze` dengan 0 error.
