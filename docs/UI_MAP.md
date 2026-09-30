# Snapan Market Mobile — UI Screen & Component Map

Dokumen ini adalah peta navigasi visual bagi AI Agent dan Developer untuk mengidentifikasi file kode sumber Flutter secara instan hanya dari tangkapan layar (screenshot) atau teks UI, **tanpa perlu membaca ratusan baris kode yang tidak relevan**.

---

## Aturan Pencarian Cepat (Screenshot-to-Code SOP)

1. **Baca Teks Visual**: Cari kata unik dalam bahasa Indonesia yang terlihat di screenshot (contoh: *"Cari di SMKN 8"*, *"Ajukan COD"*, *"Edit Profil"*).
2. **Jalankan Ripgrep/Git Grep**:
   ```bash
   git grep -i "teks_di_screenshot" lib/
   ```
3. **Buka Komponen Spesifik**: Langsung buka file komponen terkait (maksimal 250 baris), **JANGAN** membaca seluruh file screen induk jika hanya ingin mengubah sub-widget.

---

## Katalog Layar, Rute & Komponen Visual

### 1. Home Feed (Beranda & Timeline)
- **File Induk**: [`lib/features/feed/screens/home_feed_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/screens/home_feed_screen.dart) (<= 300 baris)
- **Controller**: [`lib/features/feed/controllers/home_feed_controller.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/controllers/home_feed_controller.dart)
- **Visual Clues**: Header logo Snaps di kiri atas, drawer icon di kiri, menu popover di kanan atas, filter tab (*Semua, PPLG, DKV, Kuliner*), scrollable feed list, floating action buttons.
- **Komponen Pendukung**:
  - Header & Top Bar: [`lib/features/feed/components/home_feed_header.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/home_feed_header.dart)
  - Navigation Drawer (Kiri): [`lib/features/feed/components/home_nav_drawer.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/home_nav_drawer.dart)
  - Tab Switcher Navigasi: [`lib/features/feed/components/home_nav_tab_switcher.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/home_nav_tab_switcher.dart)
  - List View Feed: [`lib/features/feed/components/home_feed_scrollable_list.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/home_feed_scrollable_list.dart)
  - Floating Action Buttons (+ / Marketplace): [`lib/features/feed/components/home_feed_fab_group.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/home_feed_fab_group.dart)
  - Kartu Postingan/Market: [`lib/features/feed/components/market_post_card.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/market_post_card.dart)
  - Rantai Thread (Part 1/2): [`lib/features/feed/components/post_card/post_thread_chain_section.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_card/post_thread_chain_section.dart)
  - Konten & Media Post: [`lib/features/feed/components/post_card/post_card_content_column.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_card/post_card_content_column.dart)

