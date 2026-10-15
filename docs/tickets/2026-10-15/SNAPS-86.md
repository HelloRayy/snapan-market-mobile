# [SNAPS-86] feat(moderation): quick content reporting pipeline and auto-hide threshold for flagged posts

> **Ticket Metadata**:
> - **Sequence**: SNAPS-86
> - **Priority**: HIGH
> - **Domain**: `moderation / report / rls / safety`
> - **Status**: Ticket (Ready to Implement)

---

## 1. Problem Statement & User Context

- **Kondisi Saat Ini**:
  Di berkas [`report_content_bottom_sheet.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/sheets/report_content_bottom_sheet.dart):
  1. Kontainer sheet masih menggunakan warna hardcoded `Colors.white` dan teks deskripsi menyebutkan nama sekolah yang salah (*"SMKN 8 Semarang"* alih-alih konteks SMKN 8 Jember / lingkungan sekolah).
  2. Saat siswa melaporkan postingan yang melanggar (misalnya konten tidak pantas atau penipuan), postingan tersebut **masih tetap muncul** di feed lokal siswa tersebut.
  3. Di sisi Supabase, laporan hanya masuk ke tabel `content_reports` status `pending`. Tidak ada mekanisme auto-hide: jika ada postingan berbahaya yang dilaporkan oleh banyak siswa sekaligus saat pameran PJBL, postingan itu tetap tampil sampai admin membuka dashboard SQL.
- **Kebutuhan Beta Release**:
  Sistem perlindungan konten responsif:
  - **Optimistic Local Hide**: Postingan yang dilaporkan langsung disembunyikan seketika dari layar pengguna yang melaporkan.
  - **Auto-Hide Threshold di Database**: Trigger PostgreSQL otomatis menyembunyikan postingan (`is_hidden = true` atau `status = 'flagged'`) jika menerima 3 laporan unik dari siswa berbeda.
  - **Dark Mode Polish**: Sheet pelaporan bebas warna putih keras dan teks ramah panduan sekolah.

---

## 2. Target File Scope

| File Path | Peran & Perubahan |
| :--- | :--- |
| [`lib/features/feed/components/sheets/report_content_bottom_sheet.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/sheets/report_content_bottom_sheet.dart) | Memperbaiki dark mode surface, deskripsi lingkungan sekolah, dan mengembalikan status post ID yang dilaporkan |
| [`lib/features/feed/controllers/home_feed_controller.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/controllers/home_feed_controller.dart) | Menambahkan method `hidePostLocally(String postId)` untuk menyembunyikan postingan yang dilaporkan dari list aktif |
| [`lib/features/feed/screens/home_feed_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/screens/home_feed_screen.dart) | Menangani hasil `ReportContentBottomSheet` agar memicu penghilangan kartu secara animasi |
| [`supabase/migrations/supabase_snaps86_auto_moderation.sql`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/supabase/migrations/supabase_snaps86_auto_moderation.sql) | **(Baru)** Trigger auto-hide postingan jika count laporan unik >= 3 dan policy feed untuk mengabaikan post yang di-flag |

---

## 3. Step-by-Step Technical Approach

### Langkah 1: Database Migration (Auto-Hide Threshold)
Buat SQL trigger pada tabel `content_reports`:
```sql
-- Tambah kolom is_hidden jika belum ada di market_posts
ALTER TABLE public.market_posts ADD COLUMN IF NOT EXISTS is_hidden BOOLEAN DEFAULT FALSE;

-- Function auto-hide jika laporan >= 3
CREATE OR REPLACE FUNCTION public.fn_check_report_threshold()
RETURNS TRIGGER AS $$
DECLARE
    report_count INT;
BEGIN
    SELECT COUNT(DISTINCT reporter_id) INTO report_count
    FROM public.content_reports
    WHERE post_id = NEW.post_id;

    IF report_count >= 3 THEN
        UPDATE public.market_posts
        SET is_hidden = TRUE
        WHERE id = NEW.post_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_check_report_threshold ON public.content_reports;
CREATE TRIGGER tr_check_report_threshold
AFTER INSERT ON public.content_reports
FOR EACH ROW
EXECUTE FUNCTION public.fn_check_report_threshold();
```

### Langkah 2: Query Filter Feed Update
Pastikan query `fetchPosts` di [`supabase_feed_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/supabase/supabase_feed_service.dart) menyaring `is_hidden.is.not.true`.

### Langkah 3: Optimistic UI Removal di Flutter
1. Saat dialog report ditutup dengan status sukses `true`, controller feed langsung memanggil:
   ```dart
   feedController.removePostFromFeed(post.id);
   ```
2. Animasi kartu menghilang dengan mulus dan muncul konfirmasi: *"Postingan telah disembunyikan dari linimasa Anda."*

---

## 4. Definition of Done (DoD)

- [ ] Sheet pelaporan konten mendukung Dark Mode tanpa artefak putih.
- [ ] Teks panduan disesuaikan dengan konteks sekolah SMKN 8 Jember.
- [ ] Postingan yang dilaporkan langsung lenyap dari layar pengguna secara optimis tanpa perlu refresh manual.
- [ ] Postingan yang mendapatkan 3 laporan unik disembunyikan otomatis oleh database dari feed publik.
- [ ] Lolos analisis `flutter analyze` dengan 0 errors.
