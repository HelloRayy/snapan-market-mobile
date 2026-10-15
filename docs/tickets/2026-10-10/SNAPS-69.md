# [SNAPS-69] feat(views-post): add views count di feed yang kita posting

> **Ticket Metadata**:
> - **Plane ID**: `83a64622-9575-4b43-bb73-d2ed26d170da`
> - **Sequence**: SNAPS-69
> - **Priority**: MEDIUM
> - **State Group**: started / in_progress (Ticket)
> - **Domain**: `feed / analytics / post_views / device_fingerprint / supabase`

---

## 1. Problem Statement & User Context
- **Deskripsi Masalah User (Plane.so)**:
> *"Ketika user pembuat, berhasil ngepost sesuatu. dia tidak tau berapa orang yang melihat hasil dari postingan tersebut. kita akan bikin sistem, dimana 1 device yang melihat postingan itu, masuk ke ui views nya di feed postingan tersebut."*

- **Kebutuhan Produk**:
  1. Penulis/pembuat postingan (maupun pembaca feed) ingin mengetahui metrik jangkauan (*reach/views*) dari setiap postingan yang diposting.
  2. **Aturan Deduplikasi 1 Device = 1 View**: Satu perangkat fisik (*unique device identifier*) hanya dihitung satu kali view per postingan agar metrik views tidak dapat di-spam / di-abuse dengan refresh berulang-ulang.
  3. **Visualisasi di Feed & Detail**: Jumlah views muncul secara elegan di *action bar* atau deretan metrik postingan (misalnya di samping Like, Comment, Repost, atau di deretan metadata dengan ikon mata/chart analitik modern mirip Threads / X).
  4. **Performa & Non-blocking**: Pencatatan view tidak boleh memperlambat scroll feed (harus fire-and-forget, didelegasikan via queue/debounced batching, dan didukung RPC Supabase atomic).

---

## 2. Target File Scope (Interface-First Coupling)
> Rujukan arsitektur berdasarkan `AGENT_MANIFEST.md`:

| Peran File | Path File di Repositori | Keterangan Peran |
| :--- | :--- | :--- |
| **Database Migration** | [`supabase/migrations/supabase_snaps69_post_views.sql`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/supabase/migrations/supabase_snaps69_post_views.sql) | DDL tabel `post_views` (dengan `UNIQUE(post_id, device_id)`), kolom `views_count` di `market_posts`, dan RPC `record_post_view` |
| **Device Identifier** | [`lib/core/services/device_security_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/device_security_service.dart) | Penyedia identitas perangkat unik yang persisten (`getDeviceId()`) |
| **Model Post** | [`lib/features/feed/models/market_post_model.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/models/market_post_model.dart) | Parser dan field `viewsCount` di `MarketPostModel` |
| **Service Supabase Feed** | [`lib/core/services/supabase/supabase_feed_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/supabase/supabase_feed_service.dart) | RPC caller `recordPostView(postId, deviceId)` dan select query `views_count` |
| **Action Bar UI** | [`lib/features/feed/components/post_card/post_action_bar.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_card/post_action_bar.dart) | Menampilkan indikator angka views dengan ikon mata (*Threads/X style*) di bar aksi postingan |
| **Detail Post Screen** | [`lib/features/feed/screens/post_detail_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/screens/post_detail_screen.dart) | Trigger view saat layar detail postingan dibuka & tampilkan metrik views di detail |
| **Feed Visibility Trigger** | [`lib/features/feed/components/post_card/market_post_card.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_card/market_post_card.dart) | Memicu pencatatan view saat postingan muncul di viewport feed |

---

## 3. Step-by-Step Technical Approach (Untuk AI Agent Eksekutor)

### Langkah 1: Skema Database & RPC Deduplikasi View (Postgres)
Buat migrasi Supabase:
1. Tambahkan kolom agregasi di `market_posts`:
   ```sql
   ALTER TABLE public.market_posts 
   ADD COLUMN IF NOT EXISTS views_count bigint NOT NULL DEFAULT 0;
   ```
2. Buat tabel audit `post_views` untuk deduplikasi berbasis device:
   ```sql
   CREATE TABLE IF NOT EXISTS public.post_views (
     id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
     post_id uuid NOT NULL REFERENCES public.market_posts(id) ON DELETE CASCADE,
     device_id text NOT NULL,
     user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
     viewed_at timestamptz NOT NULL DEFAULT now(),
     CONSTRAINT uq_post_device_view UNIQUE (post_id, device_id)
   );

   CREATE INDEX IF NOT EXISTS idx_post_views_post_id ON public.post_views(post_id);
   ```