### 2. Detail Postingan & Komentar (Post Detail Screen)
- **File Induk**: [`lib/features/feed/screens/post_detail_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/screens/post_detail_screen.dart) (<= 250 baris)
- **Controller**: [`lib/features/feed/controllers/post_detail_controller.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/controllers/post_detail_controller.dart)
- **Visual Clues**: App bar dengan tombol kembali, post fokus di atas, pembatas hitungan komentar & dropdown pengurutan (*Terbaru, Teratas, Terlama*), daftar komentar bertingkat, bottom buy / comment bar.
- **Komponen Pendukung**:
  - Header & Sort Dropdown Komentar: [`lib/features/feed/components/post_detail_comments_header.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_detail_comments_header.dart)
  - Daftar Komentar & Thread: [`lib/features/feed/components/post_detail_comments_list.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_detail_comments_list.dart)
  - Item Komentar & Balasan: [`lib/features/feed/components/post_comment_item.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_comment_item.dart)
  - Bottom Bar (Beli COD / Kirim Komentar): [`lib/features/feed/components/post_detail_bottom_bar.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_detail_bottom_bar.dart)
  - Empty State Komentar: [`lib/features/feed/components/post_detail_empty_comments.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_detail_empty_comments.dart)

### 3. Autentikasi (Masuk & Daftar Akun)
- **File Induk**: [`lib/features/auth/screens/auth_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/auth/screens/auth_screen.dart) (<= 300 baris)
- **Controller**: [`lib/features/auth/controllers/auth_controller.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/auth/controllers/auth_controller.dart)
- **Visual Clues**: Logo Snaps biru, judul *"Masuk ke Akun"* / *"Daftar Akun Siswa"*, input field, pilihan kelas & jurusan, tombol aksi utama.
- **Komponen Pendukung**:
  - Brand Header: [`lib/features/auth/components/auth_brand_header.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/auth/components/auth_brand_header.dart)
  - Tab Formulir Masuk: [`lib/features/auth/components/auth_login_tab.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/auth/components/auth_login_tab.dart)
  - Tab Formulir Daftar: [`lib/features/auth/components/auth_register_tab.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/auth/components/auth_register_tab.dart)
  - Input Field Terstandarisasi: [`lib/features/auth/components/auth_text_field.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/auth/components/auth_text_field.dart)
  - Bottom Sheet Pemilih Kelas: [`lib/features/auth/components/auth_class_picker.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/auth/components/auth_class_picker.dart)
  - Footer Switcher (Belum punya akun? Daftar): [`lib/features/auth/components/auth_footer_switcher.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/auth/components/auth_footer_switcher.dart)

### 4. Buat Postingan / Jual Produk (Create Post Modal)
- **File Induk**: [`lib/features/create_post/screens/create_post_modal.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/create_post/screens/create_post_modal.dart) (<= 300 baris)
- **Visual Clues**: Modal pembuatan konten, area input teks dengan mention siswa, switch mode jual produk/preloved, upload foto grid, tombol *"Posting"*.
- **Komponen Pendukung**:
  - Area Input Teks Utama: [`lib/features/create_post/components/create_post_main_input_block.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/create_post/components/create_post_main_input_block.dart)
  - Form Atribut Produk (Harga, Stok, Kondisi): [`lib/features/create_post/components/create_post_product_fields.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/create_post/components/create_post_product_fields.dart)
  - Preview & Thumbnail Media: [`lib/features/create_post/components/create_post_media_preview.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/create_post/components/create_post_media_preview.dart)
  - Helper Kompresi Gambar: [`lib/features/create_post/components/create_post_image_helper.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/create_post/components/create_post_image_helper.dart)
  - Bottom Sheets Tambahan: [`lib/features/create_post/components/create_post_bottom_sheets.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/create_post/components/create_post_bottom_sheets.dart)

### 5. Profil Pengguna (User Profile)
- **File Induk**: [`lib/features/profile/screens/profile_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/screens/profile_screen.dart) (<= 280 baris)
- **Controller**: [`lib/features/profile/controllers/profile_controller.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/controllers/profile_controller.dart)
- **Visual Clues**: Avatar profil, nama lengkap, username @siswa, badge jurusan SMKN 8, bio, followers/following, tombol Ikuti/Edit Profil, search bar pencarian postingan akun, tab konten (*Utas, Balasan, Dijual*).
- **Komponen Pendukung**:
  - Header Info & Bio: [`lib/features/profile/components/profile_info_header.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/components/profile_info_header.dart)
  - Bar Pencarian Profil: [`lib/features/profile/components/profile_search_bar.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/components/profile_search_bar.dart)
  - Tab Konten (Utas, Balasan, Dijual): [`lib/features/profile/components/profile_content_tabs.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/components/profile_content_tabs.dart)
  - Kartu Balasan Thread: [`lib/features/profile/components/profile_reply_thread_card.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/components/profile_reply_thread_card.dart)

### 6. Edit Profil (Edit Profile Screen)
- **File Induk**: [`lib/features/profile/screens/edit_profile_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/screens/edit_profile_screen.dart) (<= 270 baris)
- **Visual Clues**: Pratinjau ganti avatar/foto profil, field nama, bio, no WA, pemilih kelas, tombol *"Simpan Perubahan"*.
- **Komponen Pendukung**:
  - Bagian Edit Avatar & Foto: [`lib/features/profile/components/edit_profile_avatar_section.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/components/edit_profile_avatar_section.dart)
  - Formulir Isian Biodata: [`lib/features/profile/components/edit_profile_form_fields.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/components/edit_profile_form_fields.dart)
  - Bar Tombol Simpan Bawah: [`lib/features/profile/components/edit_profile_bottom_bar.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/components/edit_profile_bottom_bar.dart)

### 7. Pencarian & Saran Akun (Search & Discovery)
- **File Induk**: [`lib/features/search/screens/search_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/search/screens/search_screen.dart) (<= 280 baris)
- **Visual Clues**: Search bar atas dengan autocomplete & cancel, tab hasil (*Teratas, Terbaru, Akun*), daftar *"Saran ikuti"* dengan tombol Ikuti/Mengikuti.
- **Komponen Pendukung**:
  - Header & Bar Pencarian: [`lib/features/search/components/search_bar_header.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/search/components/search_bar_header.dart)
  - Tampilan Saran Ikuti Akun: [`lib/features/search/components/search_suggested_accounts_view.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/search/components/search_suggested_accounts_view.dart)
  - Tampilan Hasil Pencarian (Akun & Post): [`lib/features/search/components/search_results_view.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/search/components/search_results_view.dart)
  - Tile Akun Siswa: [`lib/features/search/components/suggested_account_tile.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/search/components/suggested_account_tile.dart)

