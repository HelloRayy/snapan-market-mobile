export interface RoomZone {
  id: string;
  name: string;
  code: string;
  buildingName: string;
  floor: number; // 1 or 2
  category: 'canteen' | 'lab' | 'class' | 'lobby' | 'outdoor' | 'facility';
  categoryLabel: string;
  description: string;
  hint: string;
  path: string; // SVG polygon/path data
  pinPosition: { x: number; y: number };
  isPopularCodSpot: boolean;
  height?: number; // 3D wall height
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
  // 1. Gedung Utama L-Wing
  {
    id: 'gedung-l',
    name: 'Gedung Utama (L-Wing)',
    path: 'M 112 85 L 910 25 L 910 162 L 272 208 L 274 620 L 132 630 Z',
    labelPosition: { x: 500, y: 110 },
  },
  // 2. Gedung Aula Tengah (Limasan Roof)
  {
    id: 'gedung-tengah',
    name: 'Aula Utama & Indoor Center',
    path: 'M 324 435 L 658 418 L 660 522 L 328 540 Z',
    labelPosition: { x: 490, y: 480 },
  },
  // 3. Gedung Sayap Kanan (Studio DKV & Lab)
  {
    id: 'gedung-kanan',
    name: 'Gedung Vokasi & Studio DKV',
    path: 'M 678 395 L 870 375 L 884 582 L 688 604 Z',
    labelPosition: { x: 780, y: 490 },
  },
  // 4. Kantin & Pujasera Belakang
  {
    id: 'gedung-bawah-1',
    name: 'Kantin & Pujasera',
    path: 'M 560 690 L 630 630 L 760 720 L 690 780 Z',
    labelPosition: { x: 660, y: 705 },
  },
  // 5. Gazebo & Koperasi
  {
    id: 'gedung-bawah-2',
    name: 'Gazebo & Koperasi Siswa',
    path: 'M 755 640 L 825 580 L 915 635 L 845 700 Z',
    labelPosition: { x: 835, y: 640 },
  },
];

