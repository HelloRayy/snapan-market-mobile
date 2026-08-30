import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Profile User Information Model matching Web Profile Data
class ProfileUserModel {
  final String id;
  final String name;
  final String username;
  final String avatar;
  final String bio;
  final String classGroup;
  final List<String> tags;
  final String? link;
  final bool showSalesStats;
  final int followersCount;
  final int soldCount;
  final double rating;
  final int reviewsCount;
  final bool isVerified;

  const ProfileUserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.avatar,
    required this.bio,
    required this.classGroup,
    required this.tags,
    this.link,
    this.showSalesStats = true,
    this.followersCount = 142,
    this.soldCount = 24,
    this.rating = 4.9,
    this.reviewsCount = 18,
    this.isVerified = true,
  });

  ProfileUserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? avatar,
    String? bio,
    String? classGroup,
    List<String>? tags,
    String? link,
    bool? showSalesStats,
    int? followersCount,
    int? soldCount,
    double? rating,
    int? reviewsCount,
    bool? isVerified,
  }) {
    return ProfileUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      classGroup: classGroup ?? this.classGroup,
      tags: tags ?? this.tags,
      link: link ?? this.link,
      showSalesStats: showSalesStats ?? this.showSalesStats,
      followersCount: followersCount ?? this.followersCount,
      soldCount: soldCount ?? this.soldCount,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      isVerified: isVerified ?? this.isVerified,
    );
  }

}

/// Reply Thread Model for Balasan Tab matching UserReplyThread from src/types/marketFeed.ts
class ProfileReplyThreadModel {
  final String id;
  final MarketPostModel parentPost;
  final PostCommentModel reply;

  const ProfileReplyThreadModel({
    required this.id,
    required this.parentPost,
    required this.reply,
  });
}