### 8. Pesan Langsung & Ruang Obrolan (Direct Messages & Chat)
- **File Induk Kotak Masuk (Inbox)**: [`lib/features/messages/screens/direct_messages_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/messages/screens/direct_messages_screen.dart) (<= 285 baris)
- **File Induk Obrolan (Chat Room)**: [`lib/features/messages/screens/chat_conversation_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/messages/screens/chat_conversation_screen.dart) (<= 270 baris)
- **Visual Clues**: Daftar percakapan masuk, filter chips (*Obrolan, Pembeli, Belum Dibaca*), kartu undang teman, bubble percakapan biru kumo & putih, kartu produk context di atas obrolan.
- **Komponen Pendukung Inbox**:
  - Filter Tabs Kapsul: [`lib/features/messages/components/direct_messages_filter_tabs.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/messages/components/direct_messages_filter_tabs.dart)
  - Tile Undang Teman: [`lib/features/messages/components/direct_messages_invite_tile.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/messages/components/direct_messages_invite_tile.dart)
  - Sheet Kirim Pesan Baru: [`lib/features/messages/components/direct_messages_new_chat_sheet.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/messages/components/direct_messages_new_chat_sheet.dart)
  - Item Percakapan: [`lib/features/messages/components/conversation_list_item.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/messages/components/conversation_list_item.dart)
  - Empty State Obrolan: [`lib/features/messages/components/direct_messages_empty_state.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/messages/components/direct_messages_empty_state.dart)
- **Komponen Pendukung Chat Room**:
  - Top Bar Profile & Online Status: [`lib/features/messages/components/chat_app_bar_title.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/messages/components/chat_app_bar_title.dart)
  - Bubble Pesan: [`lib/features/messages/components/chat_message_bubble.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/messages/components/chat_message_bubble.dart)
  - Kartu Konteks Produk: [`lib/features/messages/components/chat_product_card.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/messages/components/chat_product_card.dart)
  - Bar Composer Input Teks: [`lib/features/messages/components/chat_composer_bar.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/messages/components/chat_composer_bar.dart)
  - Sheet Menu Opsi Obrolan: [`lib/features/messages/components/chat_options_sheet.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/messages/components/chat_options_sheet.dart)

### 9. Checkout & Pesanan COD (Checkout Screen)
- **File Induk**: [`lib/features/checkout/screens/checkout_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/checkout/screens/checkout_screen.dart) (<= 260 baris)
- **Visual Clues**: Carousel foto produk, kartu nama & avatar penjual, pemilihan titik temu COD kampus, catatan pembeli, rincian biaya, tombol sticky *"Buat Pesanan COD"*, modal sukses pop-up.
- **Komponen Pendukung**:
  - Carousel Foto Hero: [`lib/features/checkout/components/checkout_hero_image.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/checkout/components/checkout_hero_image.dart)
  - Header Info Produk: [`lib/features/checkout/components/checkout_product_header.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/checkout/components/checkout_product_header.dart)
  - Kartu Identitas Penjual: [`lib/features/checkout/components/checkout_seller_card.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/checkout/components/checkout_seller_card.dart)
  - Kartu Titik Temu COD & Denah: [`lib/features/checkout/components/checkout_location_card.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/checkout/components/checkout_location_card.dart)
  - Kartu Catatan Pembeli: [`lib/features/checkout/components/checkout_buyer_note_card.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/checkout/components/checkout_buyer_note_card.dart)
  - Rincian Total Harga: [`lib/features/checkout/components/checkout_price_breakdown.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/checkout/components/checkout_price_breakdown.dart)
  - Sticky Bottom Action Bar: [`lib/features/checkout/components/checkout_bottom_bar.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/checkout/components/checkout_bottom_bar.dart)
  - Modal Sukses Pesanan: [`lib/features/checkout/components/checkout_success_modal.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/checkout/components/checkout_success_modal.dart)

### 10. Peta Blueprint Interaktif Kampus SMKN 8 (Campus Map Screen)
- **File Induk**: [`lib/features/map/screens/campus_map_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/map/screens/campus_map_screen.dart) (<= 110 baris)
- **Visual Clues**: Canvas denah arsitektur 2D interaktif (*InteractiveViewer*), tombol lantai (*Lt 1 / Lt 2*), filter kategori (*Kantin, Lab, Lobi, Gazebo*), kartu detail ruangan di bawah.
- **Komponen Pendukung**:
  - Painter Blueprint 2D: [`lib/features/map/components/campus_2d_blueprint_painter.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/map/components/campus_2d_blueprint_painter.dart)
  - Top Bar & Pemilih Lantai/Kategori: [`lib/features/map/components/campus_map_header.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/map/components/campus_map_header.dart)
  - Kartu Detail Ruangan & Pilih COD: [`lib/features/map/components/campus_map_room_card.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/map/components/campus_map_room_card.dart)

### 11. Layanan Backend Supabase Domain Terpisah (`lib/core/services/supabase/`)
- Facade Terpadu: [`lib/core/services/supabase_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/supabase_service.dart) (222 baris)
- Auth Service: [`lib/core/services/supabase/supabase_auth_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/supabase/supabase_auth_service.dart)
- Chat & Messaging Service: [`lib/core/services/supabase/supabase_chat_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/supabase/supabase_chat_service.dart)
- Feed & Post Service: [`lib/core/services/supabase/supabase_feed_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/supabase/supabase_feed_service.dart)
- Profile Service: [`lib/core/services/supabase/supabase_profile_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/supabase/supabase_profile_service.dart)
- Social & Follow Service: [`lib/core/services/supabase/supabase_social_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/supabase/supabase_social_service.dart)
- Storage & Image Upload Service: [`lib/core/services/supabase/supabase_storage_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/supabase/supabase_storage_service.dart)
