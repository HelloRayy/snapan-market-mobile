import "package:flutter/material.dart";

class CampusRoom {
  final String id;
  final String name;
  final String code;
  final String buildingName;
  final int floor;
  final String category;
  final String categoryLabel;
  final String description;
  final String hint;
  final Offset pinPosition;
  final bool isPopularCodSpot;

  const CampusRoom({
    required this.id,
    required this.name,
    required this.code,
    required this.buildingName,
    required this.floor,
    required this.category,
    required this.categoryLabel,
    required this.description,
    required this.hint,
    required this.pinPosition,
    this.isPopularCodSpot = false,
  });
}

const List<CampusRoom> kCampusRooms = [
  // Lantai 1
  CampusRoom(
    id: "kantin-utama",
    name: "Kantin Utama & Pujasera Siswa",
    code: "KANTIN",
    buildingName: "Area Pujasera Belakang",
    floor: 1,
    category: "canteen",
    categoryLabel: "Kantin & Makanan",
    description: "Pusat jajanan, minuman dingin, dan meja makan santai siswa SMKN 8 Semarang.",
    hint: "Spot COD paling ramai saat jam istirahat. Dekat stan jus & snack.",
    pinPosition: Offset(660, 705),
    isPopularCodSpot: true,
  ),
  CampusRoom(
    id: "lobi-utama",
    name: "Lobi Utama & Resepsionis",
    code: "LOBI DEPAN",
    buildingName: "Gedung Utama (Sayap Atas)",
    floor: 1,
    category: "lobby",
    categoryLabel: "Lobi & Informasi",
    description: "Pusat informasi, etalase piala prestasi kejuruan, dan ruang tunggu tamu.",
    hint: "Dekat pintu gerbang masuk utama dari Jl. Pandanaran 2.",
    pinPosition: Offset(250, 145),
    isPopularCodSpot: true,
  ),
  CampusRoom(
    id: "aula-limasan",
    name: "Gedung Aula Serbaguna (Limasan)",
    code: "AULA UTAMA",
    buildingName: "Gedung Aula Tengah",
    floor: 1,
    category: "facility",
    categoryLabel: "Aula & Pertemuan",
    description: "Gedung megah beratap limasan untuk pameran karya teknologi dan pentas seni.",
    hint: "Gedung besar beratap limasan tepat di tengah area sekolah.",
    pinPosition: Offset(490, 480),
    isPopularCodSpot: false,
  ),
  CampusRoom(
    id: "gazebo-koperasi",
    name: "Gazebo Taman & Koperasi Siswa",
    code: "GAZEBO",
    buildingName: "Area Taman Samping",
    floor: 1,
    category: "outdoor",
    categoryLabel: "Area Terbuka",
    description: "Gazebo kayu rindang di bawah pohon untuk diskusi dan kumpul santai.",
    hint: "Dekat lapangan basket dan koperasi siswa.",
    pinPosition: Offset(835, 640),
    isPopularCodSpot: true,
  ),
  // Lantai 2
  CampusRoom(
    id: "lab-rpl",
    name: "Lab Software Engineering (PPLG 1 & 2)",
    code: "LAB RPL",
    buildingName: "Gedung Vokasi Lt. 2",
    floor: 2,
    category: "lab",
    categoryLabel: "Laboratorium Komputer",
    description: "Lab workstation high-spec untuk pengembangan aplikasi web, mobile, dan game.",
    hint: "Lantai 2 koridor barat, depan tangga utama gedung vokasi.",
    pinPosition: Offset(780, 490),
    isPopularCodSpot: true,
  ),
  CampusRoom(
    id: "studio-dkv",
    name: "Studio Animasi & Desain (DKV)",
    code: "STUDIO DKV",
    buildingName: "Gedung Vokasi Lt. 2",
    floor: 2,
    category: "lab",
    categoryLabel: "Studio Desain",
    description: "Studio rendering, display grafis, wacom drawing area, dan fotografi.",
    hint: "Lantai 2 sayap timur, dekat ruang server.",
    pinPosition: Offset(850, 420),
    isPopularCodSpot: false,
  ),
];