export const SCHOOL_FLOORS: FloorData[] = [
  {
    floor: 1,
    name: 'Lantai 1',
    subtitle: 'Lobi Utama, Kantin, Aula Limasan & Studio DKV',
    rooms: [
      // 1. Kantin Utama SMKN 8 (Spot COD Terfavorit)
      {
        id: 'kantin-utama',
        name: 'Kantin Utama & Pujasera Siswa',
        code: 'KANTIN',
        buildingName: 'Area Pujasera Belakang',
        floor: 1,
        category: 'canteen',
        categoryLabel: 'Kantin & Makanan',
        description: 'Pusat jajanan, minuman dingin, dan meja makan santai siswa SMKN 8 Semarang.',
        hint: 'Titik COD paling ramai & mudah ditemukan saat jam istirahat. Dekat stan jus & snack.',
        path: 'M 560 690 L 630 630 L 760 720 L 690 780 Z',
        pinPosition: { x: 660, y: 705 },
        isPopularCodSpot: true,
        height: 24,
      },
      // 2. Lobi Depan Gedung A (Jl. Pandanaran 2)
      {
        id: 'lobi-utama',
        name: 'Lobi Utama & Resepsionis',
        code: 'LOBI DEPAN',
        buildingName: 'Gedung Utama (Sayap Atas)',
        floor: 1,
        category: 'lobby',
        categoryLabel: 'Lobi & Informasi',
        description: 'Pusat informasi, etalase piala prestasi kejuruan, dan ruang tunggu tamu.',
        hint: 'Dekat pintu gerbang masuk utama dari Jl. Pandanaran 2.',
        path: 'M 112 85 L 390 65 L 390 198 L 272 208 L 260 210 L 112 85 Z',
        pinPosition: { x: 250, y: 145 },
        isPopularCodSpot: true,
        height: 32,
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
        description: 'Kantor administrasi pengajar, bimbingan siswa, dan absensi.',
        hint: 'Lantai 1 koridor tengah gedung utama.',
        path: 'M 390 65 L 660 45 L 660 180 L 390 198 Z',
        pinPosition: { x: 525, y: 125 },
        isPopularCodSpot: false,
        height: 32,
      },
      // 4. Ruang Kepala Sekolah & Tamu VIP
      {
        id: 'ruang-kepsek',
        name: 'Ruang Kepala Sekolah & Mitra Industri',
        code: 'KEPSEK',
        buildingName: 'Gedung Utama (Sayap Kanan Atas)',
        floor: 1,
        category: 'facility',
        categoryLabel: 'Kantor Pimpinan',
        description: 'Ruang pimpinan sekolah dan ruang kerjasama magang industri.',
        hint: 'Ujung kanan gedung utama lantai 1.',
        path: 'M 660 45 L 910 25 L 910 162 L 660 180 Z',
        pinPosition: { x: 785, y: 105 },
        isPopularCodSpot: false,
        height: 32,
      },
      // 5. Aula Utama Tengah (Gedung Limasan)
      {
        id: 'aula-limasan-tengah',
        name: 'Gedung Aula Serbaguna (Limasan)',
        code: 'AULA UTAMA',
        buildingName: 'Gedung Aula Tengah',
        floor: 1,
        category: 'facility',
        categoryLabel: 'Aula & Pertemuan',
        description: 'Gedung megah beratap limasan untuk pameran karya teknologi, wisuda, dan pentas seni.',
        hint: 'Gedung besar beratap limasan tepat di tengah area sekolah.',
        path: 'M 324 435 L 658 418 L 660 522 L 328 540 Z',
        pinPosition: { x: 490, y: 480 },
        isPopularCodSpot: true,
        height: 42,
      },
      // 6. Studio Desain & Animasi DKV (Gedung Sayap Kanan)
      {
        id: 'studio-dkv',
        name: 'Studio Animasi & Desain DKV',
        code: 'STUDIO DKV',
        buildingName: 'Gedung Vokasi Kanan',
        floor: 1,
        category: 'lab',
        categoryLabel: 'Studio Kreatif',
        description: 'Studio komputer workstation grafis, rendering 3D, dan drawing tablet.',
        hint: 'Gedung sayap kanan lantai 1, dekat tangga depan.',
        path: 'M 678 395 L 870 375 L 884 582 L 688 604 Z',
        pinPosition: { x: 780, y: 490 },
        isPopularCodSpot: true,
        height: 30,
      },
      // 7. Gazebo Taman & Koperasi Siswa
      {
        id: 'gazebo-taman',
        name: 'Gazebo Taman & Koperasi Siswa',
        code: 'GAZEBO TAMAN',
        buildingName: 'Area Taman Samping',
        floor: 1,
        category: 'outdoor',
        categoryLabel: 'Taman Santai',
        description: 'Area duduk rindang di samping lapangan dengan stan perlengkapan sekolah.',
        hint: 'Di bawah pepohonan rindang dekat lapangan olahraga.',
        path: 'M 755 640 L 825 580 L 915 635 L 845 700 Z',
        pinPosition: { x: 835, y: 640 },
        isPopularCodSpot: true,
        height: 18,
      },
      // 8. Kelas X & XI PPLG / Teori (Sayap Kiri Gedung L)
      {
        id: 'kelas-x-pplg',
        name: 'Ruang Kelas Teori X & XI PPLG',
        code: 'KELAS PPLG',
        buildingName: 'Gedung Utama (Sayap Kiri)',
        floor: 1,
        category: 'class',
        categoryLabel: 'Ruang Kelas',
        description: 'Ruang kelas teori Rekayasa Perangkat Lunak & Pengembangan Gim.',
        hint: 'Sayap kiri lantai 1 menghadap lapangan utama.',
        path: 'M 112 215 L 268 215 L 270 415 L 120 415 Z',
        pinPosition: { x: 192, y: 315 },
        isPopularCodSpot: false,
        height: 32,
      },
      // 9. Perpustakaan & Ruang Baca Digital (Sayap Kiri Bawah)
      {
        id: 'perpustakaan-sekolah',
        name: 'Perpustakaan & Ruang Baca Digital',
        code: 'PERPUSTAKAAN',
        buildingName: 'Gedung Utama (Sayap Kiri)',
        floor: 1,
        category: 'facility',
        categoryLabel: 'Belajar & Literasi',
        description: 'Ruang literasi modern ber-AC dengan e-library dan ruang diskusi.',
        hint: 'Ujung selatan koridor sayap kiri lantai 1.',
        path: 'M 120 425 L 270 425 L 274 620 L 132 630 Z',
        pinPosition: { x: 200, y: 525 },
        isPopularCodSpot: true,
        height: 32,
      },
    ],
  },
  {
    floor: 2,
    name: 'Lantai 2',
    subtitle: 'Lab Software RPL 1 & 2, Server Room & Ruang Multimedia',
    rooms: [
      // 1. Lab Software RPL / PPLG 1 (Gedung Utama Lt. 2)
      {
        id: 'lab-rpl-1',
        name: 'Laboratorium Software RPL 1 (Web & Mobile)',
        code: 'LAB RPL 1',
        buildingName: 'Gedung Utama Sayap Kiri (Lt. 2)',
        floor: 2,
        category: 'lab',
        categoryLabel: 'Lab Komputer',
        description: 'Lab praktikum coding React, Vite, Flutter, dan web development.',
        hint: 'Lantai 2 sayap kiri, pintu kaca biru depan tangga.',
        path: 'M 112 215 L 268 215 L 270 415 L 120 415 Z',
        pinPosition: { x: 192, y: 315 },
        isPopularCodSpot: true,
        height: 32,
      },
      // 2. Lab Software RPL / PPLG 2 (Gedung Utama Lt. 2 Bawah)
      {
        id: 'lab-rpl-2',
        name: 'Laboratorium Software RPL 2 (Database & Cloud)',
        code: 'LAB RPL 2',
        buildingName: 'Gedung Utama Sayap Kiri (Lt. 2)',
        floor: 2,
        category: 'lab',
        categoryLabel: 'Lab Komputer',
        description: 'Lab praktikum database PostgreSQL/Supabase, API, dan server.',
        hint: 'Sebelah Lab RPL 1 di lantai 2 sayap kiri.',
        path: 'M 120 425 L 270 425 L 274 620 L 132 630 Z',
        pinPosition: { x: 200, y: 525 },
        isPopularCodSpot: true,
        height: 32,
      },
      // 3. Pusat Server & NOC (Gedung Utama Atas Lt. 2)
      {
        id: 'ruang-server',
        name: 'Network Operations Center & Ruang Server',
        code: 'NOC / SERVER',
        buildingName: 'Gedung Utama Sayap Atas (Lt. 2)',
        floor: 2,
        category: 'facility',
        categoryLabel: 'Infrastruktur IT',
        description: 'Pusat router Mikrotik, switch Cisco, dan server fiber optik SMKN 8.',
        hint: 'Lantai 2 tepat di atas lobi depan.',
        path: 'M 112 85 L 390 65 L 390 198 L 272 208 L 260 210 L 112 85 Z',
        pinPosition: { x: 250, y: 145 },
        isPopularCodSpot: false,
        height: 32,
      },
      // 4. Studio Broadcast & Podcast (Sayap Kanan Lt. 2)
      {
        id: 'studio-podcast',
        name: 'Studio Broadcast & Podcast Sekolah',
        code: 'BROADCAST',
        buildingName: 'Gedung Vokasi Kanan (Lt. 2)',
        floor: 2,
        category: 'lab',
        categoryLabel: 'Studio Rekaman',
        description: 'Studio rekaman video berperedam suara dan greenscreen.',
        hint: 'Lantai 2 gedung sayap kanan.',
        path: 'M 678 395 L 870 375 L 884 582 L 688 604 Z',
        pinPosition: { x: 780, y: 490 },
        isPopularCodSpot: true,
        height: 30,
      },
    ],
  },
];
