# Master Index Tiket Sprint (2026-10-13)

> Direktori ini (`docs/tickets/2026-10-13/`) memuat analisis mendalam dan dokumen pendekatan teknis (*technical approaching*) untuk **3 tiket aktif** kategori **"Ticket"** di Plane.so.
> Fokus sprint hari ini: **Media Experience, Jacob's Law Compliance, Aspect Ratio Multi-Image, dan Interaktif Image Crop Editor**.

---

## Ringkasan Tiket Aktif (Kategori: Ticket)

| Sequence | Judul Tiket | Domain | Prioritas | Status Plane | File Panduan |
| :---: | :--- | :--- | :---: | :---: | :--- |
| **SNAPS-79** | `fix(image-ratio): issue image di feed page ketika di upload tidak sesuai dengna ratio yang ada..` | `feed / post_media / aspect_ratio` | HIGH | `Ticket` | [`SNAPS-79.md`](./SNAPS-79.md) |
| **SNAPS-80** | `fix(image): when image open, ini memiliki ui yang sama semua.` | `ui / lightbox / jacobs_law / avatar_viewer` | MEDIUM | `Ticket` | [`SNAPS-80.md`](./SNAPS-80.md) |
| **SNAPS-81** | `feat(image-crop): add fitur additional ke image` | `image_picker / media / crop_editor` | MEDIUM | `Ticket` | [`SNAPS-81.md`](./SNAPS-81.md) |

---

## Hubungan dan Sinergi Antar-Tiket (Media Pipeline Architecture)

Ketiga tiket ini saling beririsan dalam satu ekosistem **Media Pipeline**:

```
[User Memilih Foto]
         │
         ▼
[SNAPS-81: Image Crop & Pan Editor]
  - User dapat menggeser, zoom, dan crop foto (1:1 untuk Avatar, rasio bebas/16:9/4:3 untuk Feed)
         │
         ▼
[SNAPS-79: Multi-Image Adaptive Aspect Ratio]
  - Saat tampil di feed, rasio asli foto tidak dipaksa melenceng/terpotong 16:9 secara sepihak
         │
         ▼
[SNAPS-80: Contextual Lightbox & Avatar Viewer (Jakob's Law)]
  - Saat avatar ditekan -> Tampil modal Avatar Viewer elegan (lingkaran, gelap, info profil)
  - Saat media feed ditekan -> Tampil Post Media Lightbox (full-screen viewer dengan zoom & aksi sosial)
```

---

## Standar Kerja untuk AI Agent & Developer
1. Buka file panduan tiket spesifik yang sedang ditugaskan (`SNAPS-79.md`, `SNAPS-80.md`, atau `SNAPS-81.md`).
2. Patuhi **Target File Scope** dan jangan memodifikasi file di luar cakupan yang ditentukan.
3. Tinjau opsi teknis dan trade-off pada bagian **Technical Consensus & Architecture**.
4. Validasi kriteria selesai sesuai checklist pada **Definition of Done (DoD)**.
