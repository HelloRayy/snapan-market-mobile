export interface TopicOption {
  id: string;
  name: string;
  isOfficial: boolean;
  icon?: 'threads' | 'party-popper';
  subtitle?: string;
}

export const PRESET_TOPICS: TopicOption[] = [
  { id: 't-1', name: 'frontend', isOfficial: true, icon: 'threads', subtitle: '1.2M anggota · 220 postingan baru' },
  { id: 't-2', name: 'PJBL', isOfficial: true, icon: 'party-popper', subtitle: 'Project Based Learning SMKN 8' },
  { id: 't-3', name: 'JajananKantin', isOfficial: true, icon: 'threads', subtitle: 'Kantin Sekolah & Snack' },
  { id: 't-4', name: 'Github', isOfficial: false, subtitle: '92 postingan baru' },
  { id: 't-5', name: 'PrelovedOutfit', isOfficial: false, subtitle: '136 postingan baru' },
];

export interface SchoolPlace {
  id: string;
  name: string;
  subtitle: string;
  distance: string;
}

export const RICH_SCHOOL_PLACES: SchoolPlace[] = [
  { id: 'p1', name: 'Lab PPLG 1 & 2', subtitle: 'Gedung Kejuruan Lantai 2 · SMKN 8 Semarang', distance: 'Sekitar sini' },
  { id: 'p2', name: 'Kantin Belakang SMKN 8', subtitle: 'Area Pujasera & Kuliner Siswa', distance: '50 m' },
  { id: 'p3', name: 'Lapangan Utama SMKN 8', subtitle: 'Area Olahraga & Lapangan Upacara', distance: '30 m' },
  { id: 'p4', name: 'Perpustakaan Sekolah', subtitle: 'Gedung Utama Lantai 1', distance: '40 m' },
  { id: 'p5', name: 'Lobi Depan & Ruang OSIS', subtitle: 'Gerbang Utama & Pos Keamanan', distance: '80 m' },
  { id: 'p6', name: 'Studio DKV', subtitle: 'Gedung Kreatif Lantai 2', distance: '60 m' },
  { id: 'p7', name: 'Bengkel TJKT / Jaringan', subtitle: 'Gedung Teknologi Barat', distance: '70 m' },
  { id: 'p8', name: 'Musholla As-Salam SMKN 8', subtitle: 'Tempat Ibadah Sekolah', distance: '90 m' },
];

export const PRESET_EMOJIS = ['🔥', '😍', '🙌', '✨', '⚡', '💯', '❤️', '👏', '🚀', '💡', '🍱', '💻'];

export const PRESET_GIFS = [
  { id: 'g1', title: 'Coding Cat', url: 'https://images.unsplash.com/photo-1534972195531-a756b1146245?w=400&q=80' },
  { id: 'g2', title: 'Let\'s Go', url: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=400&q=80' },
  { id: 'g3', title: 'Yummy Food', url: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400&q=80' },
  { id: 'g4', title: 'Deal Success', url: 'https://images.unsplash.com/photo-1556742049-0a67e55722c6?w=400&q=80' },
];
