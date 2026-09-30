import "package:flutter/material.dart";

/// Kategori titik COD kampus
enum LocationCategory {
  canteen,
  lobby,
  outdoor,
  lab,
  library,
  sports,
}

/// Model data lengkap untuk Titik Temu COD Kampus SMKN 8 Semarang
class CampusLocationSpot {
  final String id;
  final String name;
  final String code;
  final String buildingName;
  final int floor; // 1 atau 2
  final LocationCategory category;
  final String categoryLabel;
  final String description;
  final String codSafetyHint;
  final String bestTime;
  final Offset pinPosition;
  final bool isPopular;
  final IconData iconData;
  final Color themeColor;

  const CampusLocationSpot({
    required this.id,
    required this.name,
    required this.code,
    required this.buildingName,
    required this.floor,
    required this.category,
    required this.categoryLabel,
    required this.description,
    required this.codSafetyHint,
    required this.bestTime,
    required this.pinPosition,
    this.isPopular = false,
    required this.iconData,
    required this.themeColor,
  });
}

/// Daftar resmi spot COD di area sekolah SMKN 8 Semarang
const List<CampusLocationSpot> kCampusLocationSpots = [
  CampusLocationSpot(
    id: "kantin-utama",
    name: "Kantin Utama & Pujasera",
    code: "KANTIN",
    buildingName: "Area Pujasera Belakang",
    floor: 1,
    category: LocationCategory.canteen,
    categoryLabel: "Kantin & Makanan",
    description: "Pusat jajanan, stan minuman segar, dan area meja makan siswa.",
    codSafetyHint: "Titik COD terfavorit & ramai saat jam istirahat. Dekat stan jus buah.",
    bestTime: "Istirahat 1 (09.45 - 10.15) & Istirahat 2 (11.45 - 12.30)",
    pinPosition: Offset(660, 705),
    isPopular: true,
    iconData: Icons.restaurant_rounded,
    themeColor: Color(0xFFF97316),
  ),
  CampusLocationSpot(
    id: "lobi-utama",
    name: "Lobi Utama & Resepsionis",
    code: "LOBI DEPAN",
    buildingName: "Gedung Utama (Sayap Depan)",
    floor: 1,
    category: LocationCategory.lobby,
    categoryLabel: "Lobi & Informasi",
    description: "Pusat informasi tamu, etalase piala prestasi, dan area tunggu dekat gerbang masuk.",
    codSafetyHint: "Terpantau pos satpam & CCTV. Sangat aman dan mudah ditemukan oleh pembeli luar/kelas lain.",
    bestTime: "Pagi sebelum bel masuk (06.30 - 06.55) & Pulang sekolah (15.30+)",
    pinPosition: Offset(250, 145),
    isPopular: true,
    iconData: Icons.meeting_room_rounded,
    themeColor: Color(0xFF3D38F5),
  ),
  CampusLocationSpot(
    id: "gazebo-koperasi",
    name: "Gazebo Taman & Koperasi Siswa",
    code: "GAZEBO",
    buildingName: "Area Taman Samping",
    floor: 1,
    category: LocationCategory.outdoor,
    categoryLabel: "Area Terbuka & Taman",
    description: "Gazebo kayu teduh di bawah pepohonan rindang samping lapangan basket.",
    codSafetyHint: "Suasana santai & adem. Nyaman untuk cek kondisi barang elektronik/buku sebelum bayar.",
    bestTime: "Istirahat 1 & Jam kosong pelajaran",
    pinPosition: Offset(835, 640),
    isPopular: true,
    iconData: Icons.park_rounded,
    themeColor: Color(0xFF10B981),
  ),
  CampusLocationSpot(
    id: "lab-rpl",
    name: "Lab Software & Game (PPLG)",
    code: "LAB RPL",
    buildingName: "Gedung Vokasi Lt. 2",
    floor: 2,
    category: LocationCategory.lab,
    categoryLabel: "Laboratorium Komputer",
    description: "Koridor depan Lab Rekayasa Perangkat Lunak 1 & 2 serta Game Development.",
    codSafetyHint: "Cocok untuk transaksi sesama anak jurusan IT/PPLG. Dekat dispenser air lantai 2.",
    bestTime: "Pergantian jam pelajaran & Istirahat 2",
    pinPosition: Offset(780, 490),
    isPopular: false,
    iconData: Icons.laptop_chromebook_rounded,
    themeColor: Color(0xFF6366F1),
  ),
  CampusLocationSpot(
    id: "perpustakaan-lt2",
    name: "Perpustakaan Digital SMKN 8",
    code: "PERPUS",
    buildingName: "Gedung Literasi Lt. 2",
    floor: 2,
    category: LocationCategory.library,
    categoryLabel: "Perpustakaan & Literasi",
    description: "Area lobi depan perpustakaan dengan bangku baca dan pendingin ruangan.",
    codSafetyHint: "Wajib jaga ketenangan. Ideal untuk COD buku pelajaran, novel, atau modul ujian.",
    bestTime: "Istirahat 1 & 2 (Buka pk 08.00 - 15.00)",
    pinPosition: Offset(320, 210),
    isPopular: false,
    iconData: Icons.menu_book_rounded,
    themeColor: Color(0xFF8B5CF6),
  ),
  CampusLocationSpot(
    id: "lapangan-basket",
    name: "Tribun Lapangan Olahraga",
    code: "LAPANGAN",
    buildingName: "Gelanggang Olahraga Terbuka",
    floor: 1,
    category: LocationCategory.sports,
    categoryLabel: "Fasilitas Olahraga",
    description: "Tribun penonton di samping lapangan basket dan futsal sekolah.",
    codSafetyHint: "Area luas dan terang. Mudah janjian sambil melihat kegiatan ekstrakurikuler.",
    bestTime: "Sore hari saat kegiatan ekskul (15.30 - 17.00)",
    pinPosition: Offset(550, 520),
    isPopular: false,
    iconData: Icons.sports_basketball_rounded,
    themeColor: Color(0xFFEC4899),
  ),
];
