# [SNAPS-72] fix(bio-bug): bug bio tidak ditampilkan di user orang lain

> **Ticket Metadata**:
> - **Plane ID**: `a64b3b2e-0728-48fb-8e87-b3414cc24ba3`
> - **Sequence**: SNAPS-72
> - **Priority**: HIGH
> - **State Group**: completed / done (Ticket)
> - **Domain**: `profile / database / schema / user_metadata / supabase`

---

## 1. Problem Statement & User Context
- **Deskripsi Masalah User (Plane.so)**:
> *"bio pengguna yang di setting di profile page hanya ditampilkan oleh dirinya sendiri, user lain yang mengunjungi profile orang yang memakai bio tidak ditampilkan. fix ini karna fitur bio terasa sia sia dan bisa menggaggu bisnis flow dari user itu sendiri jika bio emang ditujukan untuk advertise."*

- **Akar Masalah Teknis (Root Cause Analysis)**:
  1. **Ketiadaan Kolom `bio` di Tabel `public.profiles` (Database Schema Defect)**:
     Di seluruh skrip migrasi database ([`schema.sql`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/schema.sql#L7-L35)), tabel `public.profiles` **TIDAK MEMILIKI** kolom `bio` (begitu pula kolom `link` dan `interests`).
  2. **Silent Catch & Degradasi Payload di Client Flutter**:
     Pada [`lib/core/services/supabase/supabase_profile_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/supabase/supabase_profile_service.dart#L180-L225), fungsi `updateProfile`:
     - Pertama, mengirim `fullPayload` yang berisi `'bio': bio`.
     - Karena kolom `bio` tidak ada di tabel `public.profiles`, PostgREST melempar error:
       ```text
       Could not find the 'bio' column of 'profiles' in the schema cache
       ```
     - Exception tersebut ditangkap di blok `catch (e)`, lalu otomatis me-fallback ke `corePayload` yang **hanya meng-update `full_name`, `username`, `class_group`, `nis`, `avatar_url`** tanpa `bio`.
  3. **Data Bio Terjebak di `auth.users.raw_user_meta_data`**:
     Sebelum update database, `updateProfile` memanggil `_client.auth.updateUser` yang menyimpan `bio` ke `auth.users.raw_user_meta_data`.
  4. **Boundary Akses & Mengapa Pemilik Akun Bisa Melihat Bionya**:
     - **Saat Pemilik Akun Membuka Profil Sendiri**:
       [`ProfileController.loadProfile(isOwnProfile: true)`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/controllers/profile_controller.dart#L70) membaca `currentUser.userMetadata`. Di fungsi `_buildUserModel`, bio diambil dari fallback metadata:
       ```dart
       bio: profile?['bio'] as String? ?? (meta['bio'] as String?)?.trim() ?? ''
       ```
       Sehingga pemilik akun **mengira bionya berhasil tersimpan dan tampil**.
     - **Saat Pengguna Lain Membuka Profil Target**:
       [`ProfileController.loadProfile(isOwnProfile: false)`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/controllers/profile_controller.dart#L105) memanggil `getProfileByUsername` yang meng-query tabel `public.profiles`. Karena user lain **tidak memiliki izin membaca `auth.users.raw_user_meta_data` milik orang lain** (kebijakan keamanan Supabase Auth), parameter `meta` bernilai `{}`.
       Hasilnya: `user.bio` selalu bernilai `""` (string kosong), dan [`ProfileInfoHeader`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/components/profile_info_header.dart#L140) menyembunyikan blok teks bio sama sekali!

---

## 2. Target File Scope (Interface-First Coupling)
> Rujukan arsitektur berdasarkan `AGENT_MANIFEST.md`:

| Peran File | Path File di Repositori | Keterangan Peran |
| :--- | :--- | :--- |
| **SQL Migration** | [`supabase/migrations/supabase_snaps72_profile_bio.sql`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/supabase/migrations/supabase_snaps72_profile_bio.sql) | Menambahkan kolom `bio`, `link`, `interests` di `public.profiles`, backfill data dari `auth.users`, dan update trigger `handle_new_user()` |
| **Database Schema Base** | [`schema.sql`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/schema.sql) | Menambahkan kolom `bio`, `link`, `interests` pada deklarasi skema tabel `profiles` |
| **Supabase Profile Service** | [`lib/core/services/supabase/supabase_profile_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/supabase/supabase_profile_service.dart) | Memastikan `updateProfile` menyimpan `bio` ke database secara andal tanpa degradasi |
| **Profile Controller** | [`lib/features/profile/controllers/profile_controller.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/controllers/profile_controller.dart) | Memastikan deserialisasi bio dari record publik dan event Realtime berjalan konsisten |
| **Search Service & Model** | [`lib/features/search/models/search_models.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/search/models/search_models.dart) | Memastikan daftar akun hasil pencarian dapat menampilkan snippet bio pengguna |
| **Profile Info Header Component** | [`lib/features/profile/components/profile_info_header.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/components/profile_info_header.dart) | UI komponen penyaji teks bio di atas followers stats |

---

## 3. Step-by-Step Technical Approach (Untuk AI Agent Eksekutor)

### Langkah 1: Migrasi Database Supabase (`supabase_snaps72_profile_bio.sql`)
1. Tambahkan kolom `bio`, `link`, dan `interests` ke tabel `public.profiles`:
   ```sql
   ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS bio text;
   ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS link text;
   ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS interests text;
   ```
2. Lakukan **One-Time Data Backfill**:
   Salin bio dan link yang sebelumnya terjebak di `auth.users.raw_user_meta_data` ke tabel `public.profiles`:
   ```sql
   UPDATE public.profiles p
   SET 
     bio = COALESCE(p.bio, NULLIF(TRIM(u.raw_user_meta_data->>'bio'), '')),
     link = COALESCE(p.link, NULLIF(TRIM(u.raw_user_meta_data->>'link'), ''))
   FROM auth.users u
   WHERE p.id = u.id 
     AND (u.raw_user_meta_data->>'bio' IS NOT NULL OR u.raw_user_meta_data->>'link' IS NOT NULL);
   ```
3. Perbarui trigger `handle_new_user()` agar saat user baru mendaftar atau login pertama kali, nilai `bio` dan `link` langsung disinkronkan ke `public.profiles`.

### Langkah 2: Audit & Hardening Client Service (`supabase_profile_service.dart`)
1. Di [`SupabaseProfileService.updateProfile`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/supabase/supabase_profile_service.dart#L185):
   - Pastikan `fullPayload` yang dikirim ke `.from('profiles').update(...)` memiliki field `'bio': bio`.
   - Rapikan struktur payload agar tidak perlu fallback degradasi yang membuang kolom `bio`.
2. Di `subscribeToProfile`:
   - Pastikan field `newRecord['bio']` diteruskan ke `currentUserProfileNotifier` dan callback `onUpdate`.

### Langkah 3: Verifikasi di `ProfileController` & Tampilan Profil Publik
1. Uji pemanggilan `ProfileController.loadProfile(isOwnProfile: false, username: targetUser)`:
   - Pastikan objek `user` terisi dengan `user.bio` yang berasal dari kolom `public.profiles.bio`.
   - Pastikan widget `ProfileInfoHeader` merender teks bio di profil pengguna lain.
2. Uji integrasi Edit Profile:
   - Edit bio pada Akun A $\to$ Simpan.
   - Buka profil Akun A dari Akun B $\to$ Verifikasi bio Akun A langsung muncul secara realtime / setelah refresh.

---

## 4. Database Migration Script (SQL)
Simpan skrip berikut di [`supabase/migrations/supabase_snaps72_profile_bio.sql`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/supabase/migrations/supabase_snaps72_profile_bio.sql):

```sql
-- ============================================================================
-- SNAPS-72: Public Bio, Link, & Interests Support for User Profiles
-- ============================================================================

-- 1. Tambah kolom profil publik
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS bio text;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS link text;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS interests text;

-- 2. Backfill bio & link yang tersimpan di auth.users ke public.profiles
UPDATE public.profiles p
SET 
  bio = COALESCE(p.bio, NULLIF(TRIM(u.raw_user_meta_data->>'bio'), '')),
  link = COALESCE(p.link, NULLIF(TRIM(u.raw_user_meta_data->>'link'), ''))
FROM auth.users u
WHERE p.id = u.id 
  AND (u.raw_user_meta_data->>'bio' IS NOT NULL OR u.raw_user_meta_data->>'link' IS NOT NULL);

-- 3. Update handle_new_user() trigger function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
DECLARE
  v_nis text;
  v_class text;
  v_full_name text;
  v_display_name text;
  v_username text;
  v_avatar text;
  v_bio text;
  v_link text;
BEGIN
  v_nis := nullif(trim(coalesce(new.raw_user_meta_data->>'nis', '')), '');
  v_class := nullif(trim(coalesce(new.raw_user_meta_data->>'class_group', '')), '');
  v_full_name := coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name', 'Pengguna Baru');
  v_display_name := nullif(trim(coalesce(new.raw_user_meta_data->>'display_name', '')), '');
  v_username := coalesce(new.raw_user_meta_data->>'username', lower(replace(v_full_name, ' ', '')));
  v_avatar := coalesce(new.raw_user_meta_data->>'avatar_url', new.raw_user_meta_data->>'picture', '');
  v_bio := nullif(trim(coalesce(new.raw_user_meta_data->>'bio', '')), '');
  v_link := nullif(trim(coalesce(new.raw_user_meta_data->>'link', '')), '');

  IF v_nis IS NOT NULL AND EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name = 'student_registry'
  ) THEN
    SELECT class_group, full_name INTO v_class, v_full_name
    FROM public.student_registry
    WHERE nis = v_nis
    LIMIT 1;
  END IF;

  INSERT INTO public.profiles (
    id, full_name, display_name, username, class_group, nis, avatar_url, bio, link, is_verified, role
  ) VALUES (
    new.id,
    coalesce(v_full_name, 'Pengguna Baru'),
    v_display_name,
    v_username,
    coalesce(v_class, 'Siswa Snapan'),
    v_nis,
    v_avatar,
    v_bio,
    v_link,
    false,
    'user'
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    display_name = coalesce(EXCLUDED.display_name, profiles.display_name),
    username = coalesce(EXCLUDED.username, profiles.username),
    class_group = coalesce(EXCLUDED.class_group, profiles.class_group),
    nis = coalesce(EXCLUDED.nis, profiles.nis),
    avatar_url = coalesce(EXCLUDED.avatar_url, profiles.avatar_url),
    bio = coalesce(EXCLUDED.bio, profiles.bio),
    link = coalesce(EXCLUDED.link, profiles.link);

  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 5. Definition of Done (DoD)
- [x] Kolom `bio`, `link`, dan `interests` tersedia di tabel `public.profiles`.
- [x] Data bio pengguna yang sebelumnya tersimpan di `auth.users.raw_user_meta_data` ter-backfill ke `public.profiles`.
- [x] Fungsi `updateProfile` di Flutter berhasil memperbarui field `bio` di tabel `public.profiles` tanpa terkena silent catch fallback.
- [x] Saat Akun B membuka profil Akun A, bio Akun A tampil dengan benar di [`ProfileInfoHeader`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/components/profile_info_header.dart).
- [x] Realtime profile subscription mengupdate bio secara otomatis ketika pemilik akun mengubah bionya.
- [x] Unit/Widget test untuk verifikasi rendering bio publik berjalan hijau (100% pass via `test/profile_bio_test.dart`).
