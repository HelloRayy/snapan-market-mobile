import 'package:flutter/foundation.dart';
export 'package:snapan_market/features/feed/models/mock_market_posts.dart';

typedef MarketPost = MarketPostModel;

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
