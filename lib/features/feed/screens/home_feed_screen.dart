import "package:snapan_market/features/search/screens/search_screen.dart";
import "package:snapan_market/features/map/screens/campus_map_screen.dart";
import "package:snapan_market/features/activity/screens/activity_screen.dart";
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:snapan_market/core/navigation/app_slide_page_route.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

import 'package:snapan_market/features/feed/components/home_feed_header.dart';
import 'package:snapan_market/features/feed/components/home_feed_tab_switch.dart';
import 'package:snapan_market/features/feed/components/home_bottom_nav_bar.dart';
import 'package:snapan_market/features/feed/components/floating_plus_squircle_button.dart';
import 'package:snapan_market/features/feed/components/home_menu_popover.dart';
import 'package:snapan_market/features/feed/components/market_post_card.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';
import 'package:snapan_market/features/feed/screens/post_detail_screen.dart';
import 'package:snapan_market/features/feed/components/media_lightbox_dialog.dart';
import 'package:snapan_market/features/messages/screens/direct_messages_screen.dart';
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

class _HomeFeedScreenState extends State<HomeFeedScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _barsAnimationController;
  late final Animation<double> _barsAnimation;
  FeedTab _activeTab = FeedTab.forYou;
  HomeNavTab _currentNavTab = HomeNavTab.home;
  bool _isBarsVisible = true;

  // Dynamic Feed Posts list initialized with rich Indonesian school dataset
  late List<MarketPostModel> _posts;

  @override
  void initState() {
    super.initState();
    _posts = List<MarketPostModel>.from(kMockMarketPosts);
    _barsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: 1.0,
    );
    _barsAnimation = CurvedAnimation(
      parent: _barsAnimationController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void reassemble() {
    super.reassemble();
    // Auto syncs mock dataset on every Hot Reload (r)
    _posts = List<MarketPostModel>.from(kMockMarketPosts);
  }

  @override
  void dispose() {
    _barsAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _hideBars() {
    if (_isBarsVisible) {
      _isBarsVisible = false;
      _barsAnimationController.reverse();
    }
  }

  void _showBars() {
    if (!_isBarsVisible) {
      _isBarsVisible = true;
      _barsAnimationController.forward();
    }
  }

  void _scrollToTop() {
    _showBars();
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleMenuTap() {
    HomeMenuPopover.show(
      context: context,
      onAppearanceTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tampilan: Mode Terang (Default)'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onSettingsTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengaturan akun dibuka'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onLikedTap: () {
        setState(() {
          _currentNavTab = HomeNavTab.activity;
        });
        _showBars();
      },
      onArchiveTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Arsip postingan & aktivitas dibuka'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onReportTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan masalah terkirim. Terima kasih atas masukan Anda!'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onLogout: widget.onLogout,
    );
  }

  void _handleMapTap() {
    Navigator.push(
      context,
      AppSlidePageRoute(
        builder: (context) => CampusMapScreen(
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _handleSearchTap() {
    Navigator.push(
      context,
      AppSlidePageRoute(
        builder: (context) => SearchScreen(
          onBack: () => Navigator.pop(context),
        ),
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
          caption: caption.isNotEmpty ? caption : 'Postingan baru dari SMKN 8 Semarang',
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
      AppSlidePageRoute(
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
      AppSlidePageRoute(
        builder: (context) => ProfileScreen(
          username: username,
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }


  void _handleImageClick(MarketPostModel item, int imageIndex) {
    MediaLightboxDialog.show(
      context: context,
      images: item.images,
      initialIndex: imageIndex,
      post: item,
      onLikeToggle: _handleLikeToggle,
      onRepostToggle: _handleRepostToggle,
      onPostClick: _handlePostClick,
    );
  }

  List<MarketPostModel> get _displayedPosts {
    if (_activeTab == FeedTab.latest) {
      // For "Terbaru" tab, sort by latest posts
      return _posts.reversed.toList();
    }
    return _posts;
  }

  Widget _buildHomeFeedTab(List<MarketPostModel> posts) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          final double delta = notification.scrollDelta ?? 0.0;
          final double currentOffset = notification.metrics.pixels;

          if (currentOffset <= 20.0) {
            // Reveal bars near top of the feed
            _showBars();
          } else if (delta > 8.0 && currentOffset > 60.0) {
            // User scrolled down into content - hide bottom bar smoothly
            _hideBars();
          } else if (delta < -8.0) {
            // User scrolled up - reveal bottom bar
            _showBars();
          }
        }
        return false;
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Tab Bar Switch ("Untuk Anda" & "Terbaru") - scrolls away naturally with the feed
          SliverToBoxAdapter(
            child: RepaintBoundary(
              child: HomeFeedTabSwitch(
                activeTab: _activeTab,
                onTabChanged: _handleTabChanged,
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
                  const SizedBox(height: 120.0), // Bottom clearance for floating dock & FAB
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final posts = _displayedPosts;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final double fabBottomVisible = (bottomPadding > 0 ? bottomPadding + 8.0 : 18.0) + 62.0 + 12.0;
    final double fabBottomHidden = (bottomPadding > 0 ? bottomPadding + 16.0 : 20.0);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      extendBody: true,
      appBar: HomeFeedHeader(
        title: switch (_currentNavTab) {
          HomeNavTab.home => 'Snaps.',
          HomeNavTab.messages => 'Chat',
          HomeNavTab.activity => 'Aktivitas',
          HomeNavTab.profile => 'Profil',
        },
        onMenuTap: _handleMenuTap,
        onTitleTap: () {
          if (_currentNavTab == HomeNavTab.home) {
            _scrollToTop();
          }
        },
        onSearchTap: _handleSearchTap,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _currentNavTab.index,
              children: [
                _buildHomeFeedTab(posts),
                const DirectMessagesScreen(showBackButton: false, showAppBar: false),
                const ActivityScreen(showAppBar: false),
                ProfileScreen(showAppBar: false, onOpenMenu: _handleMenuTap),
              ],
            ),
          ),
          // Collapsible Bottom Nav & Floating Action Button Overlay
          AnimatedBuilder(
            animation: _barsAnimation,
            builder: (context, _) {
              final double progress = _barsAnimation.value;
              final double currentFabBottom =
                  fabBottomHidden + (fabBottomVisible - fabBottomHidden) * progress;
              final double navOffsetY = (1.0 - progress) * 110.0;
              final double navOpacity = progress.clamp(0.0, 1.0);

              return Stack(
                children: [
                  // Floating Action Button
                  Positioned(
                    right: 20.0,
                    bottom: currentFabBottom,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      scale: _currentNavTab == HomeNavTab.home ? 1.0 : 0.0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        opacity: _currentNavTab == HomeNavTab.home ? 1.0 : 0.0,
                        child: IgnorePointer(
                          ignoring: _currentNavTab != HomeNavTab.home,
                          child: FloatingPlusSquircleButton(
                            onTap: _handleCreatePost,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Floating Bottom Nav Bar
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Transform.translate(
                      offset: Offset(0, navOffsetY),
                      child: Opacity(
                        opacity: navOpacity,
                        child: IgnorePointer(
                          ignoring: progress < 0.1,
                          child: RepaintBoundary(
                            child: HomeBottomNavBar(
                              currentTab: _currentNavTab,
                              hasUnreadMessages: true,
                              unreadMessagesCount: 20,
                              userAvatar:
                                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80',
                              onSearchTap: _handleSearchTap,
                              onPostTap: _handleCreatePost,
                              onTabSelected: (tab) {
                                setState(() {
                                  _currentNavTab = tab;
                                });
                                _showBars();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
