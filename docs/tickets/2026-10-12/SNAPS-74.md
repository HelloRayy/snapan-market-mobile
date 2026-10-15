# [SNAPS-74] feat(ui): add ui update ketika OTA rilis, ui update bukan hanya bottom sheet tapi lebih informatif

> **Ticket Metadata**:
> - **Plane ID**: `af68fba9-630b-4bc3-a059-c23468921370`
> - **Sequence**: SNAPS-74
> - **Priority**: MEDIUM
> - **State Group**: unstarted (Ticket)
> - **Domain**: `ota / app_update / dialog_system`

---

## 1. Problem Statement & User Context
- **Deskripsi Masalah di Plane.so**:
  > *"UI sekarng terasa timpa timbun antar ui, ui ota information hanya dikasi ui bototmsheet. ketika ada beberapa case tertentu example: user not login (!login) tampilannya dia overlay popup yang snapanians itu kan nah terus ada ota update ditimbun dengan bottomsheet ini jelek si. kita coba lakukan explorasi ui untuk ini."*

- **Akar Masalah Teknis**:
  1. **Konflik Z-Index & Tumpukan Modal**: Saat user belum login, layar menampilkan overlay fullscreen [`auth_prompt_overlay.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/auth/components/auth_prompt_overlay.dart). Pada saat yang sama, jika pengecekan versi OTA mendeteksi update, [`update_info_bottom_sheet.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/components/update_info_bottom_sheet.dart) ditembakkan ke atas layar melalui `showModalBottomSheet`. Hasilnya: Bottom sheet terpotong atau menimpa kartu login secara berantakan.
  2. **Format Bottom Sheet Kurang Informatif**: Bottom sheet terasa sempit untuk memuat changelog poin-poin fitur baru, perbaikan bug, dan ukuran file unduhan.
  3. **Manajemen Dialog Global Belum Memiliki Antrean (Queue)**: Tidak ada pengecekan status state layar (`isAuthOverlayActive`) sebelum memunculkan popup OTA.

---

## 2. Target File Scope (Interface-First Coupling)

| Peran File | Path File di Repositori | Keterangan Peran |
| :--- | :--- | :--- |
| **App Update Service** | [`lib/core/services/app_update_service.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/services/app_update_service.dart) | Logika trigger update, pencegahan overlap, dan prioritas antrean |
| **Update Dialog/Modal** | [`lib/core/components/update_info_bottom_sheet.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/core/components/update_info_bottom_sheet.dart) | Refactor dari bottom sheet menjadi **Centered Card Dialog** elegan |
| **Home Feed Screen** | [`lib/features/feed/screens/home_feed_screen.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/feed/screens/home_feed_screen.dart) | Penyesuaian saat auto-prompt update dipanggil di root view |
| **Auth Prompt Overlay** | [`lib/features/auth/components/auth_prompt_overlay.dart`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/lib/features/auth/components/auth_prompt_overlay.dart) | Koordinasi status overlay agar tidak bertabrakan dengan dialog OTA |

---

## 3. Step-by-Step Technical Approach

1. **Ganti Paradigma UI: Dari Bottom Sheet ke Centered Release Card**:
   * Ubah `UpdateInfoBottomSheet` menjadi dialog tengah (`showDialog` / `Dialog`) bergaya modern Kumo/Apple:
     * Header: Ilustrasi roket/update + chip versi baru (misal: `v1.0.28 • 15 MB`).
     * Body: Container berscroll berisi changelog berformat poin-poin rapi (Fitur Baru, Perbaikan Bug).
     * Footer: Tombol ganda ("Nanti Saja" dan tombol primary "Perbarui Sekarang" dengan progress bar download).
2. **Cegah Tumpukan Modal (Collision Prevention)**:
   * Tambahkan flag di `AppUpdateService`: jika `AuthPromptOverlay` sedang aktif di layar (user tamu/belum login), **tunda (postpone)** pemunculan dialog OTA hingga user berhasil login atau masuk ke layar utama.
3. **Penyediaan Tombol Manual di Drawer**:
   * Jika user menunda update, indikator badge pill "Update" tetap menyala di item menu drawer `Periksa pembaruan`, sehingga siswa bisa membuka modal update kapan saja tanpa dipaksa di awal.

---

## 4. Questions for Reviewer (Harus Dijawab Reviewer)

> ❓ **Pertanyaan 1**: Jika rilis update berkategori *Wajib (Mandatory)*, apakah user tamu yang belum login tetap harus dipaksa update terlebih dahulu sebelum bisa melihat form login?
> ❓ **Pertanyaan 2**: Apakah kamu setuju format tampilan diubah total menjadi **Centered Modal Card** (di tengah layar seperti popup App Store/Play Store) daripada bottom sheet yang terpotong dari bawah?

---

## 5. Definition of Done (DoD)
- [ ] Dialog update OTA tidak pernah muncul bersamaan menimpa `AuthPromptOverlay`.
- [ ] Informasi update menampilkan nomor versi, ukuran file APK, dan catatan rilis (changelog) yang terstruktur jelas.
- [ ] Proses unduh APK menampilkan persentase download yang akurat (0% - 100%) langsung di dalam modal.
