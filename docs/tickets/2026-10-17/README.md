# Sprint Bug Fixes: Critical Feed & Deletion Integrity (2026-10-17)

Direktori ini memuat tiket spesifikasi teknis dan panduan pengerjaan untuk perbaikan bug krusial pasca-uji coba beta Snaps Mobile.

---

## Daftar Tiket Aktif Hari Ini

| Sequence | Judul Tiket | Domain | Prioritas | Status | File Panduan |
| :---: | :--- | :--- | :---: | :---: | :--- |
| **SNAPS-87** | `fix(feed): deleted post reappears on refresh due to soft-delete filter leak` | `feed / post_deletion / supabase / rls` | CRITICAL | **DONE** | [`SNAPS-87.md`](./SNAPS-87.md) |

---

## Standar Pengerjaan

1. **Integritas Penghapusan**: Postingan yang dihapus oleh pembuatnya tidak boleh muncul kembali di layar Feed, Profile, Search, maupun saat aplikasi di-refresh.
2. **Pilihan Pendekatan**: Memastikan konsistensi antara Hard Delete langsung atau Soft Delete dengan filter RLS dan query kustom.
3. **Audit Target**: Menjaga batas baris file $\le 250$–$300$ baris per panduan arsitektur.
