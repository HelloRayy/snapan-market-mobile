class CheckoutSpot {
  final String id;
  final String name;
  final String building;
  final int floor;
  final String categoryLabel;
  final String hint;

  const CheckoutSpot({
    required this.id,
    required this.name,
    required this.building,
    required this.floor,
    required this.categoryLabel,
    required this.hint,
  });
}

const List<CheckoutSpot> kDefaultCampusSpots = [
  CheckoutSpot(
    id: "kantin-utama",
    name: "Kantin Utama & Pujasera",
    building: "Area Pujasera Belakang",
    floor: 1,
    categoryLabel: "Kantin & Makanan",
    hint: "Spot COD paling ramai saat jam istirahat. Dekat stan jus.",
  ),
  CheckoutSpot(
    id: "lobi-utama",
    name: "Lobi Utama & Resepsionis",
    building: "Gedung Utama (Sayap Atas)",
    floor: 1,
    categoryLabel: "Lobi & Informasi",
    hint: "Dekat pintu gerbang masuk utama dari Jl. Pandanaran 2.",
  ),
  CheckoutSpot(
    id: "lab-rpl",
    name: "Lab Software & Game (PPLG)",
    building: "Gedung Vokasi Lt. 2",
    floor: 2,
    categoryLabel: "Laboratorium Komputer",
    hint: "Lantai 2 koridor barat, depan Lab Jaringan.",
  ),
  CheckoutSpot(
    id: "gazebo-koperasi",
    name: "Gazebo & Koperasi Siswa",
    building: "Area Taman Samping",
    floor: 1,
    categoryLabel: "Area Terbuka",
    hint: "Gazebo kayu depan koperasi sekolah.",
  ),
];
