import 'package:flutter/foundation.dart';
export 'package:snapan_market/features/feed/models/mock_market_posts.dart';

typedef MarketPost = MarketPostModel;

String _formatRelativeTimestamp(dynamic raw) {
  if (raw == null) return 'Baru saja';
  final str = raw.toString();
  if (str.endsWith('m') || str.endsWith('j') || str.endsWith('h') || str.endsWith('d')) {
    return str;
  }
  try {
    final dateTime = DateTime.parse(str);
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}j';
    if (diff.inDays < 7) return '${diff.inDays}h';
    return '${diff.inDays ~/ 7}mg';
  } catch (_) {
    return str;
  }
}

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

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
      id: json['id']?.toString() ?? '',
      name: json['full_name']?.toString() ?? json['name']?.toString() ?? 'Pengguna Snapan',
      username: json['username']?.toString(),
      avatar: json['avatar_url']?.toString() ?? json['avatar']?.toString() ?? '',
      classGroup: json['class_group']?.toString() ?? json['classGroup']?.toString() ?? 'Siswa Snapan',
      isVerified: json['is_verified'] == true || json['isVerified'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': name,
    'username': username,
    'avatar_url': avatar,
    'class_group': classGroup,
    'is_verified': isVerified,
  };

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

  factory ThreadChainItemModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    List<String> parsedImages = [];
    if (rawImages is List) {
      parsedImages = rawImages.map((e) => e.toString()).toList();
    }
    return ThreadChainItemModel(
      id: json['id']?.toString() ?? '',
      partNumber: (json['part_number'] ?? json['partNumber'] ?? 1) as int,
      totalParts: (json['total_parts'] ?? json['totalParts'] ?? 1) as int,
      caption: json['caption']?.toString() ?? '',
      images: parsedImages,
      timestamp: _formatRelativeTimestamp(json['created_at'] ?? json['timestamp']),
      likesCount: (json['likes_count'] ?? json['likesCount'] ?? 0) as int,
      commentsCount: (json['comments_count'] ?? json['commentsCount'] ?? 0) as int,
      isLiked: json['is_liked'] == true || json['isLiked'] == true,
    );
  }

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

  factory CommentUserModel.fromJson(Map<String, dynamic> json) {
    return CommentUserModel(
      id: json['id']?.toString() ?? '',
      name: json['full_name']?.toString() ?? json['name']?.toString() ?? 'Pengguna Snapan',
      avatar: json['avatar_url']?.toString() ?? json['avatar']?.toString() ?? '',
      username: json['username']?.toString(),
      classGroup: json['class_group']?.toString() ?? json['classGroup']?.toString(),
      isVerified: json['is_verified'] == true || json['isVerified'] == true,
      isAuthor: json['is_author'] == true || json['isAuthor'] == true,
    );
  }
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

  factory PostCommentModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    List<String> parsedImages = [];
    if (rawImages is List) {
      parsedImages = rawImages.map((e) => e.toString()).toList();
    }

    final rawReplies = json['replies'];
    List<PostCommentModel> parsedReplies = [];
    if (rawReplies is List) {
      parsedReplies = rawReplies
          .whereType<Map<String, dynamic>>()
          .map((r) => PostCommentModel.fromJson(r))
          .toList();
    }

    CommentUserModel commentUser;
    if (json['user'] is Map<String, dynamic>) {
      commentUser = CommentUserModel.fromJson(json['user']);
    } else if (json['profiles'] is Map<String, dynamic>) {
      commentUser = CommentUserModel.fromJson(json['profiles']);
    } else {
      commentUser = CommentUserModel(
        id: json['user_id']?.toString() ?? '',
        name: 'Pengguna',
        avatar: '',
      );
    }

    return PostCommentModel(
      id: json['id']?.toString() ?? '',
      postId: json['post_id']?.toString() ?? json['postId']?.toString() ?? '',
      user: commentUser,
      content: json['content']?.toString() ?? '',
      images: parsedImages,
      threadPart: json['thread_part'] as int? ?? json['threadPart'] as int?,
      totalParts: json['total_parts'] as int? ?? json['totalParts'] as int?,
      timestamp: _formatRelativeTimestamp(json['created_at'] ?? json['timestamp']),
      likesCount: (json['likes_count'] ?? json['likesCount'] ?? 0) as int,
      isLiked: json['is_liked'] == true || json['isLiked'] == true,
      replies: parsedReplies,
    );
  }

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

  factory MarketPostModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    List<String> parsedImages = [];
    if (rawImages is List) {
      parsedImages = rawImages.map((e) => e.toString()).toList();
    }

    SellerModel postSeller;
    if (json['seller'] is Map<String, dynamic>) {
      postSeller = SellerModel.fromJson(json['seller']);
    } else if (json['profiles'] is Map<String, dynamic>) {
      postSeller = SellerModel.fromJson(json['profiles']);
    } else {
      postSeller = SellerModel(
        id: json['seller_id']?.toString() ?? '',
        name: 'Penjual Snapan',
        avatar: '',
        classGroup: 'Siswa',
      );
    }

    final rawChain = json['thread_chain'] ?? json['threadChain'];
    List<ThreadChainItemModel> parsedChain = [];
    if (rawChain is List) {
      parsedChain = rawChain
          .whereType<Map<String, dynamic>>()
          .map((c) => ThreadChainItemModel.fromJson(c))
          .toList();
    }

    final rawComments = json['comments'] ?? json['post_comments'];
    List<PostCommentModel> parsedComments = [];
    if (rawComments is List) {
      parsedComments = rawComments
          .whereType<Map<String, dynamic>>()
          .map((c) => PostCommentModel.fromJson(c))
          .toList();
    }

    return MarketPostModel(
      id: json['id']?.toString() ?? '',
      postType: json['post_type']?.toString() ?? json['postType']?.toString() ?? 'thread',
      seller: postSeller,
      caption: json['caption']?.toString() ?? '',
      images: parsedImages,
      title: json['title']?.toString(),
      topicTag: json['topic_tag']?.toString() ?? json['topicTag']?.toString(),
      isOfficialTopic: json['is_official_topic'] == true || json['isOfficialTopic'] == true,
      topicIcon: json['topic_icon']?.toString() ?? json['topicIcon']?.toString(),
      totalThreadParts: json['total_thread_parts'] as int? ?? json['totalThreadParts'] as int?,
      locationTag: json['location_tag']?.toString() ?? json['locationTag']?.toString(),
      price: json['price'] != null ? (num.tryParse(json['price'].toString())?.toInt()) : null,
      originalPrice: json['original_price'] != null
          ? (num.tryParse(json['original_price'].toString())?.toInt())
          : null,
      stock: json['stock'] != null ? (num.tryParse(json['stock'].toString())?.toInt()) : null,
      category: json['category']?.toString(),
      likesCount: (json['likes_count'] ?? json['likesCount'] ?? 0) as int,
      commentsCount: (json['comments_count'] ?? json['commentsCount'] ?? 0) as int,
      repostsCount: (json['reposts_count'] ?? json['repostsCount'] ?? 0) as int,
      isLiked: json['is_liked'] == true || json['isLiked'] == true,
      isReposted: json['is_reposted'] == true || json['isReposted'] == true,
      isSaved: json['is_saved'] == true || json['isSaved'] == true,
      timestamp: _formatRelativeTimestamp(json['created_at'] ?? json['timestamp']),
      threadChain: parsedChain,
      comments: parsedComments,
    );
  }

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
