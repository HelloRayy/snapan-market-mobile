import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/components/update_info_bottom_sheet.dart';
import 'package:snapan_market/core/navigation/app_slide_page_route.dart';
import 'package:snapan_market/core/services/app_update_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/features/activity/screens/activity_screen.dart';
import 'package:snapan_market/features/auth/components/auth_prompt_overlay.dart';
import 'package:snapan_market/features/auth/screens/auth_screen.dart';
import 'package:snapan_market/features/create_post/models/create_post_types.dart';
import 'package:snapan_market/features/create_post/screens/create_post_modal.dart';
import 'package:snapan_market/features/feed/components/home_bottom_nav_bar.dart';
import 'package:snapan_market/features/feed/components/home_feed_fab_group.dart';
import 'package:snapan_market/features/feed/components/home_feed_header.dart';
import 'package:snapan_market/features/feed/components/home_feed_scrollable_list.dart';
import 'package:snapan_market/features/feed/components/home_feed_tab_switch.dart';
import 'package:snapan_market/features/feed/components/home_menu_popover.dart';
import 'package:snapan_market/features/feed/components/home_nav_drawer.dart';
import 'package:snapan_market/features/feed/components/home_nav_tab_switcher.dart';
import 'package:snapan_market/features/feed/components/media_lightbox_dialog.dart';
import 'package:snapan_market/features/feed/controllers/home_feed_controller.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';
import 'package:snapan_market/features/feed/screens/post_detail_screen.dart';
import 'package:snapan_market/features/messages/screens/direct_messages_screen.dart';
import 'package:snapan_market/features/profile/screens/profile_screen.dart';
import 'package:snapan_market/features/search/screens/search_screen.dart';

