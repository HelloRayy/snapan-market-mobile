# Sprint Beta Release: 4 Fitur Mikro Operasional (2026-10-15)

Direktori ini memuat tiket spesifikasi teknis dan panduan pengerjaan untuk 4 fitur mikro wajib sebelum rilis beta publik aplikasi Snaps Mobile.

---

## Daftar Tiket Aktif Hari Ini

| Sequence | Judul Tiket | Domain | Prioritas | Status | File Panduan |
| :---: | :--- | :--- | :---: | :---: | :--- |
| **SNAPS-83** | `feat(feedback): in-app bug and feedback reporter modal with category and screenshot` | `feedback / bug_report / supabase` | HIGH | **DONE** | [`SNAPS-83.md`](./SNAPS-83.md) |
| **SNAPS-84** | `feat(about): release status, app version info and environment sheet in settings/profile` | `settings / version / build_info` | MEDIUM | [`SNAPS-84.md`](./SNAPS-84.md) |
| **SNAPS-85** | `feat(empty-state): polish contextual empty states and action recoveries across screens` | `ui / empty_state / search / feed` | MEDIUM | [`SNAPS-85.md`](./SNAPS-85.md) |
| **SNAPS-86** | `feat(moderation): quick content reporting pipeline and auto-hide threshold for flagged posts` | `moderation / report / rls / safety` | HIGH | [`SNAPS-86.md`](./SNAPS-86.md) |

---

## Standar Pengerjaan

1. **Fokus Tiket**: Setiap tiket dirancang independen dan dapat dikerjakan secara bertahap tanpa konflik dependensi silang.
2. **Kesesuaian Desain**: Seluruh modal dan komponen wajib mengadopsi token warna adaptif Dark Mode (`AppColors.adaptiveCanvas`, `AppColors.adaptiveSurfaceElevated`, dan `AppColors.adaptiveText`).
3. **Penyimpanan Data**: Fitur pelaporan (bug dan konten) terhubung langsung ke tabel Supabase dengan Row Level Security (RLS) yang ketat.
