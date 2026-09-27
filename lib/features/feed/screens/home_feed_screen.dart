import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import "package:snapan_market/features/search/screens/search_screen.dart";
import "package:snapan_market/features/map/screens/campus_map_screen.dart";
import "package:snapan_market/features/activity/screens/activity_screen.dart";
import 'package:snapan_market/features/auth/screens/auth_screen.dart';
import 'package:snapan_market/features/auth/components/auth_prompt_overlay.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:snapan_market/core/navigation/app_slide_page_route.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

import 'package:snapan_market/features/feed/components/home_feed_header.dart';
import 'package:snapan_market/features/feed/components/home_feed_tab_switch.dart';
import 'package:snapan_market/features/feed/components/home_bottom_nav_bar.dart';
import 'package:snapan_market/features/feed/components/floating_plus_squircle_button.dart';
import 'package:snapan_market/features/feed/components/floating_marketplace_squircle_button.dart';
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
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  AnimationController? _fabAnimationController;
  Animation<double>? _fabAnimation;
  FeedTab _activeTab = FeedTab.forYou;
  HomeNavTab _currentNavTab = HomeNavTab.home;
  bool _isFabVisible = true;

  // Dynamic Feed Posts list
  List<MarketPostModel> _posts = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  Map<String, dynamic>? _userProfile;
  StreamSubscription<AuthState>? _authSubscription;

  void _initAnimations() {
    _fabAnimationController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      value: 1.0,
    );

    // Transitions.dev Motion Tokens:
    // --ease-smooth-out: cubic-bezier(0.22, 1, 0.36, 1) - entry pop-in
    // --ease-smooth-in: cubic-bezier(0.32, 0, 0.67, 0) - exit dismissal
    const easeSmoothOut = Cubic(0.22, 1.0, 0.36, 1.0);
    const easeIn = Cubic(0.32, 0.0, 0.67, 0.0);

    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController!,
      curve: easeSmoothOut,
      reverseCurve: easeIn,
    );
  }

  Future<void> _fetchPosts({bool isRefresh = false}) async {
    if (!isRefresh) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
      });
    }

    try {
      final livePosts = await SupabaseService.instance.fetchFeedPosts();
      final likedIds = await SupabaseService.instance.fetchLikedPostIds();
      final savedIds = await SupabaseService.instance.fetchBookmarkedPostIds();

      final currentUser = SupabaseService.instance.currentUser;
      if (currentUser != null) {
        SupabaseService.instance.getProfile(currentUser.id).then((p) {
          if (mounted && p != null) {
            setState(() {
              _userProfile = p;
            });
          }
        });
      }

      if (!mounted) return;
      setState(() {
        if (livePosts.isNotEmpty) {
          _posts = livePosts.map((p) {
            return p.copyWith(
              isLiked: likedIds.contains(p.id),
              isSaved: savedIds.contains(p.id),
            );
          }).toList();
        } else {
          // Fallback to rich mock data if table has no posts yet
          _posts = List<MarketPostModel>.from(kMockMarketPosts);
        }
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      debugPrint('Supabase fetch error, fallback to mock data: $e');
      if (!mounted) return;
      setState(() {
        _posts = List<MarketPostModel>.from(kMockMarketPosts);
        _isLoading = false;
        _hasError = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _fetchPosts();
    _authSubscription = SupabaseService.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        _fetchPosts(isRefresh: true);
      }
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    _initAnimations();
  }

  @override
  void dispose() {
    HomeMenuPopover.dismiss();
    _authSubscription?.cancel();
    _fabAnimationController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _hideFab() {
    if (_isFabVisible) {
      _isFabVisible = false;
      _fabAnimationController?.reverse();
    }
  }

  void _showFab() {
    if (!_isFabVisible) {
      _isFabVisible = true;
      _fabAnimationController?.forward();
    }
  }

  // Backward compatibility alias methods
  void _hideBars() => _hideFab();
  void _showBars() => _showFab();

  void _scrollToTop() {
    _showFab();
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleOpenAuth() {
    HomeMenuPopover.dismiss();
    Navigator.push(
      context,
      AppSlidePageRoute(
        builder: (context) => AuthScreen(
          onBack: () => Navigator.pop(context),
          onSuccess: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pendaftaran/Login berhasil! Selamat datang di Snaps SMKN 8.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            _fetchPosts(isRefresh: true);
            setState(() {});
          },
        ),
      ),
    );
  }

  void _handleMenuTap() {
    HomeMenuPopover.toggle(
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
      onAuthTap: _handleOpenAuth,
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
    if (!SupabaseService.instance.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Silakan masuk atau daftar akun untuk membuat postingan.'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Masuk',
            textColor: Colors.amber,
            onPressed: _handleOpenAuth,
          ),
        ),
      );
      return;
    }

    CreatePostModal.show(
      context,
      initialMode: mode,
      currentUserName: _userProfile?['full_name'] as String? ?? 'Siswa Snapan',
      currentUserAvatar: _userProfile?['avatar_url'] as String?,
      onSubmitPost: (data) async {
        final postMode = data['postType'] as String? ?? 'thread';
        final caption = data['caption'] as String? ?? '';
        final title = data['title'] as String?;
        final description = data['description'] as String?;
        final locationTag = data['locationTag'] as String?;
        final topicTag = data['topicTag'] as String?;
        final price = data['price'] as int?;
        final stock = data['stock'] as int?;
        final images = (data['images'] as List<dynamic>?)?.cast<String>() ?? [];

        try {
          final liveCreated = await SupabaseService.instance.createPost(
            postType: postMode,
            caption: caption,
            title: title,
            description: description,
            price: price,
            stock: stock,
            locationTag: locationTag,
            topicTag: topicTag,
            images: images,
          );

          if (mounted) {
            setState(() {
              _posts.insert(0, liveCreated);
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
          }
        } catch (e) {
          debugPrint('Error creating post in Supabase: $e');
          final user = SupabaseService.instance.currentUser;
          final fallbackPost = MarketPostModel(
            id: 'post-local-${DateTime.now().millisecondsSinceEpoch}',
            postType: postMode,
            seller: SellerModel(
              id: user?.id ?? 'current-user-1',
              name: 'Akun Anda',
              avatar: '',
              classGroup: 'Siswa Snapan',
            ),
            caption: caption,
            title: title,
            price: price,
            stock: stock,
            locationTag: locationTag,
            topicTag: topicTag,
            images: images,
            timestamp: 'Baru saja',
          );

          if (mounted) {
            setState(() {
              _posts.insert(0, fallbackPost);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Tersimpan di offline: $e'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
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
      // Fire Supabase toggle asynchronously
      SupabaseService.instance.togglePostLike(updatedItem.id, !updatedItem.isLiked);
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
        builder: (context) => PostDetailScreen(
          post: item,
          onLikeToggle: _handleLikeToggle,
          onBookmarkToggle: (updated) {
            final index = _posts.indexWhere((p) => p.id == updated.id);
            if (index != -1) {
              setState(() {
                _posts[index] = updated;
              });
            }
          },
          onRepostToggle: _handleRepostToggle,
        ),
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
        // Strictly ignore horizontal scrolls (e.g. image carousels) and nested scrollables
        if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
          return false;
        }

        if (notification is ScrollUpdateNotification) {
          final double delta = notification.scrollDelta ?? 0.0;
          final double currentOffset = notification.metrics.pixels;
          final double maxScroll = notification.metrics.maxScrollExtent;

          if (currentOffset <= 10.0) {
            // At or near top of the feed: always show FAB
            _showFab();
          } else if (currentOffset < maxScroll) {
            if (delta > 2.0) {
              // User scrolled down: hide FAB and keep it hidden
              _hideFab();
            } else if (delta < -2.0) {
              // User scrolled up: reveal FAB
              _showFab();
            }
          }
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => _fetchPosts(isRefresh: true),
        color: AppColors.primary,
        backgroundColor: Colors.white,
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

            if (_isLoading && _posts.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              )
            else if (_hasError && _posts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded, size: 52, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 14),
                        const Text(
                          'Koneksi Terputus',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: () => _fetchPosts(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Coba Lagi', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else ...[
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
                        'Keluar Akun',
                        style: TextStyle(
                          fontSize: 13.0,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 160.0), // Bottom clearance for floating dock & vertical duo FAB
                ],
              ),
            ),
          ),
        ],
      ],
    ),
  ),
);
}

  Widget _buildNavTabScreen({required int index, required Widget child}) {
    final int currentIndex = _currentNavTab.index;
    final bool isCurrent = currentIndex == index;

    // Transitions-polish: 08-page-side-by-side
    // Directional page horizontal slide:
    // - Active page (index == currentIndex): centered at Offset.zero with full opacity
    // - Future pages (index > currentIndex): staged offscreen right at Offset(1.0, 0.0)
    // - Past pages (index < currentIndex): retired slightly left in parallax at Offset(-0.25, 0.0) with fade-out
    final Offset targetOffset = isCurrent
        ? Offset.zero
        : (index > currentIndex
            ? const Offset(1.0, 0.0)
            : const Offset(-0.25, 0.0));

    final double targetOpacity = isCurrent
        ? 1.0
        : (index > currentIndex ? 1.0 : 0.0);

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !isCurrent,
        child: AnimatedSlide(
          offset: targetOffset,
          duration: const Duration(milliseconds: 280),
          curve: const Cubic(0.22, 1.0, 0.36, 1.0),
          child: AnimatedOpacity(
            opacity: targetOpacity,
            duration: const Duration(milliseconds: 240),
            curve: const Cubic(0.22, 1.0, 0.36, 1.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: index > 0
                    ? const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 18.0,
                          offset: Offset(-4, 0),
                        ),
                      ]
                    : null,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_fabAnimationController == null || _fabAnimation == null) {
      _initAnimations();
    }
    final posts = _displayedPosts;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final double fabBottomVisible = (bottomPadding > 0 ? bottomPadding + 8.0 : 18.0) + 62.0 + 12.0;
    final bool isUnauthenticated = SupabaseService.instance.currentUser == null;

    final Widget scaffold = Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      extendBody: true,
      appBar: HomeFeedHeader(
        isDark: isUnauthenticated,
        title: switch (_currentNavTab) {
          HomeNavTab.home => 'Snaps.',
          HomeNavTab.messages => 'Chat',
          HomeNavTab.activity => 'Aktivitas',
          HomeNavTab.profile => 'Profil',
        },
        onMenuTap: _handleMenuTap,
        onBackTap: _currentNavTab != HomeNavTab.home
            ? () {
                HapticFeedback.lightImpact();
                setState(() {
                  _currentNavTab = HomeNavTab.home;
                });
                _showFab();
              }
            : null,
        onTitleTap: () {
          if (_currentNavTab == HomeNavTab.home) {
            _scrollToTop();
          }
        },
        onSearchTap: _handleSearchTap,
      ),
      body: Stack(
        children: [
          // Smooth Tab Screens Directional Slide-in (Preserves State)
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                _buildNavTabScreen(
                  index: 0,
                  child: _buildHomeFeedTab(posts),
                ),
                _buildNavTabScreen(
                  index: 1,
                  child: const DirectMessagesScreen(showBackButton: false, showAppBar: false),
                ),
                _buildNavTabScreen(
                  index: 2,
                  child: const ActivityScreen(showAppBar: false),
                ),
                _buildNavTabScreen(
                  index: 3,
                  child: ProfileScreen(showAppBar: false, onOpenMenu: _handleMenuTap),
                ),
              ],
            ),
          ),
          // Animated Floating Action Button Stack (Focused motion on FAB: hide on scroll down, reveal on scroll up/stop)
          Positioned(
            right: 20.0,
            bottom: fabBottomVisible,
            child: AnimatedBuilder(
              animation: _fabAnimationController!,
              builder: (context, _) {
                final double fabProgress = _fabAnimation?.value ?? 1.0;
                final double fabOffsetY = (1.0 - fabProgress) * 48.0;
                final double fabScale = 0.6 + 0.4 * fabProgress;
                final double fabOpacity = fabProgress.clamp(0.0, 1.0);
                final bool isHomeTab = _currentNavTab == HomeNavTab.home;

                return AnimatedOpacity(
                  opacity: isHomeTab ? fabOpacity : 0.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: AnimatedScale(
                    scale: isHomeTab ? fabScale : 0.6,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.bottomRight,
                    child: Transform.translate(
                      offset: Offset(0, fabOffsetY),
                      child: IgnorePointer(
                        ignoring: !isHomeTab || fabProgress < 0.2,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // White Marketplace Squircle Button (Langsung buka Mode Jualan)
                            FloatingMarketplaceSquircleButton(
                              onTap: () => _handleCreatePost(PostMode.product),
                            ),
                            const SizedBox(height: 6.0),
                            // Azure Blue Squircle Button (Buka Buat Utas)
                            FloatingPlusSquircleButton(
                              onTap: () => _handleCreatePost(PostMode.thread),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Fixed Bottom Nav Bar (No scroll motion, persistent dock)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: RepaintBoundary(
              child: HomeBottomNavBar(
                currentTab: _currentNavTab,
                hasUnreadMessages: true,
                unreadMessagesCount: 20,
                userAvatar: _userProfile?['avatar_url'] as String? ??
                    (SupabaseService.instance.currentUser?.userMetadata?['avatar_url'] as String?),
                onSearchTap: _handleSearchTap,
                onPostTap: _handleCreatePost,
                onTabSelected: (tab) {
                  setState(() {
                    _currentNavTab = tab;
                  });
                  _showFab();
                },
              ),
            ),
          ),
        ],
      ),
    );

    if (isUnauthenticated) {
      return Stack(
        fit: StackFit.expand,
        children: [
          scaffold,
          Positioned.fill(
            child: AuthPromptOverlay(
              onNavigateToAuth: _handleOpenAuth,
            ),
          ),
        ],
      );
    }

    return scaffold;
  }
}