/// Main Home Feed Screen (<300 lines orchestrator).
class HomeFeedScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const HomeFeedScreen({super.key, this.onLogout});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ProfileScreenState> _profileKey = GlobalKey<ProfileScreenState>();
  final ScrollController _scrollController = ScrollController();
  final HomeFeedController _feedController = HomeFeedController();

  AnimationController? _fabAnimationController;
  Animation<double>? _fabAnimation;
  FeedTab _activeTab = FeedTab.forYou;
  HomeNavTab _currentNavTab = HomeNavTab.home;
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _feedController.init();
    _feedController.addListener(() {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForAppUpdate();
    });
  }

  void _initAnimations() {
    _fabAnimationController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      value: 1.0,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController!,
      curve: const Cubic(0.22, 1.0, 0.36, 1.0),
      reverseCurve: const Cubic(0.32, 0.0, 0.67, 0.0),
    );
  }

  Future<void> _checkForAppUpdate() async {
    try {
      final update = await AppUpdateService.instance.checkForUpdate(isManual: false);
      if (update != null && mounted) {
        final info = await AppUpdateService.instance.getPackageInfo();
        if (!mounted) return;
        UpdateInfoBottomSheet.show(context, update: update, currentVersionName: info.version);
      }
    } catch (e) {
      debugPrint('Update check error: $e');
    }
  }

  Future<void> _handleManualCheckUpdate() async {
    Navigator.of(context).maybePop();
    try {
      final update = await AppUpdateService.instance.checkForUpdate(isManual: true);
      if (!mounted) return;
      if (update != null) {
        final info = await AppUpdateService.instance.getPackageInfo();
        if (!mounted) return;
        UpdateInfoBottomSheet.show(context, update: update, currentVersionName: info.version);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aplikasi Anda sudah versi terbaru.'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Manual update check error: $e');
    }
  }

  @override
  void dispose() {
    HomeMenuPopover.dismiss();
    _feedController.dispose();
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

  void _scrollToTop() {
    _showFab();
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
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
              const SnackBar(content: Text('Selamat datang di Snaps SMKN 8.'), behavior: SnackBarBehavior.floating),
            );
            _feedController.fetchPosts(isRefresh: true);
          },
        ),
      ),
    );
  }

  void _handleCreatePost([PostMode mode = PostMode.thread]) {
    if (!SupabaseService.instance.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Silakan masuk untuk membuat postingan.'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(label: 'Masuk', textColor: Colors.amber, onPressed: _handleOpenAuth),
        ),
      );
      return;
    }

    CreatePostModal.show(
      context,
      initialMode: mode,
      currentUserName: (_feedController.userProfile?['full_name'] as String?)?.isNotEmpty == true
          ? _feedController.userProfile!['full_name'] as String
          : ((_feedController.userProfile?['username'] as String?)?.isNotEmpty == true
              ? '@${_feedController.userProfile!['username']}'
              : ''),
      currentUserAvatar: _feedController.userProfile?['avatar_url'] as String?,
      onSubmitPost: (data) => _feedController.createPost(data),
    );
  }

  void _handlePostClick(MarketPostModel item) async {
    final result = await Navigator.push(
      context,
      AppSlidePageRoute(
        builder: (context) => PostDetailScreen(
          post: item,
          onLikeToggle: _feedController.toggleLike,
          onBookmarkToggle: _feedController.updatePost,
          onRepostToggle: _feedController.toggleRepost,
          onDeletePost: _feedController.deletePost,
        ),
      ),
    );

    if (result is Map && result['deleted'] == true) {
      final postId = result['postId'] as String?;
      if (postId != null) _feedController.removePostById(postId);
    }
  }

  List<MarketPostModel> get _displayedPosts {
    if (_activeTab == FeedTab.market) {
      return _feedController.posts
          .where((p) => p.postType == 'product' || (p.price != null && p.price! > 0))
          .toList();
    }
    return _feedController.posts;
  }

  @override
  Widget build(BuildContext context) {
    if (_fabAnimationController == null || _fabAnimation == null) _initAnimations();
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final double fabBottom = (bottomPadding > 0 ? bottomPadding + 8.0 : 18.0) + 62.0 + 12.0;
    final bool isUnauthenticated = SupabaseService.instance.currentUser == null;

    final scaffold = Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      extendBody: true,
      drawer: HomeNavDrawer(
        userProfile: _feedController.userProfile,
        onAppearanceTap: () {},
        onSettingsTap: () {},
        onLikedTap: () => setState(() => _currentNavTab = HomeNavTab.activity),
        onArchiveTap: () {},
        onReportTap: () {},
        onCheckUpdateTap: _handleManualCheckUpdate,
        onAuthTap: _handleOpenAuth,
        onLogout: widget.onLogout,
      ),
      appBar: HomeFeedHeader(
        isDark: false,
        title: switch (_currentNavTab) {
          HomeNavTab.home => 'Snaps.',
          HomeNavTab.messages => 'Chat',
          HomeNavTab.activity => 'Aktivitas',
          HomeNavTab.profile => 'Profil',
        },
        onMenuTap: () {
          HapticFeedback.lightImpact();
          _scaffoldKey.currentState?.openDrawer();
        },
        onBackTap: _currentNavTab != HomeNavTab.home ? () => setState(() => _currentNavTab = HomeNavTab.home) : null,
        onTitleTap: () => _currentNavTab == HomeNavTab.home ? _scrollToTop() : null,
        onSearchTap: () => Navigator.push(context, AppSlidePageRoute(builder: (_) => SearchScreen(onBack: () => Navigator.pop(context)))),
      ),
      body: Stack(
        children: [
          HomeNavTabSwitcher(
            currentNavTab: _currentNavTab,
            feedTab: HomeFeedScrollableList(
              scrollController: _scrollController,
              activeTab: _activeTab,
              onTabChanged: (t) => setState(() => _activeTab = t),
              isLoading: _feedController.isLoading,
              hasError: _feedController.hasError,
              errorMessage: _feedController.errorMessage,
              posts: _displayedPosts,
              onRefresh: () => _feedController.fetchPosts(isRefresh: true),
              onRetry: () => _feedController.fetchPosts(),
              onScrollToTop: _scrollToTop,
              onShowFab: _showFab,
              onHideFab: _hideFab,
              onLikeToggle: _feedController.toggleLike,
              onRepostToggle: _feedController.toggleRepost,
              onPostClick: _handlePostClick,
              onTopicClick: (_) {},
              onUserClick: (u) => Navigator.push(context, AppSlidePageRoute(builder: (_) => ProfileScreen(username: u, onBack: () => Navigator.pop(context)))),
              onImageClick: (item, idx) => MediaLightboxDialog.show(context: context, images: item.images, initialIndex: idx, post: item, onLikeToggle: _feedController.toggleLike, onRepostToggle: _feedController.toggleRepost, onPostClick: _handlePostClick),
              onDeletePost: _feedController.deletePost,
              onLogout: widget.onLogout,
            ),
            messagesTab: const DirectMessagesScreen(showBackButton: false, showAppBar: false),
            activityTab: const ActivityScreen(showAppBar: false),
            profileTab: ProfileScreen(key: _profileKey, showAppBar: false, onOpenMenu: () => _scaffoldKey.currentState?.openDrawer()),
          ),
          HomeFeedFabGroup(
            currentNavTab: _currentNavTab,
            fabAnimationController: _fabAnimationController!,
            fabAnimation: _fabAnimation,
            fabBottomVisible: fabBottom,
            onCreatePost: _handleCreatePost,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: RepaintBoundary(
              child: HomeBottomNavBar(
                currentTab: _currentNavTab,
                hasUnreadMessages: true,
                unreadMessagesCount: 20,
                userAvatar: _feedController.userProfile?['avatar_url'] as String? ??
                    (SupabaseService.instance.currentUser?.userMetadata?['avatar_url'] as String?),
                onSearchTap: () => Navigator.push(
                  context,
                  AppSlidePageRoute(builder: (context) => SearchScreen(onBack: () => Navigator.pop(context))),
                ),
                onPostTap: _handleCreatePost,
                onTabSelected: (tab) {
                  setState(() => _currentNavTab = tab);
                  _showFab();
                  if (tab == HomeNavTab.profile) _profileKey.currentState?.reloadProfile();
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
          Positioned.fill(child: AuthPromptOverlay(onNavigateToAuth: _handleOpenAuth)),
        ],
      );
    }
    return scaffold;
  }
}
