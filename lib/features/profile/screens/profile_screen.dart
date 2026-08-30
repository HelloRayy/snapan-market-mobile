import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/feed/components/market_post_card.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';
import 'package:snapan_market/features/feed/screens/post_detail_screen.dart';
import 'package:snapan_market/features/profile/components/profile_header_app_bar.dart';
import 'package:snapan_market/features/profile/components/profile_info_header.dart';
import 'package:snapan_market/features/profile/components/profile_action_buttons.dart';
import 'package:snapan_market/features/profile/components/profile_tab_bar.dart';
import 'package:snapan_market/features/profile/components/profile_reply_thread_card.dart';
import 'package:snapan_market/features/profile/components/profile_media_grid.dart';
import 'package:snapan_market/features/profile/models/profile_user_model.dart';
import 'package:snapan_market/features/profile/models/mock_profile_data.dart';

/// Full Profile Screen matching ProfilePage.tsx 1:1
///
/// Features:
/// - Sticky Top Bar with Search toggle & filter
/// - Name, Handle, 60x60 Avatar, Class, Verified Badge
/// - Bio & Left-Aligned 3-Avatar Stacked Follower + Seller stats
/// - Bakat & Minat Badges (Chips)
/// - Edit Profile / Follow Action CTA
/// - 3-Tab Sticky Switcher: [Utas] | [Balasan] | [Media]
/// - Live search query filtering across posts, replies, and media
class ProfileScreen extends StatefulWidget {
  final String? username;
  final VoidCallback? onBack;
  final VoidCallback? onOpenMenu;

