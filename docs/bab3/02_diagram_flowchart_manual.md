# 02. DIAGRAM FLOWCHART ALUR MANUAL (KONVENSIONAL)

**Dokumen**: Bab III - Bagian 3.2.1  
**Proyek**: Snapan Market Mobile (sNaps) - SMKN 8 Semarang  
**Fokus**: Pemetaan Alur Transaksi Konvensional Siswa Sebelum Menggunakan Sistem Digital  

---

## 1. Definisi & Ruang Lingkup Alur Manual
Alur manual merupakan representasi langkah-langkah kerja yang saat ini dilakukan oleh warga sekolah di SMKN 8 Semarang saat melakukan transaksi jual-beli produk karya vokasi, preloved, maupun makanan ringan secara konvensional melalui grup chat WhatsApp dan transaksi fisik tatap muka.

---

## 2. Diagram Flowchart Manual

```mermaid
flowchart TD
    NodeStart([Mulai: Siswa Ingin Menjual Produk/Karya]) --> NodeUpload[Siswa Mengambil Foto & Membuat Teks Promosi Manual]
    NodeUpload --> NodeBroadcast[Unggah ke Status WhatsApp & Grup Angkatan]
    NodeBroadcast --> NodeWait[Menunggu Respon Chat Calon Pembeli]
    
    NodeWait --> NodeConditionResponse{Apakah Ada Siswa yang Membalas Chat?}
    NodeConditionResponse -- Tidak (Tenggelam) --> NodeExpired[Postingan Hilang dalam 24 Jam / Tanpa Hasil Penjualan]
    NodeExpired --> NodeEndCancel([Selesai / Transaksi Batal])
    
    NodeConditionResponse -- Ya --> NodeNegotiate[Tanya Jawab Manual via DM: Tanya Ketersediaan Stok & Nego Harga]
    NodeNegotiate --> NodeConditionDeal{Apakah Tercapai Kesepakatan Harga?}
    NodeConditionDeal -- Tidak Sepakat --> NodeEndCancel
    
    NodeConditionDeal -- Sepakat --> NodeAppointment[Menentukan Waktu & Janji Temu Lokasi via Chat Teks]
    NodeAppointment --> NodeRisk[Rawan Miskomunikasi: Siswa Salah Lokasi Lantai / Jam Bentrok / Ghosting]
    
    NodeRisk --> NodeMeet[Kedua Siswa Bertemu Secara Fisik di Area Sekolah]
    NodeMeet --> NodeInspect[Pembeli Memeriksa Fisik Barang Secara Langsung]
    NodeInspect --> NodePay[Pembeli Menyerahkan Uang Tunai / Cash]
    NodePay --> NodeReceipt[Penjual Menghitung Kembalian & Menyerahkan Barang Fisik]
    NodeReceipt --> NodeManualRecord[Penjual Mencatat Penjualan di Buku Catatan Kertas / Catatan HP Pribadi]
    NodeManualRecord --> NodeEndSuccess([Selesai: Transaksi Manual Berhasil])
```

---

## 3. Penjelasan Simbol Flowchart yang Digunakan

| Simbol | Nama Simbol | Keterangan Fungsi dalam Diagram |
|---|---|---|
| ⬭ | **Terminator (`[Mulai/Selesai]`)** | Menandai titik awal inisiasi transaksi oleh siswa dan titik akhir selesainya proses. |
| ▭ | **Process (`Proses`)** | Menggambarkan tindakan operasional manusia, seperti memotret karya, menulis status WhatsApp, dan menghitung uang tunai. |
| ◇ | **Decision (`Keputusan`)** | Titik percabangan logika kondisi yang menghasilkan pilihan "Ya" atau "Tidak" (cth: ada respon chat atau tidak). |
| ➔ | **Flowline (`Garis Alir`)** | Menunjukkan arah urutan langkah proses dari atas ke bawah. |

---

## 4. Analisis Masalah & Titik Kritis Alur Manual

1. **Titik Lemah Pencatatan Stok (No Stock Visibility)**:
   Penjual harus merespon chat satu per satu hanya untuk mengabarkan bahwa barang sudah habis terjual, menghabiskan waktu produktif jam sekolah.
2. **Friksi Janji Temu (Meeting Uncertainty)**:
   Pesan teks seperti *"Nanti ketemuan di dekat tangga ya"* sering memicu kebingungan karena SMKN 8 Semarang memiliki banyak gedung dan lantai tangga, sehingga rawan gagal bertemu.
3. **Ketiadaan Bukti Transaksi Resmi**:
   Tidak ada nota digital atau tanda terima transaksi yang mengikat kedua belah pihak, menyulitkan penyelesaian sengketa bila barang yang diserahkan tidak sesuai perjanjian awal.
