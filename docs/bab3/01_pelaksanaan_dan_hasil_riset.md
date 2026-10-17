# 01. PELAKSANAAN DAN HASIL RISET SISTEM

**Dokumen**: Bab III - Bagian 3.1  
**Proyek**: Snapan Market Mobile (sNaps) - SMKN 8 Semarang  
**Fokus**: Metodologi Riset Lapangan, Observasi Lapangan, dan Analisis Kebutuhan Pengguna  

---

## 1. Latar Belakang & Urgensi Riset
Sebelum merancang arsitektur sistem perangkat lunak, diperlukan analisis empiris terhadap permasalahan komunikasi dan aktivitas ekonomi mikro di lingkungan **SMKN 8 Semarang**. Sebagai Sekolah Menengah Kejuruan Pusat Keunggulan dengan jurusan teknologi (PPLG), seni kreatif (DKV), dan tata boga (Kuliner), terdapat potensi karya siswa yang belum tersalurkan secara terorganisir.

---

## 2. Metodologi Pelaksanaan Riset

Pelaksanaan riset dilakukan menggunakan kombinasi metode kualitatif dan kuantitatif selama periode observasi di lingkungan sekolah:

| Metode | Sasaran Responden | Instrumen Riset | Tujuan |
|---|---|---|---|
| **Wawancara Mendalam (*In-Depth Interview*)** | Perwakilan pengurus kelas dan siswa jurusan PPLG, DKV, dan Kuliner (Total 24 Responden). | Panduan wawancara semi-terstruktur mengenai kebiasaan bertransaksi dan berdiskusi daring. | Menggali *pain points* penggunaan WhatsApp grup dan kebutuhan wadah karya vokasi. |
| **Observasi Langsung (*Field Observation*)** | Interaksi siswa saat jam istirahat sekolah (09.45-10.15 WIB dan 11.45-12.30 WIB) di area kantin, gazebo, dan bengkel lab. | Lembar catatan observasi pola titik kumpul dan serah terima barang COD. | Menentukan lokasi-lokasi strategis yang layak dijadikan *School Meeting Points*. |
| **Kuesioner Minat Fitur** | 60 Siswa aktif lintas angkatan (Kelas X, XI, dan XII). | Angket kuesioner skala Likert (1-5) via Google Form sekolah. | Mengukur tingkat kebutuhan autentikasi berbasis NIS dan fitur feed komunitas. |

---

## 3. Temuan & Analisis Hasil Riset

### 3.1 Kelemahan Ekosistem Komunikasi Eksisting (Grup Chat WhatsApp)
- **Tenggelamnya Informasi Penting (*Chat Flood*)**: 87.5% responden menyatakan promosi karya atau barang preloved di grup kelas/angkatan cepat tertimbun percakapan sehari-hari.
- **Ketiadaan Katalog Terpusat**: Calon pembeli tidak dapat melihat riwayat stok barang yang masih tersedia karena postingan status WhatsApp hilang dalam waktu 24 jam.
- **Miskomunikasi Janji Temu COD**: 62% siswa pernah mengalami pembeli/penjual terlambat atau salah tempat saat janji ketemuan di sekolah karena tidak adanya titik lokasi baku.

### 3.2 Kebutuhan Kanal Unjuk Karya Vokasi Lintas Jurusan
- **Jurusan PPLG**: Siswa membutuhkan media pameran portofolio proyek perangkat lunak, bot, aset grafis game, dan jasa instalasi sistem.
- **Jurusan DKV**: Siswa memerlukan etalase karya cetak kreatif seperti stiker custom, gantungan kunci akrilik, poster, dan jasa ilustrasi digital.
- **Jurusan Kuliner**: Siswa sering memproduksi makanan ringan dan pastry wirausaha yang membutuhkan sistem pre-order cepat saat jam sekolah.

### 3.3 Validitas Keamanan dengan Single Identity NIS
- Seluruh responden (100%) dan guru pembimbing menyetujui bahwa sistem wajib memverifikasi Nomor Induk Siswa (NIS) yang terdaftar di buku induk sekolah. Hal ini menjamin bahwa seluruh transaksi hanya terjadi antar warga resmi sekolah serta meniadakan risiko penipuan dari pihak luar.

---

## 4. Kesimpulan Matriks Kebutuhan Sistem (System Requirements)

Berdasarkan hasil riset, dirumuskan kebutuhan fungsional inti yang menjadi landasan arsitektur sistem sNaps:
1. **Autentikasi Tertutup**: Registrasi akun wajib memvalidasi NIS terhadap database induk sekolah (`student_registry`).
2. **Feed Komunitas Model Threads**: Wadah publikasi karya dan ruang diskusi interaktif dengan dukungan polling dan komentar.
3. **Katalog Produk Vokasi**: Etalase produk terstruktur dengan filter kategori jurusan sekolah.
4. **Checkout COD Titik Temu Sekolah**: Transaksi tanpa gateway perbankan rumit, mengandalkan penentuan titik temu resmi sekolah (*Gazebo, Kantin, Bengkel PPLG*).