  const ProfileScreen({
    super.key,
    this.username,
    this.onBack,
    this.onOpenMenu,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  ProfileTab _activeTab = ProfileTab.threads;

  // Search in Profile state
  bool _showSearch = false;
  String _searchQuery = '';

  // Follow State (if viewing other user)
  bool _isFollowing = false;

  late ProfileUserModel _user;
  late List<MarketPostModel> _allUserPosts;
  late List<ProfileReplyThreadModel> _allUserReplies;

  bool get _isOwnProfile {
    final target = widget.username?.toLowerCase().replaceAll('@', '');
    return target == null ||
        target == 'radityarayhannnn' ||
        target == 'me' ||
        target.isEmpty;
  }

  @override
  void initState() {
    super.initState();
    _initProfileData();
  }

  void _initProfileData() {
    if (_isOwnProfile) {
      _user = kDefaultProfileUser;
      // Filter user's own posts from mock feed
      _allUserPosts = kMockMarketPosts.where((p) {
        return p.seller.username == 'radityarayhannnn' ||
            p.seller.id == 'user-1' ||
            p.seller.id == 'user-thread-1' ||
            p.seller.id == 'user-current-1';
      }).toList();
      _allUserReplies = List.from(kMockUserReplies);
    } else {
      final cleanUsername = widget.username!.replaceAll('@', '');
      // Find matching post to populate seller info
      final matched = kMockMarketPosts.firstWhere(
        (p) =>
            p.seller.username?.toLowerCase() == cleanUsername.toLowerCase() ||
            p.seller.name.toLowerCase().replaceAll(' ', '') == cleanUsername.toLowerCase(),
        orElse: () => kMockMarketPosts.first,
      );

      _user = ProfileUserModel(
        id: matched.seller.id,
        name: matched.seller.name,
        username: matched.seller.username ?? cleanUsername,
        avatar: matched.seller.avatar,
        bio: 'Siswa SMKN 8 Jakarta · Jurusan ${matched.seller.classGroup?.split(' ').last ?? 'PPLG'}.',
        classGroup: matched.seller.classGroup ?? 'XII PPLG 2',
        tags: const ['📱 Mobile Dev', '🎨 UI/UX', '📷 Fotografi', '💼 Project PJBL'],
        followersCount: 289,
        soldCount: 42,
        rating: 4.9,
        isVerified: matched.seller.isVerified,
      );

      _allUserPosts = kMockMarketPosts.where((p) {
        return p.seller.username?.toLowerCase() == cleanUsername.toLowerCase() ||
            p.seller.name.toLowerCase().replaceAll(' ', '') == cleanUsername.toLowerCase();
      }).toList();

      _allUserReplies = [];
    }
  }

  void _handlePostClick(MarketPostModel post) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(post: post),
      ),
    );
  }

  void _handleImageClick(MarketPostModel item, int index) {
    if (item.images.isEmpty || index >= item.images.length) return;
    _openImageViewer(item.images[index]);
  }

  void _openImageViewer(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 16.0,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    color: Color(0x80000000),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 20.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _handleEditProfile() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur Edit Profil akan segera hadir!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleDirectMessage() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fitur pesan langsung dengan @${_user.username} akan segera hadir!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter posts according to search query
    final displayPosts = _allUserPosts.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.caption.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Filter replies
    final displayReplies = _allUserReplies.where((t) {
      if (_searchQuery.isEmpty) return true;
      return t.reply.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.parentPost.caption.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Extract media items for Media tab
    final mediaItems = _allUserPosts
        .expand((p) => p.images.map((img) => ProfileMediaItem(imageUrl: img, post: p)))
        .where((m) {
          if (_searchQuery.isEmpty) return true;
          return m.post.caption.toLowerCase().contains(_searchQuery.toLowerCase());
        })
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ProfileHeaderAppBar(
        showSearch: _showSearch,
        searchQuery: _searchQuery,
        onSearchChanged: (val) => setState(() => _searchQuery = val),
        onToggleSearch: () {
          setState(() {
            _showSearch = !_showSearch;
            if (!_showSearch) _searchQuery = '';
          });
        },
        onBackTap: widget.onBack,
        onMenuTap: widget.onOpenMenu,
        onTitleTap: () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          }
        },
      ),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // 1. Profile Bio & Information Header
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileInfoHeader(
                  user: _user,
                  isOwnProfile: _isOwnProfile,
                  onEditInterests: _handleEditProfile,
                ),
                ProfileActionButtons(
                  isOwnProfile: _isOwnProfile,
                  isFollowing: _isFollowing,
                  onEditProfile: _handleEditProfile,
                  onToggleFollow: () {
                    setState(() {
                      _isFollowing = !_isFollowing;
                      _user = _user.copyWith(
                        followersCount: _isFollowing
                            ? _user.followersCount + 1
                            : _user.followersCount - 1,
                      );
                    });
                  },
                  onDirectMessage: _handleDirectMessage,
                ),
                const SizedBox(height: 10.0),
              ],
            ),
          ),

          // 2. Sticky 3-Tab Bar Switcher (Utas, Balasan, Media)
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverProfileTabDelegate(
              child: ProfileTabBar(
                activeTab: _activeTab,
                onTabChanged: (tab) => setState(() => _activeTab = tab),
              ),
            ),
          ),

          // 3. Tab Content Area
          if (_activeTab == ProfileTab.threads) ...[
            if (displayPosts.isNotEmpty)
              SliverList.builder(
                itemCount: displayPosts.length,
                itemBuilder: (context, index) {
                  final post = displayPosts[index];
                  return MarketPostCard(
                    key: ValueKey(post.id),
                    item: post,
                    onPostClick: _handlePostClick,
                    onImageClick: _handleImageClick,
                  );
                },
              )
            else
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 64.0, horizontal: 24.0),
                  alignment: Alignment.center,
                  child: const Column(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 36.0,
                        color: Color(0xFFCBD5E1),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        'Belum ada postingan',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'Postingan dan produk jualan akan muncul di sini.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF94A3B8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ] else if (_activeTab == ProfileTab.replies) ...[
            if (displayReplies.isNotEmpty)
              SliverList.builder(
                itemCount: displayReplies.length,
                itemBuilder: (context, index) {
                  final replyThread = displayReplies[index];
                  return ProfileReplyThreadCard(
                    key: ValueKey(replyThread.id),
                    thread: replyThread,
                    onPostClick: _handlePostClick,
                    onImageClick: (imgs, idx) => _openImageViewer(imgs[idx]),
                  );

                },
              )
            else
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 64.0, horizontal: 24.0),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 36.0,
                        color: Color(0xFFCBD5E1),
                      ),
                      const SizedBox(height: 10.0),
                      const Text(
                        'Belum ada balasan',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '@${_user.username} belum membalas utas apa pun.',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF94A3B8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ] else if (_activeTab == ProfileTab.media) ...[
            SliverToBoxAdapter(
              child: ProfileMediaGrid(
                mediaItems: mediaItems,
                onMediaTap: _handlePostClick,
              ),
            ),
          ],

          // Bottom Safe Area Spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 40.0),
          ),
        ],
      ),
    );
  }
}

class _SliverProfileTabDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverProfileTabDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 46.0;

  @override
  double get minExtent => 46.0;

  @override
  bool shouldRebuild(covariant _SliverProfileTabDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
