import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/components/update_info_bottom_sheet.dart';
import 'package:snapan_market/core/navigation/app_slide_page_route.dart';
import 'package:snapan_market/core/services/app_update_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/utils/snaps_toast.dart';
import 'package:snapan_market/features/activity/screens/activity_screen.dart';
import 'package:snapan_market/features/auth/components/auth_prompt_overlay.dart';
import 'package:snapan_market/features/auth/screens/auth_screen.dart';
import 'package:snapan_market/features/create_post/models/create_post_types.dart';
import 'package:snapan_market/features/create_post/screens/create_post_modal.dart';
import 'package:snapan_market/features/feed/components/home_bottom_nav_bar.dart';
import 'package:snapan_market/features/feed/components/home_dock_overlay.dart';
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
    _drawerController?.close();
    try {
      final update = await AppUpdateService.instance.checkForUpdate(isManual: true);
      if (!mounted) return;
      if (update != null) {
        final info = await AppUpdateService.instance.getPackageInfo();
        if (!mounted) return;
        UpdateInfoBottomSheet.show(context, update: update, currentVersionName: info.version);
      } else {
        SnapsToast.show(context, 'Aplikasi Anda sudah versi terbaru.', hasBottomNav: true);
      }
    } catch (e) {
      debugPrint('Manual update check error: $e');
    }
  }

  @override
  void dispose() {
    _drawerController?.dispose();
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
    _drawerController?.close();
    HomeMenuPopover.dismiss();
    Navigator.push(
      context,
      AppSlidePageRoute(
        builder: (context) => AuthScreen(
          onBack: () => Navigator.pop(context),
          onSuccess: () {
            Navigator.pop(context);
            SnapsToast.show(context, 'Selamat datang di Snaps SMKN 8.', hasBottomNav: true);
            _feedController.fetchPosts(isRefresh: true);
          },
        ),
      ),
    );
  }

  void _handleCreatePost([PostMode mode = PostMode.thread]) {
    if (!SupabaseService.instance.isAuthenticated) {
      SnapsToast.show(context, 'Silakan masuk untuk membuat postingan.', hasBottomNav: true, action: SnackBarAction(label: 'Masuk', textColor: Colors.amber, onPressed: _handleOpenAuth));
      return;
    }
    final name = (_feedController.userProfile?['full_name'] as String?)?.isNotEmpty == true
        ? _feedController.userProfile!['full_name'] as String
        : ((_feedController.userProfile?['username'] as String?)?.isNotEmpty == true ? '@${_feedController.userProfile!['username']}' : '');
    CreatePostModal.show(context, initialMode: mode, currentUserName: name, currentUserAvatar: _feedController.userProfile?['avatar_url'] as String?, onSubmitPost: _feedController.createPost);
  }

  void _handlePostClick(MarketPostModel item) async {
    final result = await Navigator.push(context, AppSlidePageRoute(builder: (context) => PostDetailScreen(post: item, onLikeToggle: _feedController.toggleLike, onBookmarkToggle: _feedController.updatePost, onRepostToggle: _feedController.toggleRepost, onDeletePost: _feedController.deletePost)));
    if (result is Map) {
      if (result['deleted'] == true && result['postId'] is String) {
        _feedController.removePostById(result['postId'] as String);
      } else if (result['updatedPost'] is MarketPostModel) {
        _feedController.updatePost(result['updatedPost'] as MarketPostModel);
      }
    }
  }

  List<MarketPostModel> get _displayedPosts => _activeTab == FeedTab.market
      ? _feedController.posts.where((p) => p.postType == 'product' || (p.price != null && p.price! > 0)).toList()
      : _feedController.posts;

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
      drawerScrimColor: Colors.black.withValues(alpha: 0.35),
      drawerEdgeDragWidth: 28.0,
      drawer: HomeNavDrawer(
        userProfile: _feedController.userProfile,
        onAppearanceTap: () {},
        onSettingsTap: () {},
        onLikedTap: () {
          Navigator.of(context).maybePop();
          setState(() => _currentNavTab = HomeNavTab.activity);
        },
        onArchiveTap: () {},
        onReportTap: () {},
        onCheckUpdateTap: _handleManualCheckUpdate,
        onAuthTap: _handleOpenAuth,
        onLogout: widget.onLogout,
        onClose: () => Navigator.of(context).maybePop(),
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
              onVotePoll: (post, optionIds) => _feedController.votePoll(post.id, optionIds),
              onLogout: widget.onLogout,
            ),
            messagesTab: const DirectMessagesScreen(showBackButton: false, showAppBar: false),
            activityTab: const ActivityScreen(showAppBar: false),
            profileTab: ProfileScreen(key: _profileKey, showAppBar: false, onOpenMenu: () => _scaffoldKey.currentState?.openDrawer()),
          ),
          HomeDockOverlay(
            currentNavTab: _currentNavTab,
            fabAnimationController: _fabAnimationController!,
            fabAnimation: _fabAnimation,
            fabBottom: fabBottom,
            onCreatePost: _handleCreatePost,
            onTabSelected: (tab) {
              setState(() => _currentNavTab = tab);
              _showFab();
              if (tab == HomeNavTab.profile) _profileKey.currentState?.reloadProfile();
            },
            userAvatar: _feedController.userProfile?['avatar_url'] as String? ??
                (SupabaseService.instance.currentUser?.userMetadata?['avatar_url'] as String?),
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
