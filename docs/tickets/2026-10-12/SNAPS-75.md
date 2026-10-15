# [SNAPS-75] hold(jualan-mode): for sprint beta release, kita hold fitur penjualan

> **Ticket Metadata**:
> - **Plane ID**: `ba738356-9f48-41da-a63b-f815277b3f5a`
> - **Sequence**: SNAPS-75
> - **Priority**: HIGH
> - **State Group**: unstarted (Ticket)
> - **Domain**: `scope / commerce / feed_cleanup`

---

## 1. Problem Statement & User Context
- **Deskripsi Masalah di Plane.so**:
  > *"Fitur jualan masi banyak mengalami bug dan integrasi yang lumayan rumit. kita juga harus ngejar beta version untuk release ke publik dan promosikan secara meluas. analsia semua fitur dan sistem yang terintegrasi dengan jualan ini untuk kita HOLD terlebih dahulu."*

- **Akar Masalah Teknis**:
  Aplikasi Snaps saat ini memiliki percabangan logika antara `postType == 'thread'` dan `postType == 'product'`:
  1. Halaman detail postingan memunculkan floating dock `StickyBuyBar` dan bottom sheet transaksi `BuyBottomSheet` ketika postingan bertipe produk atau memiliki atribut harga.
  2. Dialog pembuatan postingan (`CreatePostModal`) memiliki input harga, stok, dan tag kategori lapak yang memicu validasi inventaris.
  3. Modul checkout (`lib/features/checkout/`) dan integrasi order COD masih belum stabil dan rawan error database saat dicoba oleh banyak siswa secara serentak.
  4. Munculnya elemen marketplace yang setengah jadi membingungkan siswa baru yang tujuan utamanya adalah membaca dan merespons obrolan sekolah di linimasa.

---

## 2. Target File Scope (Interface-First Coupling)

| Peran File | Path File di Repositori | Keterangan Peran |
| :--- | :--- | :--- |
| **Post Detail Screen** | [`lib/features/feed/screens/post_detail_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/screens/post_detail_screen.dart) | Nonaktifkan render `StickyBuyBar` dan alur modal `BuyBottomSheet` |
| **Sticky Buy Bar** | [`lib/features/feed/components/sheets/sticky_buy_bar.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/sheets/sticky_buy_bar.dart) | Guardrail agar tidak ditampilkan selama mode hold aktif |
| **Create Post Modal** | [`lib/features/create_post/screens/create_post_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/create_post/screens/create_post_screen.dart) | Sembunyikan toggle posting barang dagangan / input harga jual |
| **Navigation Drawer** | [`lib/features/feed/components/navigation/home_nav_drawer.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/navigation/home_nav_drawer.dart) | Pastikan tidak ada tautan menu lapak / inventaris toko yang dangling |
| **App Configuration** | [`lib/core/constants/app_constants.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/constants/app_constants.dart) | Tambahkan feature flag global `enableMarketplaceTransactions = false` |

---

## 3. Step-by-Step Technical Approach

1. **Tambahkan Feature Flag Terpusat**:
   * Definisikan konstanta `static const bool isCommerceEnabled = false;` di `AppConstants` agar mudah diaktifkan kembali pasca-beta tanpa mengubah struktur database.
2. **Sembunyikan Elemen Transaksi di Post Detail**:
   * Di `PostDetailScreen`, bungkus `StickyBuyBar` dengan pengecekan `if (AppConstants.isCommerceEnabled && item.postType == 'product')`.
   * Ganti bottom bar postingan murni menjadi `CommentInputBar` standar Threads.
3. **Sederhanakan Modal Buat Postingan**:
   * Sembunyikan field input harga (`price`), harga coret (`originalPrice`), dan jumlah stok (`stock`).
   * Siswa tetap dapat mengunggah foto dan teks bebas, namun seluruh unggahan baru disimpan dengan `postType = 'thread'`.
4. **Isolasi Modul Checkout**:
   * Jangan menghapus folder `lib/features/checkout/`, biarkan tetap utuh sebagai aset masa depan, namun putus navigasi langsung menuju `CheckoutScreen`.

---

## 4. Questions for Reviewer (Harus Dijawab Reviewer)

> ❓ **Pertanyaan 1**: Untuk postingan lama yang sudah terlanjur memiliki atribut harga di database Supabase, apakah label harganya tetap ditampilkan sebagai teks informasi biasa di kartu feed, atau disembunyikan sepenuhnya dari pandangan user?
> ❓ **Pertanyaan 2**: Apakah tombol "Kirim Pesan (DM)" pada author kartu postingan tetap aktif sebagai saluran alternatif transaksi mandiri antar siswa?

---

## 5. Definition of Done (DoD)
- [ ] Tidak ada tombol "Beli Sekarang", "Beli", atau `StickyBuyBar` yang muncul di layar mana pun pada versi mobile.
- [ ] Modal pembuatan postingan hanya menerima teks, gambar, dan polling tanpa form isian harga atau stok dagangan.
- [ ] Alur navigasi tidak pernah masuk ke `CheckoutScreen`.
- [ ] Pengujian visual verifikasi feed berjalan 100% mulus sebagai media sosial murni.
