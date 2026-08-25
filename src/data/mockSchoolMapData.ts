export interface RoomZone {
  id: string;
  name: string;
  code: string;
  floor: number; // 1, 2, or 3
  category: 'canteen' | 'lab' | 'class' | 'lobby' | 'outdoor' | 'facility';
  categoryLabel: string;
  description: string;
  hint: string;
  path: string; // SVG path data
  pinPosition: { x: number; y: number };
  isPopularCodSpot: boolean;
  colorPreset?: string;
}

export interface MapFeature {
  id: string;
  type: 'table' | 'atrium' | 'pillar' | 'entrance' | 'stairs';
  x: number;
  y: number;
  width?: number;
  height?: number;
  radius?: number;
  label?: string;
  floor: number;
}

export interface FloorData {
  floor: number;
  name: string;
  subtitle: string;
  rooms: RoomZone[];
  features: MapFeature[];
}

export const SCHOOL_FLOORS: FloorData[] = [
  {
    floor: 1,
    name: 'Lantai 1',
    subtitle: 'Lobi Utama, Kantin & Ruang Kelas Dasar',
    features: [
      // Central Circular Atrium (persis gambar referensi)
      { id: 'atrium-1', type: 'atrium', x: 230, y: 260, radius: 24, label: 'Atrium', floor: 1 },
      // Meja-meja Kantin (kotak kuning khas referensi di area bawah)
      { id: 'table-1', type: 'table', x: 270, y: 560, width: 18, height: 18, floor: 1 },
      { id: 'table-2', type: 'table', x: 320, y: 560, width: 18, height: 18, floor: 1 },
      { id: 'table-3', type: 'table', x: 250, y: 600, width: 18, height: 18, floor: 1 },
      { id: 'table-4', type: 'table', x: 295, y: 600, width: 18, height: 18, floor: 1 },
      { id: 'table-5', type: 'table', x: 345, y: 600, width: 18, height: 18, floor: 1 },
      { id: 'table-6', type: 'table', x: 270, y: 640, width: 18, height: 18, floor: 1 },
      { id: 'table-7', type: 'table', x: 320, y: 640, width: 18, height: 18, floor: 1 },
      { id: 'table-8', type: 'table', x: 250, y: 680, width: 18, height: 18, floor: 1 },
      { id: 'table-9', type: 'table', x: 295, y: 680, width: 18, height: 18, floor: 1 },
      { id: 'table-10', type: 'table', x: 345, y: 680, width: 18, height: 18, floor: 1 },
      // Pintu Masuk Gerbang
      { id: 'ent-1', type: 'entrance', x: 230, y: 60, width: 60, height: 12, label: 'Pintu Gerbang Utama', floor: 1 },
    ],
    rooms: [
      {
        id: 'kantin-utama',
        name: 'Kantin Sekolah (Meja Tengah)',
        code: 'KANTIN',
        floor: 1,
        category: 'canteen',
        categoryLabel: 'Kantin & Makanan',
        description: 'Area pujasera & meja makan utama SMKN 8 Jakarta.',
        hint: 'Spot COD paling favorit saat jam istirahat. Dekat stan minuman jus.',
        path: 'M 140 540 L 410 540 L 410 740 L 140 740 Z',
        pinPosition: { x: 295, y: 620 },
        isPopularCodSpot: true,
      },
      {
        id: 'lobi-utama',
        name: 'Lobi Depan Gedung A',
        code: 'LOBI A',
        floor: 1,
        category: 'lobby',
        categoryLabel: 'Lobi & Informasi',
        description: 'Pusat resepsionis & ruang tunggu tamu sekolah.',
        hint: 'Dekat piala prestasi dan papan pengumuman lobi.',
        path: 'M 140 80 L 320 80 L 320 180 L 140 180 Z',
        pinPosition: { x: 230, y: 130 },
        isPopularCodSpot: true,
      },
      {
        id: 'ruang-guru-1',
        name: 'Ruang Guru & Tata Usaha',
        code: 'TU & GURU',
        floor: 1,
        category: 'facility',
        categoryLabel: 'Fasilitas Guru',
        description: 'Ruang kantor administrasi dan staff pengajar.',
        hint: 'Lantai 1 sayap kanan lobi.',
        path: 'M 330 80 L 480 80 L 480 180 L 330 180 Z',
        pinPosition: { x: 405, y: 130 },
        isPopularCodSpot: false,
      },
      {
        id: 'kelas-x-pplg1',
        name: 'Kelas X PPLG 1',
        code: 'X PPLG 1',
        floor: 1,
        category: 'class',
        categoryLabel: 'Ruang Teori',
        description: 'Ruang kelas teori pengembangan perangkat lunak.',
        hint: 'Lorong sayap kiri dekat tangga.',
        path: 'M 80 200 L 180 200 L 180 340 L 80 340 Z',
        pinPosition: { x: 130, y: 270 },
        isPopularCodSpot: false,
      },
      {
        id: 'kelas-x-pplg2',
        name: 'Kelas X PPLG 2',
        code: 'X PPLG 2',
        floor: 1,
        category: 'class',
        categoryLabel: 'Ruang Teori',
        description: 'Ruang kelas teori tingkat dasar.',
        hint: 'Lorong sayap kiri dekat toilet siswa.',
        path: 'M 80 350 L 180 350 L 180 500 L 80 500 Z',
        pinPosition: { x: 130, y: 425 },
        isPopularCodSpot: false,
      },
      {
        id: 'koperasi-sekolah',
        name: 'Koperasi & ATK Siswa',
        code: 'KOPERASI',
        floor: 1,
        category: 'facility',
        categoryLabel: 'Belanja & Cetak',
        description: 'Menjual perlengkapan seragam, fotokopi, dan ATK.',
        hint: 'Tepat di samping area masuk kantin.',
        path: 'M 260 480 L 340 480 L 340 530 L 260 530 Z',
        pinPosition: { x: 300, y: 505 },
        isPopularCodSpot: true,
      },
      {
        id: 'ruang-bimbingan-konseling',
        name: 'Ruang BK & UKS',
        code: 'BK & UKS',
        floor: 1,
        category: 'facility',
        categoryLabel: 'Layanan Siswa',
        description: 'Ruang bimbingan konseling dan unit kesehatan sekolah.',
        hint: 'Sayap kanan dekat koridor belakang.',
        path: 'M 350 320 L 480 320 L 480 440 L 350 440 Z',
        pinPosition: { x: 415, y: 380 },
        isPopularCodSpot: false,
      },
      {
        id: 'gazebo-lapangan',
        name: 'Gazebo Taman Lapangan',
        code: 'GAZEBO',
        floor: 1,
        category: 'outdoor',
        categoryLabel: 'Taman & Gazebo',
        description: 'Area duduk santai terbuka di pinggir lapangan hijau.',
        hint: 'Di bawah pohon rindang samping lapangan basket.',
        path: 'M 500 200 L 620 200 L 620 320 L 500 320 Z',
        pinPosition: { x: 560, y: 260 },
        isPopularCodSpot: true,
      },
    ],
  },
  {
    floor: 2,
    name: 'Lantai 2',
    subtitle: 'Laboratorium Komputer PPLG, DKV & Perpustakaan',
    features: [
      { id: 'atrium-2', type: 'atrium', x: 230, y: 260, radius: 24, label: 'Void Atrium', floor: 2 },
    ],
    rooms: [
      {
        id: 'lab-pplg-1',
        name: 'Laboratorium Software RPL / PPLG 1',
        code: 'LAB RPL 1',
        floor: 2,
        category: 'lab',
        categoryLabel: 'Lab Komputer',
        description: 'Lab komputer spesifikasi tinggi untuk coding & web dev.',
        hint: 'Dekat tangga utama lantai 2, pintu kaca biru.',
        path: 'M 140 80 L 320 80 L 320 180 L 140 180 Z',
        pinPosition: { x: 230, y: 130 },
        isPopularCodSpot: true,
      },
      {
        id: 'lab-pplg-2',
        name: 'Laboratorium Software RPL / PPLG 2',
        code: 'LAB RPL 2',
        floor: 2,
        category: 'lab',
        categoryLabel: 'Lab Komputer',
        description: 'Lab pengembangan mobile app & cloud computing.',
        hint: 'Sebelah Lab RPL 1.',
        path: 'M 330 80 L 480 80 L 480 180 L 330 180 Z',
        pinPosition: { x: 405, y: 130 },
        isPopularCodSpot: true,
      },
      {
        id: 'lab-dkv',
        name: 'Studio Desain & Animasi DKV',
        code: 'STUDIO DKV',
        floor: 2,
        category: 'lab',
        categoryLabel: 'Studio Kreatif',
        description: 'Lab iMac & drawing tablet untuk desain grafis.',
        hint: 'Sayap kiri lantai 2, depan ruang server.',
        path: 'M 80 200 L 180 200 L 180 380 L 80 380 Z',
        pinPosition: { x: 130, y: 290 },
        isPopularCodSpot: true,
      },
      {
        id: 'perpustakaan',
        name: 'Perpustakaan Digital SMKN 8',
        code: 'PERPUS',
        floor: 2,
        category: 'facility',
        categoryLabel: 'Perpustakaan & Belajar',
        description: 'Ruang baca ber-AC yang tenang dengan koleksi buku lengkap.',
        hint: 'Di seberang void atrium lantai 2.',
        path: 'M 350 320 L 520 320 L 520 500 L 350 500 Z',
        pinPosition: { x: 435, y: 410 },
        isPopularCodSpot: true,
      },
      {
        id: 'ruang-audio-visual',
        name: 'Ruang Audio Visual / Mini Theater',
        code: 'AUDIO VISUAL',
        floor: 2,
        category: 'facility',
        categoryLabel: 'Ruang Presentasi',
        description: 'Tempat pemutaran film & presentasi karya siswa.',
        hint: 'Sayap belakang lantai 2.',
        path: 'M 140 540 L 410 540 L 410 740 L 140 740 Z',
        pinPosition: { x: 275, y: 640 },
        isPopularCodSpot: false,
      },
    ],
  },
  {
    floor: 3,
    name: 'Lantai 3',
    subtitle: 'Ruang Multimedia, Aula Utama & Rooftop',
    features: [
      { id: 'atrium-3', type: 'atrium', x: 230, y: 260, radius: 24, label: 'Void Atrium', floor: 3 },
    ],
    rooms: [
      {
        id: 'aula-utama',
        name: 'Aula Serbaguna SMKN 8',
        code: 'AULA UTAMA',
        floor: 3,
        category: 'facility',
        categoryLabel: 'Aula & Event',
        description: 'Aula besar untuk seminar, pameran karya, dan pentas seni.',
        hint: 'Pintu ganda utama lantai 3.',
        path: 'M 140 80 L 480 80 L 480 260 L 140 260 Z',
        pinPosition: { x: 310, y: 170 },
        isPopularCodSpot: true,
      },
      {
        id: 'lab-jaringan-tkj',
        name: 'Laboratorium Jaringan & Server',
        code: 'LAB JARINGAN',
        floor: 3,
        category: 'lab',
        categoryLabel: 'Lab Hardware & IoT',
        description: 'Ruang praktikum mikrotik, router, dan fiber optic.',
        hint: 'Sayap kiri lantai 3.',
        path: 'M 80 280 L 180 280 L 180 480 L 80 480 Z',
        pinPosition: { x: 130, y: 380 },
        isPopularCodSpot: false,
      },
      {
        id: 'rooftop-greenhouse',
        name: 'Taman Atap & Green House',
        code: 'ROOFTOP',
        floor: 3,
        category: 'outdoor',
        categoryLabel: 'Rooftop & Udara Terbuka',
        description: 'Area santai terbuka di lantai teratas dengan pemandangan kota.',
        hint: 'Pintu keluar lorong belakang lantai 3.',
        path: 'M 200 480 L 480 480 L 480 720 L 200 720 Z',
        pinPosition: { x: 340, y: 600 },
        isPopularCodSpot: true,
      },
    ],
  },
];
