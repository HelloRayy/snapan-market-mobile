import { MarketThreadItem } from '@/types/threadsFeed';

export const MOCK_THREADS_ITEMS: MarketThreadItem[] = [
  {
    id: 'thread-1',
    seller: {
      id: 'user-1',
      name: 'Raymond Chin',
      avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
      classGroup: 'XII PPLG 1',
      isVerified: true,
      username: 'raymondchins',
    },
    caption: 'Ada kenalan website designer / UI engineer yang bisa bikin landing page & PWA kilat? Comment portofolio & tawaran harganya ya :)',
    price: 150000,
    category: 'Jasa DKV/PPLG',
    images: [
      'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&q=80'
    ],
    stock: 5,
    locationTag: 'Lab Komputer PPLG',
    likesCount: 466,
    commentsCount: 287,
    repostsCount: 9,
    timestamp: '1j lalu',
    isLiked: true,
  },
  {
    id: 'thread-2',
    seller: {
      id: 'user-2',
      name: 'Faiz Intifada',
      avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
      classGroup: 'XII DKV 2',
      isVerified: true,
      username: 'faizintifada',
    },
    caption: 'Hadir mas! Open commission UI/UX & Design Engineering PWA responsive siap pakai. Portofolio lengkap bisa dicek langsung 🚀✨',
    price: 250000,
    originalPrice: 350000,
    category: 'Jasa DKV/PPLG',
    images: [
      'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&q=80'
    ],
    stock: 3,
    locationTag: 'Studio DKV Gedung B',
    likesCount: 124,
    commentsCount: 42,
    repostsCount: 15,
    timestamp: '2j lalu',
    isLiked: false,
  },
  {
    id: 'thread-3',
    seller: {
      id: 'user-3',
      name: 'Ibu Kantin Sayang',
      avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
      classGroup: 'Kantin SMKN 8',
      isVerified: true,
      username: 'kantin_smkn8',
    },
    caption: 'Tahu Walik Renyah + Sambal Kecap Pedas Mantap Baru Matang! Tinggal 10 porsi lagi di Kantin Tengah. Pesan sekarang bisa diantar ke kelas pas istirahat ke-2! 🥟🔥',
    price: 10000,
    originalPrice: 12000,
    category: 'Kantin',
    images: [
      'https://images.unsplash.com/photo-1541544741938-0af808871cc0?w=800&q=80'
    ],
    stock: 10,
    locationTag: 'Kantin Utama Depan Aula',
    likesCount: 89,
    commentsCount: 18,
    repostsCount: 4,
    timestamp: '15m lalu',
    isLiked: true,
  },
  {
    id: 'thread-4',
    seller: {
      id: 'user-4',
      name: 'Rian TJKT',
      avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
      classGroup: 'XI TJKT 3',
      isVerified: false,
      username: 'rian_tjkt',
    },
    caption: 'Preloved Oversized Blue Hoodie Katun Import tebal, kondisi 95% masih kayak baru! Dijual murah aja karena butuh uang buat beli RAM. COD langsung di parkiran belakang.',
    price: 85000,
    originalPrice: 190000,
    category: 'Fashion',
    images: [
      'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=800&q=80'
    ],
    stock: 1,
    locationTag: 'Parkiran Belakang TJKT',
    likesCount: 54,
    commentsCount: 12,
    repostsCount: 2,
    timestamp: '3j lalu',
    isLiked: false,
  },
  {
    id: 'thread-5',
    seller: {
      id: 'user-5',
      name: 'Bima Elektronik',
      avatar: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=200&q=80',
      classGroup: 'XII LK 1',
      isVerified: true,
      username: 'bima_lk',
    },
    caption: 'Headset Gaming TWS Latency Rendah (Anti Delay buat Mobile Legends/PUBG). Baterai awet 24 jam + Garansi toko sekolah 1 bulan 🎧⚡',
    price: 125000,
    originalPrice: 175000,
    category: 'Elektronik',
    images: [
      'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=800&q=80'
    ],
    stock: 7,
    locationTag: 'Bengkel Listrik & Elektronika',
    likesCount: 142,
    commentsCount: 31,
    repostsCount: 8,
    timestamp: '5j lalu',
    isLiked: false,
  }
];
