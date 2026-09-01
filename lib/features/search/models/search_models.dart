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
    id: "1",
    username: "growthflo",
    fullName: "Flo",
    avatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&q=80",
    bio: "designing & running adfects.com",
    followersCount: "8.728 pengikut",
  ),
  SuggestedAccount(
    id: "2",
    username: "haluandotco",
    fullName: "Haluan Media",
    avatar: "https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150&q=80",
    isVerified: true,
    bio: "Berita Politik, Nasional, Internasional, dan Hiburan terkini.",
    followersCount: "245 rb pengikut",
  ),
  SuggestedAccount(
    id: "3",
    username: "dewakoding",
    fullName: "Septiawan Aji Pradana",
    avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&q=80",
    bio: "🚀 | Sharing Tips Programming 💻 | Pengguna Laravel Sejati",
    followersCount: "14,2 rb pengikut",
  ),
  SuggestedAccount(
    id: "4",
    username: "kementeriankegelapan",
    fullName: "Kementerian Kegelapan",
    avatar: "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=150&q=80",
    isVerified: true,
    bio: "Indonesia Emas 2045 Hijriah. Limbah & Inovasi.",
    followersCount: "89,1 rb pengikut",
  ),
  SuggestedAccount(
    id: "5",
    username: "officialbin_ri",
    fullName: "Badan Intelijen Negara",
    avatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&q=80",
    isVerified: true,
    bio: "Akun Threads Resmi Badan Intelijen Negara Republik Indonesia.",
    followersCount: "120 rb pengikut",
  ),
  SuggestedAccount(
    id: "6",
    username: "junaid_jamel",
    fullName: "Junaid • iOS & Android Developer",
    avatar: "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150&q=80",
    isVerified: true,
    bio: "I build Mobile Apps 📩 junaid@developer.com",
    followersCount: "32,4 rb pengikut",
  ),
  SuggestedAccount(
    id: "7",
    username: "uiuxbagas",
    fullName: "Bagas Surya A | UI/UX Designer",
    avatar: "https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150&q=80",
    bio: "💼 UI/UX Designer 📌 Bekasi, IDN — Design By : @bagas",
    followersCount: "18,9 rb pengikut",
  ),
  SuggestedAccount(
    id: "8",
    username: "indozone.id",
    fullName: "INDOZONE - #KAMUHARUSTAU",
    avatar: "https://images.unsplash.com/photo-1586339949916-3e9457bef6d3?w=150&q=80",
    isVerified: true,
    bio: "Zone of Youth Generation — 📌 INDOZONE Media Group",
    followersCount: "540 rb pengikut",
  ),
  SuggestedAccount(
    id: "9",
    username: "dytama.studio",
    fullName: "dytama studio",
    avatar: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&q=80",
    bio: "Creative digital design & brand architecture.",
    followersCount: "52 pengikut",
  ),
];

const List<TrendingTag> kTrendingTags = [
  TrendingTag(id: "1", tag: "snapandev", posts: "1.8 rb utas"),
  TrendingTag(id: "2", tag: "vibe coding", posts: "3.4 rb utas"),
  TrendingTag(id: "3", tag: "MarketDay", posts: "1.2 rb utas"),
  TrendingTag(id: "4", tag: "PPLG1", posts: "856 utas"),
  TrendingTag(id: "5", tag: "Kantin8", posts: "2.4 rb utas"),
];
