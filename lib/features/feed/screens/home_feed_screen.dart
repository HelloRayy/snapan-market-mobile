import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/feed/components/home_feed_header.dart';
import 'package:snapan_market/features/feed/components/home_feed_tab_switch.dart';
import 'package:snapan_market/features/feed/components/home_bottom_nav_bar.dart';
import 'package:snapan_market/features/feed/components/home_navigation_drawer.dart';
import 'package:snapan_market/features/create_post/screens/create_post_modal.dart';
import 'package:snapan_market/features/create_post/models/create_post_types.dart';

/// Main Home Feed Screen
///
/// Features sticky [HomeFeedHeader] with tactile action controls,
/// sticky [HomeFeedTabSwitch] for "Untuk Anda" and "Terbaru" feed modes,
/// scroll-to-top behavior, and a modular layout ready for upcoming
/// feed slices (Post Cards, Threads, and Bottom Navigation).
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['mode'] == 'product'
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.canvas,
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
      appBar: HomeFeedHeader(
        onMenuTap: _handleMenuTap,
        onTitleTap: _scrollToTop,
        onSearchTap: _handleSearchTap,
      ),
      body: CustomScrollView(
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

          // Placeholder container for upcoming slicing components:
          // Filter Tabs, Feed Post Cards, Threads Discussion, etc.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPastel,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Icon(
                            _activeTab == FeedTab.forYou
                                ? Icons.explore_outlined
                                : Icons.access_time_rounded,
                            color: AppColors.primary,
                            size: 20.0,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Feed Beranda Aktif',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                _activeTab == FeedTab.forYou
                                    ? 'Untuk Anda • Rekomendasi & Diskusi SMKN 8'
                                    : 'Terbaru • Aktivitas & Produk Baru SMKN 8',
                                style: const TextStyle(
                                  fontSize: 13.0,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.onLogout != null) ...[
                      const SizedBox(height: 16.0),
                      const Divider(color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 8.0),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
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
                      ),
                    ],
                  ],
                ),
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

  const _SliverTabSwitchDelegate({required this.child});

  @override
  double get minExtent => 47.0;

  @override
  double get maxExtent => 47.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _SliverTabSwitchDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
