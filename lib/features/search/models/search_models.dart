class SuggestedAccount {
  final String id;
  final String username;
  final String fullName;
  final String avatar;
  final bool isVerified;
  final String bio;
  final String followersCount;
  final bool isFollowing;

  const SuggestedAccount({
    required this.id,
    required this.username,
    required this.fullName,
    required this.avatar,
    this.isVerified = false,
    required this.bio,
    required this.followersCount,
    this.isFollowing = false,
  });

  SuggestedAccount copyWith({
    String? id,
    String? username,
    String? fullName,
    String? avatar,
    bool? isVerified,
    String? bio,
    String? followersCount,
    bool? isFollowing,
  }) {
    return SuggestedAccount(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatar: avatar ?? this.avatar,
      isVerified: isVerified ?? this.isVerified,
      bio: bio ?? this.bio,
      followersCount: followersCount ?? this.followersCount,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}

class TrendingTag {
  final String id;
  final String tag;
  final String posts;

  const TrendingTag({
    required this.id,
    required this.tag,
    required this.posts,
  });
}

const List<SuggestedAccount> kInitialSuggestedAccounts = [
  SuggestedAccount(
    id: "0",
    username: "snaps",
    fullName: "Snaps Developer",
    avatar: "assets/logo/smk8.png",
    isVerified: true,
    bio: "Come see what Snapanians are talking about.",
    followersCount: "Akun Resmi",
  ),
];

const List<TrendingTag> kTrendingTags = [
  TrendingTag(id: "1", tag: "snapandev", posts: "1.8 rb utas"),
  TrendingTag(id: "2", tag: "vibe coding", posts: "3.4 rb utas"),
  TrendingTag(id: "3", tag: "MarketDay", posts: "1.2 rb utas"),
  TrendingTag(id: "4", tag: "PPLG1", posts: "856 utas"),
  TrendingTag(id: "5", tag: "Kantin8", posts: "2.4 rb utas"),
];
