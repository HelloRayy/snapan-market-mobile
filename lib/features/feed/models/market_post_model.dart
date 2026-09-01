typedef MarketPost = MarketPostModel;
const mockMarketPosts = kMockMarketPosts;
import 'package:flutter/foundation.dart';

/// Model representing a seller or author of a post
@immutable
class SellerModel {
  final String id;
  final String name;
  final String? username;
  final String avatar;
  final String classGroup;
  final bool isVerified;

  const SellerModel({
    required this.id,
    required this.name,
    this.username,
    required this.avatar,
    required this.classGroup,
    this.isVerified = false,
  });

  SellerModel copyWith({
    String? id,
    String? name,
    String? username,
    String? avatar,
    String? classGroup,
    bool? isVerified,
  }) {
    return SellerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      classGroup: classGroup ?? this.classGroup,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SellerModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          username == other.username &&
          avatar == other.avatar &&
          classGroup == other.classGroup &&
          isVerified == other.isVerified;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      username.hashCode ^
      avatar.hashCode ^
      classGroup.hashCode ^
      isVerified.hashCode;
}

/// Model representing an author continuation item in a multi-part thread (e.g., 2/2)
@immutable
class ThreadChainItemModel {
  final String id;
  final int partNumber;
  final int totalParts;
  final String caption;
  final List<String> images;
  final String timestamp;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;

  const ThreadChainItemModel({
    required this.id,
    required this.partNumber,
    required this.totalParts,
    required this.caption,
    this.images = const [],
    this.timestamp = 'Baru saja',
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
  });

  ThreadChainItemModel copyWith({
    String? id,
    int? partNumber,
    int? totalParts,
    String? caption,
    List<String>? images,
    String? timestamp,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
  }) {
    return ThreadChainItemModel(
      id: id ?? this.id,
      partNumber: partNumber ?? this.partNumber,
      totalParts: totalParts ?? this.totalParts,
      caption: caption ?? this.caption,
      images: images ?? this.images,
      timestamp: timestamp ?? this.timestamp,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

/// Model representing a user commenting on a thread or product
@immutable
class CommentUserModel {
  final String id;
  final String name;
  final String avatar;
  final String? username;
  final String? classGroup;
  final bool isVerified;
  final bool isAuthor;

  const CommentUserModel({
    required this.id,
    required this.name,
    required this.avatar,
    this.username,
    this.classGroup,
    this.isVerified = false,
    this.isAuthor = false,
  });
}

/// Model representing a comment and its nested replies on a post
@immutable
class PostCommentModel {
  final String id;
  final String postId;
  final CommentUserModel user;
  final String content;
  final List<String> images;
  final int? threadPart;
  final int? totalParts;
  final String timestamp;
  final int likesCount;
  final bool isLiked;
  final List<PostCommentModel> replies;

  const PostCommentModel({
    required this.id,
    required this.postId,
    required this.user,
    required this.content,
    this.images = const [],
    this.threadPart,
    this.totalParts,
    required this.timestamp,
    this.likesCount = 0,
    this.isLiked = false,
    this.replies = const [],
  });

  PostCommentModel copyWith({
    String? id,
    String? postId,
    CommentUserModel? user,
    String? content,
    List<String>? images,
    int? threadPart,
    int? totalParts,
    String? timestamp,
    int? likesCount,
    bool? isLiked,
    List<PostCommentModel>? replies,
  }) {
    return PostCommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      user: user ?? this.user,
      content: content ?? this.content,
      images: images ?? this.images,
      threadPart: threadPart ?? this.threadPart,
      totalParts: totalParts ?? this.totalParts,
      timestamp: timestamp ?? this.timestamp,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      replies: replies ?? this.replies,
    );
  }
}

/// Model representing a feed item (community thread or market product post)
@immutable
class MarketPostModel {
  final String id;
  final String postType; // 'thread' | 'product'
  final SellerModel seller;
  final String caption;
  final List<String> images;
  final String? title;
  final String? topicTag;
  final bool isOfficialTopic;
  final String? topicIcon; // 'threads' | 'presentation' | 'party-popper'
  final int? totalThreadParts;
  final String? locationTag;
  final int? price;
  final int? originalPrice;
  final int? stock;
  final String? category;
  final int likesCount;
  final int commentsCount;
  final int repostsCount;
  final bool isLiked;
  final bool isReposted;
  final bool isSaved;
  final String timestamp;
  final List<ThreadChainItemModel> threadChain;
  final List<PostCommentModel> comments;

  const MarketPostModel({
    required this.id,
    this.postType = 'thread',
    required this.seller,
    required this.caption,
    this.images = const [],
    this.title,
    this.topicTag,
    this.isOfficialTopic = false,
    this.topicIcon,
    this.totalThreadParts,
    this.locationTag,
    this.price,
    this.originalPrice,
    this.stock,
    this.category,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.repostsCount = 0,
    this.isLiked = false,
    this.isReposted = false,
    this.isSaved = false,
    required this.timestamp,
    this.threadChain = const [],
    this.comments = const [],
  });

  bool get isProduct => postType == 'product';
  bool get isThread => postType == 'thread';
  String get sellerName => seller.name;
  String get sellerUsername => seller.username ?? seller.name;
  String get sellerAvatar => seller.avatar;
  String get department => seller.classGroup;
  String get description => caption;
  List<String> get imageUrls => images;


  MarketPostModel copyWith({
    String? id,
    String? postType,
    SellerModel? seller,
    String? caption,
    List<String>? images,
    String? title,
    String? topicTag,
    bool? isOfficialTopic,
    String? topicIcon,
    int? totalThreadParts,
    String? locationTag,
    int? price,
    int? originalPrice,
    int? stock,
    String? category,
    int? likesCount,
    int? commentsCount,
    int? repostsCount,
    bool? isLiked,
    bool? isReposted,
    bool? isSaved,
    String? timestamp,
    List<ThreadChainItemModel>? threadChain,
    List<PostCommentModel>? comments,
  }) {
    return MarketPostModel(
      id: id ?? this.id,
      postType: postType ?? this.postType,
      seller: seller ?? this.seller,
      caption: caption ?? this.caption,
      images: images ?? this.images,
      title: title ?? this.title,
      topicTag: topicTag ?? this.topicTag,
      isOfficialTopic: isOfficialTopic ?? this.isOfficialTopic,
      topicIcon: topicIcon ?? this.topicIcon,
      totalThreadParts: totalThreadParts ?? this.totalThreadParts,
      locationTag: locationTag ?? this.locationTag,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      repostsCount: repostsCount ?? this.repostsCount,
      isLiked: isLiked ?? this.isLiked,
      isReposted: isReposted ?? this.isReposted,
      isSaved: isSaved ?? this.isSaved,
      timestamp: timestamp ?? this.timestamp,
      threadChain: threadChain ?? this.threadChain,
      comments: comments ?? this.comments,
    );
  }
}

/// Realistic Mock Dataset for SMKN 8 Jakarta feed (6 sequential parameter variations for visual audit)
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
    caption: 'Eksplorasi layout majalah dinding digital SMKN 8 Jakarta semester ini sudah jadi! Gimana menurut kalian komposisi warna dan visual hierarchy-nya? Feedbacks are welcome! 📐✨',
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

