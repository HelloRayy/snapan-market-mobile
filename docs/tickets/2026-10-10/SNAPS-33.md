> **Ticket Metadata**:
> - **Plane ID**: `9a287d59-102a-4ad2-a488-dc86e8e930fe`
> - **Sequence**: SNAPS-33
> - **Priority**: LOW (POSTPONED)
> - **State Group**: postponed / rejected
> - **Domain**: `auth / onboarding / profile`

> [!CAUTION]
> **LESSON LEARNED & RETROSPECTIVE RULE (MUTLAK)**:
> 1. **Dilarang langsung mengimplementasikan layar interstitial pasca-register** tanpa verifikasi urgensi & user fatigue. Layar jeda paksa pasca-register merusak *Time to Value (TTV)* user baru.
> 2. **Gunakan pendekatan Contextual Nudge / In-App Reminder** di halaman profil asli daripada memblokir alur registrasi.
> 3. Alur registrasi dipertahankan langsung menuju Feed (`onSuccess()`). Fitur interstitial screen resmi **DITUNDA/DIBATALKAN**.

---

## 1. Problem Statement & User Context
- **Deskripsi Asli Plane**:
> Problem Context Ketika new user baru mencoba aplikasi, akun profile sangat polosan. sehingga kita perlu 'mengarahkan' user untuk mencoba melengkapi User Profile ini. hal ini memberikan dampak positif juga bagi ekosistem apps kita karna apps kita tidak hanya dikenal app dummy user doang, tapi berasa hidup gitu.  Inovation Solution tambahkan ui di auth untuk interactive profile page, misal ketika user mengganti username secara realtime di bagian auth dia akan terganti gitu.  untuk penerapan ini fleksible, tapi saya ada berbagai macam saran. Kita bisa terapkan di Auth register page, flownya ketika habis input username dan password. ada page semacam 'Set a Profile' untuk meng guide si user melengkapi profile.  page Set a Profile ini ada interactive profile page, dilengkapi dengan username, profile picture(with pen editor), add bio dan parameter field lainnya yang dibutuhkan. hasil akhir, dari hasil Set a Profile itu → akan sync dengan real profile akhir dan tersinkron dengan database. Ini adalah fitur yang termasuk fitur critical, kita perlu menerapkan ini. jika tidak, maka ekosistem dan user experience akan tidak terpenuhi. User akan merasa bosan, dan aplikasi terlihat tidak hidup.

- **Akar Masalah Teknis**: Siswa baru yang berhasil registrasi langsung mendarat di halaman Feed dengan profil kosong (tanpa bio, avatar default). Hal ini membuat akun terlihat pasif/dummy dan menurunkan interaksi sosial aplikasi.

---

## 2. Target File Scope (Interface-First Coupling)
> Rujukan arsitektur berdasarkan `AGENT_MANIFEST.md`:

| Peran File | Path File di Repositori | Keterangan Peran |
| :--- | :--- | :--- |
| **Auth Controller** | [`lib/features/auth/controllers/auth_controller.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/auth/controllers/auth_controller.dart) | Mendeteksi akun siswa baru pasca registrasi dan mengarahkan ke alur onboarding |
| **Auth Screen** | [`lib/features/auth/screens/auth_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/auth/screens/auth_screen.dart) | Orchestrator auth yang menampilkan transisi ke onboarding flow |
| **Onboarding Component** | [`lib/features/auth/components/onboarding_profile_setup_sheet.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/auth/components/onboarding_profile_setup_sheet.dart) | Komponen leaf baru: interaktif live-preview kartu profil + picker avatar + input bio |
| **Profile Controller** | [`lib/features/profile/controllers/profile_controller.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/controllers/profile_controller.dart) | Menyimpan data kustomisasi awal ke Supabase profiles |
| **Avatar Section** | [`lib/features/profile/components/edit_profile_avatar_section.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/profile/components/edit_profile_avatar_section.dart) | Komponen pemilih avatar gambar / preset silhouette |

---

## 3. Step-by-Step Technical Approach (Untuk AI Agent Eksekutor)
1. Buat komponen baru onboarding_profile_setup_sheet.dart (< 250 baris) dengan live-preview kartu profil yang langsung bereaksi terhadap ketikan display name dan bio.
2. Tambahkan opsi tombol aksi avatar (upload galeri atau pilih warna avatar tema).
3. Di AuthController.registerWithNis(), jika registrasi berhasil, tunda navigasi ke main feed dan buka onboarding setup.
4. Sediakan tombol "Simpan & Mulai" dan tombol "Lewati untuk sekarang" (Skip).
5. Simpan data profil ke tabel profiles via ProfileController.

---

## 4. Key Decisions & Questions Needed
- ❓ Apakah siswa wajib mengisi bio minimal beberapa karakter atau boleh melewati langkah onboarding (Skip)?
- ❓ Apakah preset avatar warna default diizinkan bagi siswa yang belum ingin mengunggah foto asli?

---

## 5. Definition of Done (DoD)
- [ ] Siswa baru diarahkan ke onboarding profil interaktif setelah registrasi berhasil.
- [ ] Live preview kartu profil memperbarui nama dan bio secara instan saat diketik.
- [ ] Data tersimpan sukses ke Supabase dan tercatat di AGENT_MANIFEST.md.

