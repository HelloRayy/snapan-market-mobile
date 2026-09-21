import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Backward-compatibility alias
const mockMarketPosts = kMockMarketPosts;

/// Realistic Mock Dataset for SMKN 8 Semarang feed (6 sequential parameter variations for visual audit)
const List<MarketPostModel> kMockMarketPosts = [
  // ===========================================================================
  // VARIASI 1: Teks Murni (Minimalis, tanpa gambar, tanpa topik, tanpa lokasi)
  // ===========================================================================
  MarketPostModel(
    id: 'post-var-1',
    postType: 'thread',
    seller: SellerModel(
      id: 'user-var-1',
      name: 'Raden Mas Bagus',
      avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80',
      classGroup: 'XII PPLG 2',
      isVerified: false,
      username: 'radenbagus',
    ),
    caption: 'Ada yang punya info kisi-kisi atau referensi materi buat UKK Kejuruan PPLG minggu depan? Terutama bagian arsitektur database migration dan integrasi Supabase Auth ke Flutter app. Mohon infonya ya guys! 🙏💻',
    images: [],
    likesCount: 42,
    commentsCount: 8,
    repostsCount: 3,
    timestamp: '10m',
    isLiked: false,
    comments: [
      PostCommentModel(
        id: 'comment-v1-1',
        postId: 'post-var-1',
        user: CommentUserModel(
          id: 'user-v1-2',
          name: 'Naufal Rizky',
          avatar: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=200&q=80',
          username: 'naufalrizky',
          classGroup: 'XII PPLG 1',
          isVerified: true,
        ),
        content: 'Bisa cek dokumentasi fe-to-be contract di docs repo kita bro, udah lengkap sama schema sql!',
        timestamp: '5m',
        likesCount: 6,
        isLiked: true,
        replies: [
          PostCommentModel(
            id: 'reply-v1-1',
            postId: 'post-var-1',
            user: CommentUserModel(
              id: 'user-ember',
              name: 'embercettembok',
              avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
              username: 'embercettembok',
              isVerified: false,
            ),
            content: 'Please jangan delete utas nya kak, belum kubaca semua komennya. 23.56 dah waktunya tidur, besok ku lanjut baca lagi. Sangat mendaging',
            timestamp: '9 jam',
            likesCount: 146,
            isLiked: false,
          ),
          PostCommentModel(
            id: 'reply-v1-2',
            postId: 'post-var-1',
            user: CommentUserModel(
              id: 'user-raditya',
              name: 'Raditya Rayhan',
              avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
              username: 'radityarayhannnn',
              classGroup: 'XII PPLG 1',
              isVerified: true,
            ),
            content: 'Siap kak tenang aja, utasnya disimpan permanen buat arsip belajar bareng!',
            timestamp: '8 jam',
            likesCount: 18,
            isLiked: true,
          ),
        ],
      ),
    ],
  ),

  // ===========================================================================
  // POST THREAD 2: 1:1 Web Sliced from @faizintifada/post/post-thread-2
  // ===========================================================================
  MarketPostModel(
    id: 'post-thread-2',
    postType: 'thread',
    seller: SellerModel(
      id: 'user-thread-2',
      name: 'Faiz Intifada',
      avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
      classGroup: 'XII DKV 2',
      isVerified: true,
      username: 'faizintifada',
    ),
    caption: 'Moodboard project PJBL semester ini akhirnya selesai! Menurut kalian color palette yang kiri atau kanan yang lebih aesthetic buat tema marketplace sekolah? 🎨🔥',
    images: [
      'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&q=80',
    ],
    topicTag: 'PJBL',
    isOfficialTopic: true,
    topicIcon: 'presentation',
    likesCount: 184,
    commentsCount: 36,
    repostsCount: 12,
    timestamp: '2j',
    isLiked: false,
    comments: [
      PostCommentModel(
        id: 'comment-thread-2-1',
        postId: 'post-thread-2',
        user: CommentUserModel(
          id: 'user-raditya',
          name: 'radityarayhannnn',
          avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
          username: 'radityarayhannnn',
          isVerified: true,
        ),
        content: 'hai bro',
        timestamp: 'Baru saja',
        likesCount: 0,
        isLiked: false,
        replies: [
          PostCommentModel(
            id: 'reply-thread-2-1',
            postId: 'post-thread-2',
            user: CommentUserModel(
              id: 'user-raditya',
              name: 'radityarayhannnn',
              avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
              username: 'radityarayhannnn',
              isVerified: true,
            ),
            content: 'whatsapp bro',
            timestamp: 'Baru saja',
            likesCount: 0,
            isLiked: false,
          ),
        ],
      ),
    ],
  ),

  // ===========================================================================
  // VARIASI 2: Teks + Topik Tag (#frontend dengan Threads Glyph)
  // ===========================================================================
  MarketPostModel(
    id: 'post-var-2',
    postType: 'thread',
    seller: SellerModel(
      id: 'user-var-2',
      name: 'Faiz Intifada',
      avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
      classGroup: 'XII DKV 2',
      isVerified: true,
      username: 'faizintifada',
    ),
    caption: 'Diskusi santai anak IT: menurut kalian mana styling workflow yang paling produktif buat UI Web PWA sekolah kita? Tailwind CSS v4 @theme tokens atau Vanilla CSS custom properties? Share pengalaman kalian di bawah! 🎨✨',
    images: [],
    topicTag: 'frontend',
    isOfficialTopic: true,
    topicIcon: 'threads',
    likesCount: 128,
    commentsCount: 24,
    repostsCount: 7,
    timestamp: '25m',
    isLiked: true,
    comments: [
      PostCommentModel(
        id: 'comment-v2-1',
        postId: 'post-var-2',
        user: CommentUserModel(
          id: 'user-v2-2',
          name: 'Raymond Chin',
          avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
          username: 'raymondchins',
          classGroup: 'XII PPLG 1',
          isVerified: true,
        ),
        content: 'Tailwind v4 jauh lebih cepet pas build time dan auto-generate CSS variable buat dark mode!',
        timestamp: '18m',
        likesCount: 12,
        isLiked: true,
      ),
    ],
  ),

  // ===========================================================================
  // VARIASI 3: Teks + Single Foto (Rasio 4:5, 18px rounded)
  // ===========================================================================
  MarketPostModel(
    id: 'post-var-3',
    postType: 'thread',
    seller: SellerModel(
      id: 'user-var-3',
      name: 'Sarah Amelia',
      avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
      classGroup: 'XI DKV 1',
      isVerified: true,
      username: 'sarahamelia',
    ),
    caption: 'Eksplorasi layout majalah dinding digital SMKN 8 Semarang semester ini sudah jadi! Gimana menurut kalian komposisi warna dan visual hierarchy-nya? Feedbacks are welcome! 📐✨',
    images: [
      'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?w=800&q=80',
    ],
    likesCount: 195,
    commentsCount: 14,
    repostsCount: 6,
    timestamp: '1j',
    isLiked: false,
  ),

  // ===========================================================================
  // VARIASI 4: Teks + Topik + Multi-Foto Carousel (2+ Foto Horizontal Edge-to-Edge)
  // ===========================================================================
  MarketPostModel(
    id: 'post-var-4',
    postType: 'thread',
    seller: SellerModel(
      id: 'user-var-4',
      name: 'Bima Arya',
      avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
      classGroup: 'XII DKV 1',
      isVerified: true,
      username: 'bimaarya',
    ),
    caption: 'Dokumentasi photoshoot behind-the-scene project PJBL pameran karya kejuruan SMKN 8. Geser ke kanan buat liat proses editing & color grading lengkapnya! 📸🎨🔥',
    images: [
      'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&q=80',
      'https://images.unsplash.com/photo-1581291518633-83b4ebd1d83e?w=800&q=80',
      'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&q=80',
    ],
    topicTag: 'PJBL',
    isOfficialTopic: true,
    topicIcon: 'presentation',
    likesCount: 312,
    commentsCount: 45,
    repostsCount: 19,
    timestamp: '2j',
    isLiked: true,
  ),

  // ===========================================================================
  // VARIASI 5: Produk Jualan Lengkap (Judul, Harga Rp, Stok, Kategori, Foto, Tag Titik COD SMKN 8)
  // ===========================================================================
  MarketPostModel(
    id: 'post-var-5',
    postType: 'product',
    title: 'Jasa Desain UI/UX & PWA Kilat',
    seller: SellerModel(
      id: 'user-var-5',
      name: 'Raymond Chin',
      avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
      classGroup: 'XII PPLG 1',
      isVerified: true,
      username: 'raymondchins',
    ),
    caption: 'Open order jasa pembuatan UI/UX & Engineering PWA responsive siap pakai untuk tugas akhir atau portfolio kejuruan. Siap COD & diskusi langsung di lab komputer! Slot terbatas.',
    price: 150000,
    originalPrice: 200000,
    category: 'Jasa DKV/PPLG',
    images: [
      'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&q=80',
      'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?w=800&q=80',
    ],
    stock: 5,
    locationTag: 'Lab Komputer PPLG 1 (Lt. 3)',
    topicTag: 'frontend',
    isOfficialTopic: true,
    topicIcon: 'threads',
    likesCount: 245,
    commentsCount: 18,
    repostsCount: 5,
    timestamp: '3j',
    isLiked: true,
  ),

  // ===========================================================================
  // VARIASI 6: Multi-Part Thread Utas (1/2 di Main Post & 2/2 di Thread Chain)
  // ===========================================================================
  MarketPostModel(
    id: 'post-var-6',
    postType: 'thread',
    seller: SellerModel(
      id: 'user-var-6',
      name: 'Ibu Kantin Sayang',
      avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
      classGroup: 'Kantin SMKN 8',
      isVerified: true,
      username: 'kantin_smkn8',
    ),
    caption: 'Menu spesial hari ini: Tahu Walik Renyah + Sambal Kecap Pedas Mantap Baru Matang! Tinggal 10 porsi lagi di Kantin Tengah. Pesan sekarang bisa diantar ke kelas pas istirahat ke-2! Simak kelanjutannya 🥟🔥',
    images: [
      'https://images.unsplash.com/photo-1541544741938-0af808871cc0?w=800&q=80',
    ],
    totalThreadParts: 2,
    likesCount: 89,
    commentsCount: 18,
    repostsCount: 4,
    timestamp: '15m',
    isLiked: true,
    threadChain: [
      ThreadChainItemModel(
        id: 'chain-v6-2',
        partNumber: 2,
        totalParts: 2,
        caption: 'Pemesanan sebelum jam 11:30 WIB bisa langsung diantar ke ruang kelas masing-masing pas istirahat ke-2 ya anak-anak! Pembayaran bisa tunai atau QRIS di tempat. (2/2) 🚀✨',
        images: [
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80',
        ],
        timestamp: '12m',
        likesCount: 38,
        commentsCount: 2,
        isLiked: false,
      ),
    ],
  ),
];
