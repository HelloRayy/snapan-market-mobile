/// Data types and presets for the Create Post & Thread feature
/// Matching Web `src/ui/components/marketplace/create-post/types.ts`

enum PostMode {
  thread,
  product;

  String get label {
    switch (this) {
      case PostMode.thread:
        return 'Utas';
      case PostMode.product:
        return 'Jual Barang';
    }
  }
}

class TopicOption {
  final String id;
  final String name;
  final bool isOfficial;
  final String? subtitle;
  final String? iconType;

  const TopicOption({
    required this.id,
    required this.name,
    this.isOfficial = false,
    this.subtitle,
    this.iconType,
  });
}

const List<TopicOption> kPresetTopics = [
  TopicOption(
    id: 't-1',
    name: 'frontend',
    isOfficial: true,
    iconType: 'threads',
    subtitle: '1.2M anggota · 220 postingan baru',
  ),
  TopicOption(
    id: 't-2',
    name: 'PJBL',
    isOfficial: true,
    iconType: 'party-popper',
    subtitle: 'Project Based Learning SMKN 8',
  ),
  TopicOption(
    id: 't-3',
    name: 'JajananKantin',
    isOfficial: true,
    iconType: 'threads',
    subtitle: 'Kantin Sekolah & Snack',
  ),
  TopicOption(
    id: 't-4',
    name: 'Github',
    isOfficial: false,
    subtitle: '92 postingan baru',
  ),
  TopicOption(
    id: 't-5',
    name: 'PrelovedOutfit',
    isOfficial: false,
    subtitle: '136 postingan baru',
  ),
];

class SchoolPlace {
  final String id;
  final String name;
  final String subtitle;
  final String distance;

  const SchoolPlace({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.distance,
  });
}

const List<SchoolPlace> kRichSchoolPlaces = [
  SchoolPlace(
    id: 'p1',
    name: 'Lab PPLG 1 & 2',
    subtitle: 'Gedung Kejuruan Lantai 2 · SMKN 8',
    distance: 'Sekitar sini',
  ),
  SchoolPlace(
    id: 'p2',
    name: 'Kantin Belakang SMKN 8',
    subtitle: 'Area Pujasera & Kuliner Siswa',
    distance: '50 m',
  ),
  SchoolPlace(
    id: 'p3',
    name: 'Lapangan Utama SMKN 8',
    subtitle: 'Area Olahraga & Lapangan Upacara',
    distance: '30 m',
  ),
  SchoolPlace(
    id: 'p4',
    name: 'Perpustakaan Sekolah',
    subtitle: 'Gedung Utama Lantai 1',
    distance: '40 m',
  ),
  SchoolPlace(
    id: 'p5',
    name: 'Lobi Depan & Ruang OSIS',
    subtitle: 'Gerbang Utama & Pos Keamanan',
    distance: '80 m',
  ),
  SchoolPlace(
    id: 'p6',
    name: 'Studio DKV',
    subtitle: 'Gedung Kreatif Lantai 2',
    distance: '60 m',
  ),
  SchoolPlace(
    id: 'p7',
    name: 'Bengkel TJKT / Jaringan',
    subtitle: 'Gedung Teknologi Barat',
    distance: '70 m',
  ),
  SchoolPlace(
    id: 'p8',
    name: 'Musholla As-Salam SMKN 8',
    subtitle: 'Tempat Ibadah Sekolah',
    distance: '90 m',
  ),
];

const List<String> kPresetEmojis = [
  '🔥',
  '😍',
  '🙌',
  '✨',
  '⚡',
  '💯',
  '❤️',
  '👏',
  '🚀',
  '💡',
  '🍱',
  '💻'
];

class PresetGif {
  final String id;
  final String title;
  final String url;

  const PresetGif({
    required this.id,
    required this.title,
    required this.url,
  });
}

const List<PresetGif> kPresetGifs = [
  PresetGif(
    id: 'g1',
    title: 'Coding Cat',
    url: 'https://images.unsplash.com/photo-1534972195531-a756b1146245?w=400&q=80',
  ),
  PresetGif(
    id: 'g2',
    title: 'Let\'s Go',
    url: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=400&q=80',
  ),
  PresetGif(
    id: 'g3',
    title: 'Yummy Food',
    url: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400&q=80',
  ),
  PresetGif(
    id: 'g4',
    title: 'Deal Success',
    url: 'https://images.unsplash.com/photo-1556742049-0a67e55722c6?w=400&q=80',
  ),
];

class SubThreadItem {
  final String id;
  String caption;
  List<String> images;

  SubThreadItem({
    required this.id,
    this.caption = '',
    List<String>? images,
  }) : images = images ?? [];
}
