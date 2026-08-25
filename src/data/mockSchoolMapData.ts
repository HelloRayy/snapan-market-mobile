export interface RoomZone {
  id: string;
  name: string;
  code: string;
  buildingName: string;
  floor: number; // 1, 2, or 3
  category: 'canteen' | 'lab' | 'class' | 'lobby' | 'outdoor' | 'facility';
  categoryLabel: string;
  description: string;
  hint: string;
  path: string; // SVG polygon/path data
  pinPosition: { x: number; y: number };
  isPopularCodSpot: boolean;
}

export interface BuildingOutline {
  id: string;
  name: string;
  path: string;
  labelPosition?: { x: number; y: number };
}

export interface FloorData {
  floor: number;
  name: string;
  subtitle: string;
  rooms: RoomZone[];
}

export const SCHOOL_BUILDING_OUTLINES: BuildingOutline[] = [
  // 1. Gedung Besar Berbentuk L (L-Shaped Building)
  {
    id: 'gedung-l',
    name: 'Gedung Utama (L-Wing)',
    path: 'M 112 85 L 910 25 L 910 162 L 272 208 L 274 620 L 132 630 Z',
    labelPosition: { x: 500, y: 110 },
  },
  // 2. Gedung Tengah (Central Building / Lab)
  {
    id: 'gedung-tengah',
    name: 'Gedung Vokasi & Lab',
    path: 'M 324 435 L 658 418 L 660 522 L 328 540 Z',
    labelPosition: { x: 490, y: 480 },
  },
  // 3. Gedung Kanan (Right Wing / Aula)
  {
    id: 'gedung-kanan',
    name: 'Gedung Aula & Serbaguna',
    path: 'M 678 395 L 870 375 L 884 582 L 688 604 Z',
    labelPosition: { x: 780, y: 490 },
  },
  // 4. Bangunan Miring Bawah Kiri (Kantin & Pujasera)
  {
    id: 'gedung-bawah-1',
    name: 'Kantin & Pujasera',
    path: 'M 560 690 L 630 630 L 760 720 L 690 780 Z',
    labelPosition: { x: 660, y: 705 },
  },
  // 5. Bangunan Miring Bawah Kanan (Gazebo & Koperasi)
  {
    id: 'gedung-bawah-2',
    name: 'Gazebo & Koperasi',
    path: 'M 755 640 L 825 580 L 915 635 L 845 700 Z',
    labelPosition: { x: 835, y: 640 },
  },
];

