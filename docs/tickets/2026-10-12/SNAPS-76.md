# [SNAPS-76] style(topic-tag): improve ui dan sistem dari pencarian topik tag / community

> **Ticket Metadata**:
> - **Plane ID**: `64234e8b-3cd0-4446-bf8f-80ad7d66afdf`
> - **Sequence**: SNAPS-76
> - **Priority**: LOW
> - **State Group**: in_review (Completed UI Polish)
> - **Domain**: `feed / topic_tag / search_navigation`

---

## 1. Problem Statement & User Context
- **Deskripsi Masalah di Plane.so** :
  > *"topic-tag kita sempurankan ui nya, fokus ke ui dari topic tag di feed post detail, kita improvisasi ui di overlay popup nya. kemudian fungsi tap topic-tag ini langsung mengarah ke topik yang sedang dibahas itu → search page. jadi flow nya, ketika user mengunggah dengan topic-tag, ketika user lain click topic-tag tersebut → bakal direct ke search page dengan keyword sesuai dengan topic tag tersebut."*
- **User Directives**:
  - Hapus ALL CAPS yang berlebihan (ganti title menjadi friendly: `"Topik untuk kamu"`).
  - Hilangkan karakter `#` yang canggung baik di daftar nama topik maupun di search field.
  - Samakan kualitas overlay popover dengan standar Snaps (rounded 16px, border 0.8px, layered box shadow, live search/create filter).

---

## 2. Target File Scope & Implementation

| Peran File | Path File di Repositori | Keterangan Perubahan |
| :--- | :--- | :--- |
| **Topic Picker Popover** | [`lib/features/create_post/components/create_post_bottom_sheets.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/create_post/components/create_post_bottom_sheets.dart) | Refactor popover modal: Title `"Topik untuk kamu"` + micro-sparkle icon, live filter search input bersih tanpa simbol `#`, tile card dengan rounded icon container & subtle elevation. |
| **Author Line Topic Indicator** | [`lib/features/create_post/components/create_post_author_line.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/create_post/components/create_post_author_line.dart) | Bersihkan tampilan topik terpilih, ganti `#` dengan ikon semantik `tag_fill` / `star_fill` & clear button bulat halus. |
| **Post Card Header Pill** | [`lib/features/feed/components/post_card/post_card_header.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_card/post_card_header.dart) | Redesign topic tag menjadi kapsul badge (*pill style*) Threads: background neutral-100 / tinted primary, font 12px semi-bold, icon tag/official glyph, tanpa `#` mentah. |
| **Preset Topics Model** | [`lib/features/create_post/models/create_post_types.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/create_post/models/create_post_types.dart) | Bersihkan nama topik menjadi natural: `Frontend`, `PJBL`, `Kantin Sekolah`, `GitHub`, `Preloved`. |
| **Feed & Search Navigation** | [`lib/features/feed/screens/home_feed_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/screens/home_feed_screen.dart), [`lib/features/feed/screens/post_detail_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/screens/post_detail_screen.dart) | Menyambungkan `onTopicClick` langsung membuka `SearchScreen(initialQuery: tag)` dengan pencarian otomatis. |

---

## 3. Definition of Done (DoD)
- [x] Title popover ramah & elegan: `"Topik untuk kamu"` dengan sentence case dan ikon sparkle.
- [x] Karakter `#` mentah dihilangkan dari label topik dan kotak input pencarian.
- [x] Input bar pencarian topik memiliki fitur live-filter dan opsi instan *"Gunakan {query}"* untuk membuat topik kustom baru.
- [x] Desain overlay popover konsisten dengan `PostSubmenuPopover` (16px border-radius, 0.8px border `#F1F5F9`, double drop shadow lembut).
- [x] Topic tag di feed dan post detail tampil sebagai pill capsule yang rapi, responsive, dan tidak bertabrakan dengan nama user.
- [x] Mengetuk pill topic tag di feed maupun detail langsung mengarahkan ke SearchScreen dengan query topik terkait terisi dan tersaring otomatis.
