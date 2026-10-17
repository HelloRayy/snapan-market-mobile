# [SNAPS-87] fix(feed): deleted post reappears on refresh due to soft-delete filter leak

> **Ticket Metadata**:
> - **Sequence**: SNAPS-87
> - **Priority**: CRITICAL
> - **Domain**: `feed / post_deletion / supabase / rls`
> - **Status**: Ticket (Awaiting User Approach Selection)

---

## 1. Problem Statement & Root Cause Analysis

- **Gejala Bug**:
  Pengguna menghapus postingan miliknya dari linimasa. Secara optimis di UI lokal, postingan langsung hilang dari daftar. Namun, ketika layar di-pull-to-refresh atau aplikasi dibuka kembali, postingan tersebut **kembali muncul**.
- **Akar Masalah (Root Cause)**:
  1. **Kebocoran RLS Policy**: Di file migrasi [`supabase/migrations/supabase_snaps82_soft_delete_and_storage_cleanup.sql`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/supabase/migrations/supabase_snaps82_soft_delete_and_storage_cleanup.sql), policy `SELECT` pada tabel `public.market_posts` dikonfigurasi sebagai:
     ```sql
     CREATE POLICY "Market posts viewable by everyone" 
     ON public.market_posts FOR SELECT USING (
       deleted_at IS NULL 
       OR auth.uid() = seller_id 
       OR public.is_admin()
     );
     ```
     Klausul `OR auth.uid() = seller_id` membuat pemilik postingan (`seller_id`) tetap mendapatkan data postingan yang sudah di-soft-delete (`deleted_at IS NOT NULL`) ketika melakukan query `SELECT`.
  2. **Query Flutter Tidak Menyaring `deleted_at`**:
     Di [`lib/core/services/supabase/supabase_feed_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/supabase/supabase_feed_service.dart), method `fetchFeedPosts()`, `fetchUserPosts()`, `fetchPostById()`, dan `searchPosts()` tidak menyertakan filter `.filter('deleted_at', 'is', 'null')`.
  3. **Data Hydration Tanpa Validasi `isDeleted`**:
     Di [`lib/features/feed/controllers/home_feed_controller.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/controllers/home_feed_controller.dart), hasil fetch dari database langsung ditugaskan ke state tanpa memfilter objek yang memiliki `post.isDeleted == true`.

---

## 2. Pilihan Pendekatan Solusi (Technical Trade-offs)

### Opsi A: Permanent Hard Delete (Rekomendasi Simpel & Tuntas)
- **Mekanisme**: Mengubah method `deletePost()` di `supabase_feed_service.dart` menjadi eksekusi `DELETE` permanen langsung (`_client.from('market_posts').delete().match(...)`).
- **Kelebihan**:
  - Tuntas 100%, data fisik dihapus dari PostgreSQL.
  - Komentar, likes, views, dan bookmarks otomatis terhapus via `ON DELETE CASCADE`.
  - Tidak ada risiko kebocoran RLS atau celah query `deleted_at` di masa depan.
  - Tidak memerlukan filter tambahan di setiap endpoint query feed/search/profil.
- **Kekurangan**: Data yang dihapus tidak bisa di-restore atau di-audit di tabel `market_posts`.

### Opsi B: Soft Delete Konsisten (Audit Trail & Restorable)
- **Mekanisme**: Mempertahankan `deleted_at = nowUtc` saat hapus post, namun memperbaiki rantai RLS dan Client:
  1. Perbarui policy SQL: Hilangkan `OR auth.uid() = seller_id` dari policy publik agar hanya admin yang bisa melihat post terhapus.
  2. Tambahkan filter `.filter('deleted_at', 'is', 'null')` pada `fetchFeedPosts()`, `fetchUserPosts()`, `searchPosts()`, dan `fetchPostById()`.
  3. Tambahkan filter `posts = livePosts.where((p) => !p.isDeleted).toList()` di Controller.
- **Kelebihan**: Data tersimpan untuk audit jejak digital dan moderasi sekolah.
- **Kekurangan**: Memerlukan eksekusi migrasi SQL di Supabase console dan pemeliharaan filter di seluruh lapisan query.

---

## 3. Target File Scope

| File Path | Peran & Perubahan |
| :--- | :--- |
| [`lib/core/services/supabase/supabase_feed_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/supabase/supabase_feed_service.dart) | Penyesuaian `deletePost` (Hard Delete langsung atau filter query `deleted_at`) |
| [`lib/features/feed/controllers/home_feed_controller.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/controllers/home_feed_controller.dart) | Sanitasi state feed agar mengabaikan postingan `isDeleted` |
| [`supabase/migrations/supabase_snaps87_fix_post_deletion.sql`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/supabase/migrations/supabase_snaps87_fix_post_deletion.sql) | Migrasi SQL perbaikan RLS policy atau trigger pembersihan data |

---

## 4. Definition of Done (DoD)

- [ ] Menjalankan penghapusan postingan oleh author atau admin.
- [ ] Setelah refresh layar feed (pull-to-refresh) atau restart aplikasi, postingan yang telah dihapus tidak pernah muncul kembali.
- [ ] Di layar profil pengguna (tab post), postingan yang telah dihapus tidak tampil.
- [ ] Hasil pencarian (`searchPosts`) tidak menampilkan postingan yang telah dihapus.
- [ ] Kode bersih, modular, dan sesuai batas baris file.
