# [SNAPS-13] feat(mascot): add mascot ui dengan "/page-mascot" sebagai sumber assets nya

> **Ticket Metadata**:
> - **Plane ID**: `daaeb4cf-acc5-4468-a399-5e6871732502`
> - **Sequence**: SNAPS-13
> - **Priority**: MEDIUM
> - **State Group**: unstarted (Ticket)
> - **Domain**: `profile / mascot / identity_flair`

---

## 1. Problem Statement & User Context
- **Deskripsi Masalah di Plane.so**:
  > *"tambahkan mascot dari '/page-mascot' jangan tambahkan semua add berberapa dlu sebgai demo testing. letakan ini disamping username ketika user mengupload feed. mascot di select di user profile. menggantikan preset profile itu. terapkan per bundle jadi misal ketika milih koala → ada berbagai emotion, crying, pusing dll sesuai dengan di page mascot. sistem pemilihan mascot ini berada di edit profile page user, menggantikan foto profile preset.*
  > *For the beta test, batasi access ini. kita mulai ujicoba khsusu untuk akun '@snaps' pada mobile apps saja. hanya akun tersebut yang memiliki access preset bundle icon pack di edit profile page nya. untuk kedepannya ini bakal diterapkan ke berbagai siswa, jadi buat fitur yang scalable bukan hardcoded 1 akun saja.*
  > *Image relevance: ganti icon bulat sabit menjadi mascot, seperti img refer discord ini. implementasi mascot juga sama seperti gambar Slimeto, tepat di kanan dari username dikasi page mascot."*

- **Akar Masalah Teknis**:
  1. **Absennya Kolom Maskot di Skema Profil**: Tabel `profiles` di Supabase saat ini hanya menyimpan `avatar_url` bertipe URL gambar bulat. Tidak ada metadata untuk menyimpan `mascot_bundle` (misal: `koala`, `fox`, `bear`) dan `mascot_mood` (misal: `idle`, `happy`, `crying`).
  2. **Preset Avatar Lama Kaku**: Komponen [`edit_profile_avatar_section.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/components/edit_profile_avatar_section.dart) hanya memiliki carousel picker preset Oreo design statis, belum ada panel pemilihan bundle maskot karakter.
  3. **Header Kartu Feed Belum Merender Flair Maskot**: Di [`post_card_header.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_card/post_card_header.dart), di samping kanan nama akun hanya ada ikon verified blue `Icons.verified_rounded`. Belum ada slot widget untuk merender maskot mikro (18px - 20px) ala Discord Nitro status.

---

## 2. Target File Scope (Interface-First Coupling)

| Peran File | Path File di Repositori | Keterangan Peran |
| :--- | :--- | :--- |
| **Asset Directory Maskot** | `assets/mascots/` | Folder penyimpanan aset sprite/vektor karakter Koboyo terpilih |
| **Profile Model & Schema** | [`lib/core/models/user_profile_model.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/models/user_profile_model.dart) / `schema.sql` | Penambahan field `mascot_flair: { bundle, emotion }` |
| **Edit Profile Screen** | [`lib/features/profile/components/edit_profile_avatar_section.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/components/edit_profile_avatar_section.dart) | Panel pemilih bundle maskot (khusus akun pilot beta `@snaps`) |
| **Post Card Header** | [`lib/features/feed/components/post_card/post_card_header.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/components/post_card/post_card_header.dart) | Render badge maskot mikro tepat di sebelah kanan username |
| **Market Post Model** | [`lib/features/feed/models/market_post_model.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/models/market_post_model.dart) | Parsing metadata maskot author dari respons Supabase feed |

---

## 3. Step-by-Step Technical Approach

1. **Persiapan Aset Maskot Terbatas (Demo Pilot)**:
   * Pilih **2 bundle karakter awal** dari Koboyo/page-mascot (misal: `fox` dan `koala`).
   * Ekstrak frame emosi penting (Idle/Smile, Happy, Sad/Crying, Shocked) ke format SVG atau WebP transparan berukuran ringan di `assets/mascots/`.
2. **Skema Database & Guardrail Hak Akses Beta**:
   * Tambahkan kolom JSONB `mascot_flair` di tabel `public.profiles`.
   * Di `edit_profile_screen.dart`, lakukan validasi hak akses:
     ```dart
     final bool canAccessMascot = user.username == 'snaps' || user.isBetaTester == true;
     ```
     Jika aktif, tampilkan tab/opsi baru: **"Pilih Maskot Profil"**.
3. **Penyematan di Samping Username (Post Card Header)**:
   * Di `post_card_header.dart`, posisikan widget maskot mikro:
     ```dart
     if (item.seller.mascotFlair != null)
       Padding(
         padding: const EdgeInsets.only(left: 4.0),
         child: MascotFlairBadge(
           bundle: item.seller.mascotFlair!.bundle,
           emotion: item.seller.mascotFlair!.emotion,
           size: 18.0,
         ),
       ),
     ```
   * Desain mikro-badge: rounded 4px, tidak memakan tinggi baris teks, selaras dengan penempatan badge server booster / custom emoji Discord.
4. **Interaksi Tap Mikro (Easter Egg)**:
   * Ketika maskot mikro di samping username disentuh singkat (*tap*), trigger haptic feedback ringan dan tampilkan tooltip popover nama maskot (misal: *"Koala Snaps 🐨"*).

---

## 4. Questions for Reviewer (Harus Dijawab Reviewer)

> ❓ **Pertanyaan 1**: Karakter apa saja (selain Koala) yang ingin dimasukkan ke dalam paket uji coba tahap pertama? (Rekomendasi: Fox, Cat, atau Bear).
> ❓ **Pertanyaan 2**: Apakah emosi maskot (misal: senang vs sedih) ditentukan secara statis saat siswa memilih di profil, atau berubah secara dinamis berdasarkan jenis postingan?

---

## 5. Definition of Done (DoD)
- [ ] Tersedia aset bundel maskot lokal di folder `assets/mascots/`.
- [ ] User dengan akun pilot `@snaps` dapat memilih bundel maskot di halaman Edit Profil.
- [ ] Postingan feed yang dibuat oleh pemilik maskot menampilkan ikon karakter mikro tepat di samping kanan nama pengguna.
- [ ] Pengguna biasa non-pilot tidak melihat opsi pemilih maskot hingga fitur dirilis penuh pasca-beta.
