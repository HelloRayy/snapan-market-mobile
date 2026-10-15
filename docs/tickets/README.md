# Master Index Tiket Aktif Snapan Market Mobile (Plane.so)

> Direktori ini (`docs/tickets/`) memuat panduan teknis dan analisis mendalam untuk tiket yang berada pada state **"Ticket"** (Unstarted) di Plane.so.
> Seluruh issue aktif dikelompokkan berdasarkan tanggal sprint pengerjaan.

---

## 🚀 Sprint Aktif Hari Ini (2026-10-15)

> Folder: [`docs/tickets/2026-10-15/`](./2026-10-15/README.md)  
> Fokus: **Beta Release Operational Readiness (Bug Reporting, App About Info, Empty States Recovery, & Content Moderation)**.

| Sequence | Judul Tiket | Domain | Prioritas | Status Plane | File Panduan |
| :---: | :--- | :--- | :---: | :---: | :--- |
| **SNAPS-83** | `feat(feedback): in-app bug and feedback reporter modal with category and screenshot` | `feedback / bug_report / supabase` | HIGH | `Ticket` | [`SNAPS-83.md`](./2026-10-15/SNAPS-83.md) |
| **SNAPS-84** | `feat(about): release status, app version info and environment sheet in settings/profile` | `settings / version / build_info` | MEDIUM | `Ticket` | [`SNAPS-84.md`](./2026-10-15/SNAPS-84.md) |
| **SNAPS-85** | `feat(empty-state): polish contextual empty states and action recoveries across screens` | `ui / empty_state / search / feed` | MEDIUM | `Ticket` | [`SNAPS-85.md`](./2026-10-15/SNAPS-85.md) |
| **SNAPS-86** | `feat(moderation): quick content reporting pipeline and auto-hide threshold for flagged posts` | `moderation / report / rls / safety` | HIGH | `Ticket` | [`SNAPS-86.md`](./2026-10-15/SNAPS-86.md) |

---

## 📦 Arsip Sprint Sebelumnya

### 1. Sprint 2026-10-13 (Media Experience & Aspect Ratio)
> Folder: [`docs/tickets/2026-10-13/`](./2026-10-13/README.md)
* **SNAPS-79**: `fix(image-ratio): issue image di feed page ketika di upload tidak sesuai dengna ratio yang ada` (Done)
* **SNAPS-80**: `fix(image): when image open, ini memiliki ui yang sama semua` (Done)
* **SNAPS-81**: `feat(image-crop): add fitur additional ke image` (Done)

### 2. Sprint 2026-10-12 (Feed Performance & Clean UI)
> Folder: [`docs/tickets/2026-10-12/`](./2026-10-12/README.md)
* **SNAPS-75**: `hold(jualan-mode): for sprint beta release, kita hold fitur penjualan` (Done)
* **SNAPS-78**: `fix(loading): optimalisasi fitur load data / upload data yang berlangsung lama` (Done)
* **SNAPS-77**: `style(ui): fix shadow berlebihan, dan ui yang tidak clean di apps` (Done)
* **SNAPS-76**: `style(topic-tag): improve ui dan sistem dari pencarian topik tag / community` (Done)
* **SNAPS-74**: `feat(ui): add ui update ketika OTA rilis, ui update bukan hanya bottom sheet tapi lebih informatif` (Backlog)
* **SNAPS-71**: `feat(notification): add notif ketika ada dm masuk` (Done)
* **SNAPS-13**: `feat(mascot): add mascot ui dengan "/page-mascot" sebagai sumber assets nya` (Done)

### 3. Sprint 2026-10-10 (Foundation & Security)
> Folder: [`docs/tickets/2026-10-10/`](./2026-10-10/)
* **SNAPS-73, SNAPS-72, SNAPS-70, SNAPS-69, SNAPS-68, SNAPS-63, SNAPS-39, SNAPS-33, SNAPS-26, SNAPS-19, SNAPS-35**

---

## Standar Kerja untuk AI Agent
Setiap AI Agent yang ditugaskan mengerjakan tiket:
1. **Wajib Membaca HANYA 1 File Tiket Terkait** (contoh: buka [`docs/tickets/2026-10-13/SNAPS-79.md`](./2026-10-13/SNAPS-79.md)).
2. **Kunci Target File** pada Bagian 2 (*Target File Scope*). Jangan membaca file di luar scope tersebut.
3. **Eksekusi Sesuai Langkah** pada Bagian 3 (*Step-by-Step Technical Approach*).
4. **Verifikasi Kriteria Selesai** pada Bagian 5 (*Definition of Done*).