export const SCHOOL_FLOORS: FloorData[] = [
  {
    floor: 1,
    name: 'Lantai 1',
    subtitle: 'Lobi Utama, Kantin, Lab DKV & Ruang Guru',
    rooms: [
      // 1. Kantin Utama (Paling Populer COD)
      {
        id: 'kantin-utama',
        name: 'Kantin Utama & Pujasera',
        code: 'KANTIN',
        buildingName: 'Area Pujasera Belakang',
        floor: 1,
        category: 'canteen',
        categoryLabel: 'Kantin & Makanan',
        description: 'Pusat jajanan & meja makan outdoor siswa SMKN 8 Jakarta.',
        hint: 'Titik COD paling ramai & mudah ditemukan saat istirahat. Dekat stan minuman jus.',
        path: 'M 560 690 L 630 630 L 760 720 L 690 780 Z',
        pinPosition: { x: 660, y: 705 },
        isPopularCodSpot: true,
      },
      // 2. Lobi Depan Gedung A
      {
        id: 'lobi-utama',
        name: 'Lobi Depan Gedung Utama',
        code: 'LOBI A',
        buildingName: 'Gedung Utama (Sayap Atas)',
        floor: 1,
        category: 'lobby',
        categoryLabel: 'Lobi & Informasi',
        description: 'Area resepsionis, etalase piala prestasi, dan ruang tunggu tamu.',
        hint: 'Dekat pintu masuk gerbang utama sekolah.',
        path: 'M 112 85 L 390 65 L 390 198 L 272 208 L 260 210 L 112 85 Z',
        pinPosition: { x: 250, y: 145 },
        isPopularCodSpot: true,
      },
      // 3. Ruang Guru & Tata Usaha
      {
        id: 'ruang-guru-tu',
        name: 'Ruang Guru & Tata Usaha',
        code: 'RUANG GURU',
        buildingName: 'Gedung Utama (Sayap Atas)',
        floor: 1,
        category: 'facility',
        categoryLabel: 'Fasilitas Guru',
        description: 'Kantor administrasi guru dan staff pengajar.',
        hint: 'Lantai 1 koridor tengah gedung utama.',
        path: 'M 390 65 L 660 45 L 660 180 L 390 198 Z',
        pinPosition: { x: 525, y: 125 },
        isPopularCodSpot: false,
      },
      // 4. Ruang Kepala Sekolah & Tamu
      {
        id: 'ruang-kepsek',
        name: 'Ruang Kepala Sekolah & Mitra',
        code: 'KEPSEK',
        buildingName: 'Gedung Utama (Sayap Kanan Atas)',
        floor: 1,
        category: 'facility',
        categoryLabel: 'Kantor Pimpinan',
        description: 'Ruang pimpinan sekolah dan pertemuan mitra industri.',
        hint: 'Ujung kanan gedung utama lantai 1.',
        path: 'M 660 45 L 910 25 L 910 162 L 660 180 Z',
        pinPosition: { x: 785, y: 105 },
        isPopularCodSpot: false,
      },
      // 5. Studio Desain & Animasi DKV (Gedung Tengah)
      {
        id: 'studio-dkv',
        name: 'Studio Desain & Animasi DKV',
        code: 'STUDIO DKV',
        buildingName: 'Gedung Vokasi Tengah',
        floor: 1,
        category: 'lab',
        categoryLabel: 'Studio Kreatif',
        description: 'Studio praktikum iMac dan drawing tablet jurusan DKV.',
        hint: 'Gedung tengah lantai 1, pintu kaca lorong depan.',
        path: 'M 324 435 L 490 425 L 492 530 L 328 540 Z',
        pinPosition: { x: 408, y: 482 },
        isPopularCodSpot: true,
      },
      // 6. Ruang Praktik Kerja Industri (Gedung Tengah Kanan)
      {
        id: 'ruang-prakerin',
        name: 'Ruang Prakerin & Karir Siswa',
        code: 'BKK / PRAKERIN',
        buildingName: 'Gedung Vokasi Tengah',
        floor: 1,
        category: 'facility',
        categoryLabel: 'Layanan Karir',
        description: 'Pusat informasi magang, PKL, dan bursa kerja khusus.',
        hint: 'Sebelah studio DKV gedung tengah.',
        path: 'M 490 425 L 658 418 L 660 522 L 492 530 Z',
        pinPosition: { x: 575, y: 475 },
        isPopularCodSpot: false,
      },
      // 7. Aula Utama & Lapangan Indoor (Gedung Kanan)
      {
        id: 'aula-serbaguna',
        name: 'Aula Utama & Gedung Serbaguna',
        code: 'AULA SMKN 8',
        buildingName: 'Gedung Aula Kanan',
        floor: 1,
        category: 'facility',
        categoryLabel: 'Aula & Acara',
        description: 'Gedung pertemuan besar untuk pameran karya, seminar, dan eskul.',
        hint: 'Gedung sayap kanan dekat pintu lapangan.',
        path: 'M 678 395 L 870 375 L 884 582 L 688 604 Z',
        pinPosition: { x: 780, y: 490 },
        isPopularCodSpot: true,
      },
      // 8. Gazebo Taman & Lapangan (Pojok Kanan Bawah)
      {
        id: 'gazebo-taman',
        name: 'Gazebo Taman & Koperasi Siswa',
        code: 'GAZEBO',
        buildingName: 'Area Luar / Taman',
        floor: 1,
        category: 'outdoor',
        categoryLabel: 'Taman Santai',
        description: 'Area duduk rindang dan stan koperasi perlengkapan siswa.',
        hint: 'Di bawah pohon rindang samping lapangan basket.',
        path: 'M 755 640 L 825 580 L 915 635 L 845 700 Z',
        pinPosition: { x: 835, y: 640 },
        isPopularCodSpot: true,
      },
      // 9. Kelas X & XI PPLG 1 (Sayap Kiri Gedung L)
      {
        id: 'kelas-x-pplg',
        name: 'Ruang Kelas X & XI PPLG',
        code: 'KELAS PPLG',
        buildingName: 'Gedung Utama (Sayap Kiri)',
        floor: 1,
        category: 'class',
        categoryLabel: 'Ruang Teori',
        description: 'Ruang kelas teori pengembangan perangkat lunak & gim.',
        hint: 'Lorong sayap kiri dekat tangga.',
        path: 'M 112 215 L 268 215 L 270 415 L 120 415 Z',
        pinPosition: { x: 192, y: 315 },
        isPopularCodSpot: false,
      },
      // 10. Perpustakaan & Ruang Baca (Sayap Kiri Bawah)
      {
        id: 'perpustakaan-sekolah',
        name: 'Perpustakaan & Ruang Baca',
        code: 'PERPUSTAKAAN',
        buildingName: 'Gedung Utama (Sayap Kiri)',
        floor: 1,
        category: 'facility',
        categoryLabel: 'Belajar & Literasi',
        description: 'Ruang baca ber-AC yang nyaman dengan akses internet cepat.',
        hint: 'Ujung lorong sayap kiri lantai 1.',
        path: 'M 120 425 L 270 425 L 274 620 L 132 630 Z',
        pinPosition: { x: 200, y: 525 },
        isPopularCodSpot: true,
      },
    ],
  },
  {
    floor: 2,
    name: 'Lantai 2',
    subtitle: 'Lab Software RPL 1 & 2, Server Room & Ruang Multimedia',
    rooms: [
      // 1. Lab Software RPL 1 (Gedung Tengah Lantai 2)
      {
        id: 'lab-rpl-1',
        name: 'Laboratorium Software RPL / PPLG 1',
        code: 'LAB RPL 1',
        buildingName: 'Gedung Vokasi Tengah (Lt. 2)',
        floor: 2,
        category: 'lab',
        categoryLabel: 'Lab Komputer',
        description: 'Lab komputer spesifikasi tinggi untuk web & mobile app dev.',
        hint: 'Gedung tengah lantai 2, pintu kaca biru depan tangga.',
        path: 'M 324 435 L 490 425 L 492 530 L 328 540 Z',
        pinPosition: { x: 408, y: 482 },
        isPopularCodSpot: true,
      },
      // 2. Lab Software RPL 2 (Gedung Tengah Lantai 2 Kanan)
      {
        id: 'lab-rpl-2',
        name: 'Laboratorium Software RPL / PPLG 2',
        code: 'LAB RPL 2',
        buildingName: 'Gedung Vokasi Tengah (Lt. 2)',
        floor: 2,
        category: 'lab',
        categoryLabel: 'Lab Komputer',
        description: 'Lab praktikum database, API backend, dan cloud server.',
        hint: 'Sebelah Lab RPL 1 di lantai 2.',
        path: 'M 490 425 L 658 418 L 660 522 L 492 530 Z',
        pinPosition: { x: 575, y: 475 },
        isPopularCodSpot: true,
      },
      // 3. Ruang Server & IT Support (Gedung Utama Atas Lt. 2)
      {
        id: 'ruang-server',
        name: 'Pusat Server & Network Operations',
        code: 'SERVER ROOM',
        buildingName: 'Gedung Utama (Lt. 2)',
        floor: 2,
        category: 'facility',
        categoryLabel: 'Infrastruktur IT',
        description: 'Pusat jaringan internet dan server lokal SMKN 8 Jakarta.',
        hint: 'Lantai 2 di atas lobi utama.',
        path: 'M 112 85 L 390 65 L 390 198 L 272 208 L 260 210 L 112 85 Z',
        pinPosition: { x: 250, y: 145 },
        isPopularCodSpot: false,
      },
      // 4. Ruang Multimedia & Podcast (Gedung Utama Kanan Lt. 2)
      {
        id: 'studio-podcast',
        name: 'Studio Podcast & Broadcast SMKN 8',
        code: 'BROADCAST',
        buildingName: 'Gedung Utama (Lt. 2)',
        floor: 2,
        category: 'lab',
        categoryLabel: 'Studio Rekaman',
        description: 'Studio kedap suara untuk rekaman podcast dan video sekolah.',
        hint: 'Lantai 2 gedung utama sayap kanan.',
        path: 'M 390 65 L 910 25 L 910 162 L 390 198 Z',
        pinPosition: { x: 650, y: 110 },
        isPopularCodSpot: true,
      },
      // 5. Tribun Atas Aula (Gedung Kanan Lt. 2)
      {
        id: 'tribun-aula',
        name: 'Balkon & Tribun Aula Serbaguna',
        code: 'TRIBUN AULA',
        buildingName: 'Gedung Aula Kanan (Lt. 2)',
        floor: 2,
        category: 'facility',
        categoryLabel: 'Tribun Acara',
        description: 'Area penonton atas untuk pementasan seni dan wisuda.',
        hint: 'Akses tangga samping aula.',
        path: 'M 678 395 L 870 375 L 884 582 L 688 604 Z',
        pinPosition: { x: 780, y: 490 },
        isPopularCodSpot: false,
      },
      // 6. Lab Perakitan & Hardware (Sayap Kiri Lt. 2)
      {
        id: 'lab-hardware',
        name: 'Laboratorium Hardware & Mikrokontroler',
        code: 'LAB HARDWARE',
        buildingName: 'Gedung Utama Sayap Kiri (Lt. 2)',
        floor: 2,
        category: 'lab',
        categoryLabel: 'Lab IoT & Robotik',
        description: 'Ruang solder, perakitan PC, dan pemrograman Arduino/IoT.',
        hint: 'Sayap kiri lantai 2.',
        path: 'M 112 215 L 274 215 L 274 620 L 132 630 Z',
        pinPosition: { x: 195, y: 420 },
        isPopularCodSpot: false,
      },
    ],
  },
];