3. Buat RPC atomic `record_post_view(p_post_id uuid, p_device_id text, p_user_id uuid DEFAULT NULL)`:
   - Gunakan `INSERT ... ON CONFLICT (post_id, device_id) DO NOTHING`.
   - Jika row berhasil di-insert (`FOUND`), lakukan `UPDATE market_posts SET views_count = views_count + 1 WHERE id = p_post_id;`.
   - Mengembalikan `views_count` terbaru.

### Langkah 2: Model & Query Data (Flutter)
1. Di [`lib/features/feed/models/market_post_model.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/models/market_post_model.dart):
   - Tambahkan properti `final int viewsCount;` pada `MarketPostModel` (default `0`).
   - Parse dari JSON: `viewsCount: (json['views_count'] ?? json['viewsCount'] ?? 0) as int`.
   - Tambahkan ke `copyWith` dan `toJson`.
2. Di [`lib/core/services/supabase/supabase_feed_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/supabase/supabase_feed_service.dart):
   - Implementasikan method `Future<int?> recordPostView(String postId)`:
     - Ambil `deviceId` dari `DeviceSecurityService.instance.getDeviceId()`.
     - Panggil RPC `record_post_view` via Supabase client secara *unawaited / non-blocking* agar UI tetap responsif 120Hz.

### Langkah 3: Integrasi UI Post Action Bar (Simple Minimalist: No Background)
Di sisi kanan (`trailing`) [`lib/features/feed/components/post_card/post_action_bar.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_card/post_action_bar.dart):
- Render views secara clean tanpa border/background pill (`just eyes icon + label`):
  ```
  [ ❤️  💬  🔁  ↗️ ]                         👁️ 1.9k  [ 📦 12 ]
  ```
- Implementasi Widget:
  ```dart
  Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Views Metric (Clean minimal: hanya ikon mata + angka tabular)
      if (item.viewsCount > 0) ...[
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.eye,
              size: 14.5,
              color: AppColors.ashGray,
            ),
            const SizedBox(width: 4.0),
            Text(
              formatCompactNumber(item.viewsCount),
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w400,
                color: AppColors.graphite,
                fontFeatures: [FontFeature.tabularFigures()],
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        if (item.isProduct && item.stock != null && item.stock! > 0)
          const SizedBox(width: 8.0),
      ],

      // Stock Pill (Tetap ada jika postingan adalah produk market)
      if (item.isProduct && item.stock != null && item.stock! > 0)
        ...[ /* existing stock pill */ ],
    ],
  )
  ```

### Langkah 4: Triggering Logic (Kapan View Dihitung?)
1. **Saat Postingan Dibuka di Detail (`PostDetailScreen`)**:
   - Panggil `recordPostView(post.id)` di `initState`.
2. **Saat Postingan Masuk Viewport di Feed**:
   - Simpan cache set lokal ID postingan yang sudah dicatat dalam sesi ini (`_viewedPostIdsInMemory`) agar tidak menembak network berulang kali saat user scroll naik-turun.

---

## 4. Key Decisions & Questions Needed
- ❓ **Tampilan Views**: Apakah jumlah views ingin ditampilkan ke semua orang (publik seperti di X / Threads) atau hanya pemilik postingan?
  - *Rekomendasi*: Tampilkan secara publik di feed & detail agar menambah kesan hidup dan sosial di platform Snaps.
- ❓ **Format Angka**: Menggunakan formatter compact bawaan Snaps (`formatCompactNumber`), misal `1.2k`, `350`, `12k` untuk konsistensi type scale.

---

## 5. Definition of Done (DoD)
- [ ] Migrasi database `post_views` dan RPC `record_post_view` siap dan dapat dieksekusi di Supabase.
- [ ] Field `viewsCount` terintegrasi di `MarketPostModel` dan query feed Supabase.
- [ ] 1 Device fisik hanya dihitung 1 kali per postingan (deduplikasi constraint `(post_id, device_id)`).
- [ ] Ikon views dan angka counter muncul rapi di UI Feed Card dan Post Detail Screen.
- [ ] Eksekusi pencatatan view berjalan secara *non-blocking* tanpa jank atau freeze pada scrolling feed.
- [ ] `flutter analyze` bersih tanpa error.
