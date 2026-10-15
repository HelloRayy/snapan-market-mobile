# [SNAPS-63] feat(security-login): Sistem untuk menganalisa device login ke NIS orang lain.

> **Ticket Metadata**:
> - **Plane ID**: `cae2264b-8aab-47b9-b75e-6f5938037921`
> - **Sequence**: SNAPS-63
> - **Priority**: HIGH
> - **State Group**: unstarted
> - **Domain**: `security / auth / device_fingerprint`

---

## 1. Problem Statement & User Context
- **Deskripsi Asli Plane**:
> Problem context Register page kita memiliki celah bagi user yang iseng login dengan nis orang lain, dan post aneh aneh disana. hal ini mengkhawatirkan bagi team developer karna takut dibuat spamming / berita negatif Troubleshoot terapkan device info di dashboard admin biar kita bisa liat device yang login di nis tersebut ini bisa menjadi masalah serius, jika benre2 ada user yang iseng login dengan akun orang even kita sudah membatasi daftar akun, apakah bagi pelaku tetep bisa memanfaatkan celah yang lain? (misal hapus data aplikasi) atau celah apapun itu

- **Akar Masalah Teknis**: Register/Login page memiliki celah siswa iseng mendaftar atau mencoba login menggunakan NIS siswa lain. Perlu sistem analisis device fingerprint agar dashboard admin dapat mengidentifikasi perangkat yang login pada suatu NIS dan mendeteksi anomali login.

---

## 2. Target File Scope (Interface-First Coupling)
> Rujukan arsitektur berdasarkan `AGENT_MANIFEST.md`:

| Peran File | Path File di Repositori | Keterangan Peran |
| :--- | :--- | :--- |
| **Security Service** | [`lib/core/services/device_security_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/device_security_service.dart) | Menghasilkan hardware UUID, nama model perangkat, dan platform ID |
| **Auth Controller** | [`lib/features/auth/controllers/auth_controller.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/auth/controllers/auth_controller.dart) | Mengirimkan device payload ke Supabase saat verifikasi NIS & login |
| **Auth Register Tab** | [`lib/features/auth/components/auth_register_tab.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/auth/components/auth_register_tab.dart) | Memvalidasi kuota akun per device dan verifikasi NIS |
| **Admin Service (Web)** | [`src/admin/services/adminSecurityService.ts`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/src/admin/services/adminSecurityService.ts) | Menerima dan menganalisis log riwayat device per NIS di dashboard |
| **Admin Tab (Web)** | [`src/admin/pages/DeviceSecurityTab.tsx`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/src/admin/pages/DeviceSecurityTab.tsx) | Menampilkan daftar perangkat yang terhubung dengan akun siswa |

---

## 3. Step-by-Step Technical Approach (Untuk AI Agent Eksekutor)
1. Audit device_security_service.dart: pastikan UUID perangkat persisten menggunakan SharedPreferences/SecureStorage dan tidak mudah di-bypass hanya dengan clear cache.
2. Pada rpc register_student_account atau trigger auth, catat device_id, device_model, dan os_version ke tabel user_devices.
3. Berikan warning di Auth UI jika device terdeteksi mencoba login dengan NIS yang sudah terasosiasi dengan perangkat aktif lain.
4. Kirim log aktivitas mencurigakan ke admin dashboard (DeviceSecurityTab.tsx) jika 1 device mendaftar lebih dari limit akun yang diizinkan.

---

## 4. Key Decisions & Questions Needed
- ❓ Apakah siswa yang kehilangan HP diizinkan mengajukan unlink device langsung ke admin atau melalui mekanisme verifikasi khusus?
- ❓ Berapa batas toleransi device yang diizinkan per satu NIS (misal: maksimal 2 device)?

---

## 5. Definition of Done (DoD)
- [ ] Device fingerprint tercatat di Supabase setiap kali login/register dengan NIS.
- [ ] Dashboard admin menampilkan riwayat hardware model dan IP/waktu login siswa.
- [ ] Adanya pembatasan eksploitasi pembuatan akun liar per hardware ID.

