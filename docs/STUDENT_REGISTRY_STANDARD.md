# Standarisasi & Aturan Impor Data Siswa (Student Registry Standard)
**Snapan Market Mobile (Snaps)** — SMKN 8 Semarang (SNAPS-61)

Dokumen ini berfungsi sebagai **buku panduan & aturan baku (data contract)** untuk mengelola, memasukkan, atau mengimpor data siswa baru (dari Tata Usaha, Dapodik, atau file Excel sekolah) ke dalam sistem Snapan Market.

---

## 📌 1. Aturan Format Baku Penamaan Kelas (Class Group)

Format kelas yang diakui resmi di seluruh antarmuka aplikasi Snaps menggunakan kombinasi **Angka Romawi (Tingkat) + Singkatan Jurusan Kapital + Nomor Rombel**.

### Format Standar:
```text
<TINGKAT_ROMAWI> <JURUSAN> <NOMOR_ROMBEL>
```

### Contoh Benar (Accepted / Standard):
- ✅ `X PPLG 1`, `X PPLG 2`
- ✅ `XI PPLG 1`, `XI PPLG 2`
- ✅ `XII PPLG 1`, `XII PPLG 2`
- ✅ `XI DKV 1`, `XI DKV 2`
- ✅ `XI TJKT 1`, `XI TJKT 2`
- ✅ `XI LK 1`, `XI PS 1`

### Contoh Salah (Akan Ditolak / Harus Dinormalisasi):
- ❌ `11 pplg 2` *(Menggunakan angka arab dan huruf kecil)*
- ❌ `11 PPLG 2` *(Menggunakan angka arab)*
- ❌ `XI-PPLG-2` atau `XI/PPLG/2` *(Menggunakan tanda hubung/garis miring)*
- ❌ `Kelas XI PPLG 2` *(Menggunakan kata depan 'Kelas')*

---

## 🏫 2. Master Data Pilihan di SMKN 8 Semarang

Sistem memvalidasi kelas berdasarkan 3 elemen turunan berikut:

| Elemen | Format Baku | Pilihan yang Valid |
|---|---|---|
| **Tingkat (Grade)** | Angka Romawi | `X`, `XI`, `XII` |
| **Jurusan (Major)** | Huruf Kapital | `DKV` (Desain Komunikasi Visual)<br>`LK` (Layanan Perbankan Syariah / Keuangan)<br>`PPLG` (Pengembangan Perangkat Lunak & Gim)<br>`PS` (Perbankan Syariah)<br>`TJKT` (Teknik Jaringan Komputer & Telekomunikasi) |
| **Nomor Rombel** | Angka Biasa | `1`, `2`, `3` |

---

## 🔄 3. Mekanisme "Penerjemah Otomatis" (Auto-Normalization Guard)

Jika data mentah siswa dari pihak sekolah masih menggunakan format angka arab biasa (misal: `11 pplg 2`), sistem Snaps telah dilengkapi dengan lapisan *auto-normalizer* (`AuthConstants.normalizeClassGroup`):

1. **Pemetaan Tingkat Otomatis:**
   - Angka `10` dipetakan otomatis ke `X`
   - Angka `11` dipetakan otomatis ke `XI`
   - Angka `12` dipetakan otomatis ke `XII`
2. **Kapitalisasi Jurusan:**
   - `pplg`, `tjkt`, `dkv`, `ps`, `lk` otomatis diubah menjadi `PPLG`, `TJKT`, `DKV`, `PS`, `LK`.
3. **Pemisah Standar:**
   - Pemisah karakter spasi ganda, tanda hubung (`-`), atau garis miring (`/`) otomatis dirapikan menjadi spasi tunggal.

*Meskipun sistem memiliki penerjemah otomatis, berkas database/JSON yang diunggah ke repositori atau database WAJIB mengikuti format baku Romawi.*

---

## 🗄️ 4. Struktur Skema JSON Data Siswa

Berkas master data siswa lokal disimpan di `assets/data/students_demo_11_pplg_2.json` (atau berkas per-angkatan):

```json
[
  {
    "nis": "11840",
    "name": "RADITYA RAYHAN YOGISWARA",
    "class_group": "XI PPLG 2"
  },
  {
    "nis": "11816",
    "name": "AIDA DWI RIANA PUTRI",
    "class_group": "XI PPLG 2"
  }
]
```

### Spesifikasi Field:
1. `nis` (*String*, Wajib, Unik):
   - Nomor Induk Siswa 5 digit angka resmi sekolah (contoh: `"11840"`).
   - Dilarang mengandung spasi di awal atau akhir.
2. `name` (*String*, Wajib):
   - Nama lengkap resmi siswa sesuai buku induk / rapor.
   - Menggunakan huruf kapital.
3. `class_group` (*String*, Wajib):
   - Format baku Romawi: `"XI PPLG 2"`.

---

## ⚡ 5. Skrip Normalisasi Database Supabase (SQL)

Jika terdapat data akun siswa terdahulu yang masih tersimpan dengan angka arab (misal: `11 pplg 2`), jalankan skrip berikut di **Supabase SQL Editor**:

```sql
-- Normalisasi format kelas di profiles dari angka biasa ke Romawi
update public.profiles
set class_group = regexp_replace(
  regexp_replace(
    regexp_replace(
      trim(class_group),
      '^10[\\s\\-_/]+', 'X '
    ),
    '^11[\\s\\-_/]+', 'XI '
  ),
  '^12[\\s\\-_/]+', 'XII '
)
where class_group ~ '^(10|11|12)[\\s\\-_/]';

-- Perbaiki huruf kecil pada jurusan jika ada
update public.profiles
set class_group = regexp_replace(class_group, 'pplg', 'PPLG', 'i')
where class_group ~* 'pplg';

update public.profiles
set class_group = regexp_replace(class_group, 'tjkt', 'TJKT', 'i')
where class_group ~* 'tjkt';

update public.profiles
set class_group = regexp_replace(class_group, 'dkv', 'DKV', 'i')
where class_group ~* 'dkv';
```
