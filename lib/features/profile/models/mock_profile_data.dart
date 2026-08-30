import 'package:snapan_market/features/feed/models/market_post_model.dart';
import 'package:snapan_market/features/profile/models/profile_user_model.dart';

/// Default Logged-In User Profile Mock matching Web Profile Page
const ProfileUserModel kDefaultProfileUser = ProfileUserModel(
  id: 'user-current-1',
  name: 'Raditya Rayhan',
  username: 'radityarayhannnn',
  avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
  bio: 'Building scalable mobile applications & web apps with clean architecture.',
  classGroup: 'XII PPLG 1',
  tags: [
    'Web PWA',
    'UI/UX',
    'Preloved',
    'Joki Coding',
    'Kuliner',
  ],
  link: 'https://instagram.com/radityarayhannnn',
  showSalesStats: true,
  followersCount: 142,
  soldCount: 24,
  rating: 4.9,
  reviewsCount: 18,
  isVerified: true,
);

/// Preset Avatars matching PRESET_AVATARS in src/ui/pages/EditProfilePage.tsx
const List<String> kPresetAvatars = [
  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&q=80',
  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&q=80',
  'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300&q=80',
  'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=300&q=80',
  'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=300&q=80',
  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&q=80',
];


/// Mock Replies List for "Balasan" Tab matching MOCK_USER_REPLIES in src/data/mockMarketData.ts
final List<ProfileReplyThreadModel> kMockUserReplies = [
  ProfileReplyThreadModel(
    id: 'reply-thread-1',
    parentPost: const MarketPostModel(
      id: 'post-thread-1',
      postType: 'thread',
      seller: SellerModel(
        id: 'user-thread-1',
        name: 'Raymond Chin',
        avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
        classGroup: 'XII PPLG 1',
        isVerified: true,
        username: 'raymondchins',
      ),
      caption:
          'Ada kenalan website designer / UI engineer yang bisa diajak kolaborasi bikin landing page & PWA kilat? Comment portofolio & tech stack kalian di bawah ya :) 🚀',
      images: [
        'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&q=80',
        'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?w=800&q=80',
      ],
      topicTag: 'frontend',
      isOfficialTopic: true,
      topicIcon: 'threads',
      likesCount: 466,
      commentsCount: 2,
      repostsCount: 9,
      timestamp: '1j',
      isLiked: true,
    ),
    reply: const PostCommentModel(
      id: 'reply-1',
      postId: 'post-thread-1',
      user: CommentUserModel(
        id: 'user-current-1',
        name: 'Raditya Rayhan',
        username: 'radityarayhannnn',
        avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
        classGroup: 'XII PPLG 1',
        isVerified: true,
      ),
      content: 'Saya open collab mas! Tech stack React + Tailwind v4 & Framer Motion 🎨✨',
      timestamp: '45m',
      likesCount: 17,
      isLiked: true,
    ),
  ),
  ProfileReplyThreadModel(
    id: 'reply-thread-2',
    parentPost: const MarketPostModel(
      id: 'parent-faiz-1',
      postType: 'thread',
      seller: SellerModel(
        id: 'user-faiz',
        name: 'Faiz Intifada',
        username: 'faizintifada',
        avatar: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=200&q=80',
        classGroup: 'XII PPLG 2',
        isVerified: false,
      ),
      caption:
          'Lagi open order jasa 3D Modeling Blender buat tugas akhir / portofolio mockup! Bisa animasi render kilat 360 derajat 🚀🖥️',
      images: [
        'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&q=80',
      ],
      likesCount: 128,
      commentsCount: 14,
      repostsCount: 5,
      timestamp: '2j',
      isLiked: true,
    ),
    reply: const PostCommentModel(
      id: 'reply-2',
      postId: 'parent-faiz-1',
      user: CommentUserModel(
        id: 'user-current-1',
        name: 'Raditya Rayhan',
        username: 'radityarayhannnn',
        avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
        classGroup: 'XII PPLG 1',
        isVerified: true,
      ),
      content:
          'Keren banget idenya! Bisa custom warna atau ukuran mockup ga bro? Mau buat project PWA kita nanti 🔥',
      timestamp: '2j',
      likesCount: 4,
      isLiked: false,
    ),
  ),
  ProfileReplyThreadModel(
    id: 'reply-thread-3',
    parentPost: const MarketPostModel(
      id: 'parent-kantin-1',
      postType: 'product',
      seller: SellerModel(
        id: 'user-kantin',
        name: 'Kantin SMKN 8',
        username: 'kantin_smkn8',
        avatar: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=200&q=80',
        classGroup: 'Kantin Sekolah',
        isVerified: true,
      ),
      caption:
          'Paket Spesial Nasi Ayam Geprek Sambal Bawang + Es Teh Manis Jumbo cuma 15k khusus jam istirahat pertama & kedua! 🍗🔥',
      price: 15000,
      images: [
        'https://images.unsplash.com/photo-1562967914-608f82629710?w=800&q=80',
      ],
      likesCount: 94,
      commentsCount: 8,
      repostsCount: 1,
      timestamp: '1h',
      isLiked: false,
    ),
    reply: const PostCommentModel(
      id: 'reply-3',
      postId: 'parent-kantin-1',
      user: CommentUserModel(
        id: 'user-current-1',
        name: 'Raditya Rayhan',
        username: 'radityarayhannnn',
        avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
        classGroup: 'XII PPLG 1',
        isVerified: true,
      ),
      content: 'Siang ini masih ready paket nasi ayam gepreknya bu? Mau pesan 3 porsi buat anak lab PPLG 🍗',
      timestamp: '1h',
      likesCount: 2,
      isLiked: false,
    ),
  ),
];
