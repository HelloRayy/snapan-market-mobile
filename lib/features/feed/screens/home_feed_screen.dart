import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/feed/components/home_feed_header.dart';
import 'package:snapan_market/features/feed/components/home_feed_tab_switch.dart';
import 'package:snapan_market/features/feed/components/home_bottom_nav_bar.dart';
import 'package:snapan_market/features/feed/components/home_navigation_drawer.dart';
import 'package:snapan_market/features/feed/components/market_post_card.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';
import 'package:snapan_market/features/feed/screens/post_detail_screen.dart';
import 'package:snapan_market/features/profile/screens/profile_screen.dart';
import 'package:snapan_market/features/create_post/screens/create_post_modal.dart';
import 'package:snapan_market/features/create_post/models/create_post_types.dart';

/// Main Home Feed Screen
///
/// Features sticky [HomeFeedHeader] with tactile action controls,
/// sticky [HomeFeedTabSwitch] for "Untuk Anda" and "Terbaru" feed modes,
/// scroll-to-top behavior, dynamic [MarketPostCard] list feed, and bottom navigation.
class HomeFeedScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const HomeFeedScreen({
    super.key,
    this.onLogout,
  });

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  FeedTab _activeTab = FeedTab.forYou;
  HomeNavTab _currentNavTab = HomeNavTab.home;

  // Dynamic Feed Posts list initialized with rich Indonesian school dataset
  late List<MarketPostModel> _posts;

  @override
  void initState() {
    super.initState();
    _posts = List<MarketPostModel>.from(kMockMarketPosts);
  }

  @override
  void reassemble() {
    super.reassemble();
    // Auto syncs mock dataset on every Hot Reload (r)
    _posts = List<MarketPostModel>.from(kMockMarketPosts);
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleMenuTap() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _handleSearchTap() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pencarian akan segera hadir pada slicing berikutnya!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleCreatePost([PostMode mode = PostMode.thread]) {
    CreatePostModal.show(
      context,
      initialMode: mode,
      onSubmitPost: (data) {
        final postMode = data['mode'] as String? ?? 'thread';
        final caption = data['caption'] as String? ?? '';
        final locationTag = data['location'] as String?;
        final price = data['price'] as int?;
        final stock = data['stock'] as int?;
        final images = (data['images'] as List<dynamic>?)?.cast<String>() ?? [];

        final newPost = MarketPostModel(
          id: 'post-user-${DateTime.now().millisecondsSinceEpoch}',
          postType: postMode,
          seller: const SellerModel(
            id: 'current-user-1',
            name: 'Akun Anda',
            username: 'saya',
            avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
            classGroup: 'XII PPLG 1',
            isVerified: true,
          ),
          caption: caption.isNotEmpty ? caption : 'Postingan baru dari SMKN 8 Jakarta',
          images: images,
          locationTag: locationTag,
          price: price,
          stock: stock,
          timestamp: 'Baru saja',
          likesCount: 0,
          commentsCount: 0,
          repostsCount: 0,
          isLiked: false,
          isReposted: false,
        );

        setState(() {
          _posts.insert(0, newPost);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              postMode == 'product'
                  ? 'Produk berhasil dipasang ke katalog COD SMKN 8!'
                  : 'Utas berhasil diposting ke feed!',
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _handleTabChanged(FeedTab tab) {
    setState(() {
      _activeTab = tab;
    });
  }

  void _handleLikeToggle(MarketPostModel updatedItem) {
    final index = _posts.indexWhere((p) => p.id == updatedItem.id);
    if (index != -1) {
      setState(() {
        _posts[index] = updatedItem;
      });
    }
  }

  void _handleRepostToggle(MarketPostModel updatedItem) {
    final index = _posts.indexWhere((p) => p.id == updatedItem.id);
    if (index != -1) {
      setState(() {
        _posts[index] = updatedItem;
      });
    }
  }

  void _handlePostClick(MarketPostModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(post: item),
      ),
    );
  }

  void _handleTopicClick(String topic) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Menampilkan postingan topik #$topic'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleUserClick(String username) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          username: username,
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _handleImageClick(MarketPostModel item, int imageIndex) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  item.images[imageIndex],
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 10.0,
              right: 10.0,
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

  List<MarketPostModel> get _displayedPosts {
    if (_activeTab == FeedTab.latest) {
      // For "Terbaru" tab, sort by latest posts
      return _posts.reversed.toList();
    }
    return _posts;
  }

  @override
  Widget build(BuildContext context) {
    final posts = _displayedPosts;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth: 40.0,
      drawer: HomeNavigationDrawer(
        onNavigateHome: () {
          setState(() {
            _activeTab = FeedTab.forYou;
            _currentNavTab = HomeNavTab.home;
          });
          _scrollToTop();
        },
        onNavigateSearch: _handleSearchTap,
        onOpenCreateModal: _handleCreatePost,
        onLogout: widget.onLogout,
      ),
      appBar: _currentNavTab == HomeNavTab.profile
          ? null
          : HomeFeedHeader(
              onMenuTap: _handleMenuTap,
              onTitleTap: _scrollToTop,
              onSearchTap: _handleSearchTap,
            ),
      body: _currentNavTab == HomeNavTab.profile
          ? ProfileScreen(
              onOpenMenu: _handleMenuTap,
            )
          : CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Sticky Switch Tab Bar ("Untuk Anda" & "Terbaru") Isolated with RepaintBoundary
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabSwitchDelegate(
                    child: RepaintBoundary(
                      child: HomeFeedTabSwitch(
                        activeTab: _activeTab,
                        onTabChanged: _handleTabChanged,
                      ),
                    ),
                  ),
                ),


          // Dynamic Feed Posts Sliver List
          SliverList.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return MarketPostCard(
                key: ValueKey(post.id),
                item: post,
                onLikeToggle: _handleLikeToggle,
                onRepostToggle: _handleRepostToggle,
                onPostClick: _handlePostClick,
                onTopicClick: _handleTopicClick,
                onUserClick: _handleUserClick,
                onImageClick: _handleImageClick,
              );
            },
          ),

          // End of Feed Footer
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.canvas,
              padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 16.0),
              child: Column(
                children: [
                  Container(
                    width: 32.0,
                    height: 3.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                  const SizedBox(height: 14.0),
                  const Text(
                    'Scroll ke bawah untuk memuat postingan baru',
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  if (widget.onLogout != null) ...[
                    const SizedBox(height: 16.0),
                    TextButton.icon(
                      onPressed: widget.onLogout,
                      icon: const Icon(
                        Icons.logout_rounded,
                        size: 16.0,
                        color: AppColors.muted,
                      ),
                      label: const Text(
                        'Keluar (Reset Onboarding)',
                        style: TextStyle(
                          fontSize: 13.0,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: HomeBottomNavBar(
        currentTab: _currentNavTab,
        hasUnreadMessages: true,
        onTabSelected: (tab) {
          if (tab == HomeNavTab.create) {
            _handleCreatePost();
          } else {
            setState(() => _currentNavTab = tab);
          }
        },
        onCreateTap: _handleCreatePost,
      ),
    );
  }
}

/// SliverPersistentHeaderDelegate for Sticky Tab Switch Bar (47px height)
class _SliverTabSwitchDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverTabSwitchDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => 47.0;

  @override
  double get minExtent => 47.0;

  @override
  bool shouldRebuild(covariant _SliverTabSwitchDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
