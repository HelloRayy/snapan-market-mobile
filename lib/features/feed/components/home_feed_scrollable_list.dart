import 'package:flutter/material.dart';
import 'package:snapan_market/core/constants/app_constants.dart';
import 'package:snapan_market/core/components/snaps_skeleton.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/feed/components/navigation/home_feed_tab_switch.dart';
import 'package:snapan_market/features/feed/components/post_card/market_post_card.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Threads-Style Feed Container with Tap-Only Mode Switcher (SNAPS-26).
///
/// Eliminates horizontal gesture arena conflicts to guarantee 100% solid,
/// unhindered vertical scrolling while preserving independent scroll states
/// across "Untuk Anda" (All posts) and "Jualan" (Product posts).
class HomeFeedScrollableList extends StatefulWidget {
  final FeedTab activeTab;
  final ValueChanged<FeedTab> onTabChanged;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasError;
  final String errorMessage;
  final List<MarketPostModel> allPosts;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final VoidCallback? onLoadMore;
  final VoidCallback onScrollToTop;
  final VoidCallback onShowFab;
  final VoidCallback onHideFab;
  final ValueChanged<MarketPostModel> onLikeToggle;
  final ValueChanged<MarketPostModel> onRepostToggle;
  final ValueChanged<MarketPostModel> onPostClick;
  final ValueChanged<String> onTopicClick;
  final ValueChanged<String> onUserClick;
  final void Function(MarketPostModel, int) onImageClick;
  final ValueChanged<MarketPostModel> onDeletePost;
  final void Function(MarketPostModel, List<String>)? onVotePoll;
  final VoidCallback? onLogout;

  const HomeFeedScrollableList({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
    required this.isLoading,
    this.isLoadingMore = false,
    required this.hasError,
    required this.errorMessage,
    required this.allPosts,
    required this.onRefresh,
    required this.onRetry,
    this.onLoadMore,
    required this.onScrollToTop,
    required this.onShowFab,
    required this.onHideFab,
    required this.onLikeToggle,
    required this.onRepostToggle,
    required this.onPostClick,
    required this.onTopicClick,
    required this.onUserClick,
    required this.onImageClick,
    required this.onDeletePost,
    this.onVotePoll,
    this.onLogout,
  });

  @override
  State<HomeFeedScrollableList> createState() => HomeFeedScrollableListState();
}

class HomeFeedScrollableListState extends State<HomeFeedScrollableList> {
  late final ScrollController _forYouScrollController;
  late final ScrollController _marketScrollController;

  @override
  void initState() {
    super.initState();
    _forYouScrollController = ScrollController();
    _marketScrollController = ScrollController();
  }

  @override
  void dispose() {
    _forYouScrollController.dispose();
    _marketScrollController.dispose();
    super.dispose();
  }

  /// Public imperative method to scroll the currently visible tab to top
  void scrollToTop() {
    final activeController = widget.activeTab == FeedTab.forYou
        ? _forYouScrollController
        : _marketScrollController;
    if (activeController.hasClients) {
      activeController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final forYouPosts = widget.allPosts;

    if (!AppConstants.enableCommerceMode) {
      return _buildTimelinePage(
        key: const PageStorageKey('timeline_for_you'),
        scrollController: _forYouScrollController,
        posts: forYouPosts,
        isMarket: false,
      );
    }

    final marketPosts = widget.allPosts
        .where((p) => p.postType == 'product' || (p.price != null && p.price! > 0))
        .toList();

    return Column(
      children: [
        // Pinned Header Tab Switch with Polished Spring Indicator
        RepaintBoundary(
          child: HomeFeedTabSwitch(
            activeTab: widget.activeTab,
            onTabChanged: widget.onTabChanged,
          ),
        ),

        // Pure Vertical Timeline Container with Zero Horizontal Gesture Conflicts
        Expanded(
          child: IndexedStack(
            index: widget.activeTab == FeedTab.forYou ? 0 : 1,
            children: [
              _buildTimelinePage(
                key: const PageStorageKey('timeline_for_you'),
                scrollController: _forYouScrollController,
                posts: forYouPosts,
                isMarket: false,
              ),
              _buildTimelinePage(
                key: const PageStorageKey('timeline_market'),
                scrollController: _marketScrollController,
                posts: marketPosts,
                isMarket: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelinePage({
    required Key key,
    required ScrollController scrollController,
    required List<MarketPostModel> posts,
    required bool isMarket,
  }) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.depth != 0 ||
            notification.metrics.axis != Axis.vertical) {
          return false;
        }

        if (notification is ScrollUpdateNotification) {
          final double delta = notification.scrollDelta ?? 0.0;
          final double currentOffset = notification.metrics.pixels;
          final double maxScroll = notification.metrics.maxScrollExtent;

          if (currentOffset <= 10.0) {
            widget.onShowFab();
          } else if (currentOffset < maxScroll) {
            if (delta > 2.0) {
              widget.onHideFab();
            } else if (delta < -2.0) {
              widget.onShowFab();
            }
          }

          // Trigger infinite scroll threshold (75% of list length)
          if (maxScroll > 0 && currentOffset >= maxScroll * 0.75) {
            widget.onLoadMore?.call();
          }
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: widget.onRefresh,
        color: AppColors.primary,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurfaceElevated
            : Colors.white,
        child: CustomScrollView(
          key: key,
          controller: scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            if (widget.isLoading && posts.isEmpty)
              const SliverToBoxAdapter(
                child: FeedTimelineSkeleton(itemCount: 4),
              )
            else if (widget.hasError && posts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildErrorState(),
              )
            else if (posts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(isMarket: isMarket),
              )
            else ...[
              SliverList.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return MarketPostCard(
                    key: ValueKey(post.id),
                    item: post,
                    onLikeToggle: widget.onLikeToggle,
                    onRepostToggle: widget.onRepostToggle,
                    onPostClick: widget.onPostClick,
                    onTopicClick: widget.onTopicClick,
                    onUserClick: widget.onUserClick,
                    onImageClick: widget.onImageClick,
                    onDeletePost: widget.onDeletePost,
                    onVotePoll: widget.onVotePoll,
                  );
                },
              ),
              if (widget.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: SizedBox(
                        width: 22.0,
                        height: 22.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: _buildFooter(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 100.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 52, color: Color(0xFF94A3B8)),
            const SizedBox(height: 14),
            Text(
              'Koneksi Terputus',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: widget.onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Coba Lagi',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({required bool isMarket}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 100.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54.0,
              height: 54.0,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: Icon(
                isMarket
                    ? Icons.storefront_outlined
                    : Icons.dynamic_feed_rounded,
                size: 28.0,
                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 14.0),
            Text(
              isMarket ? 'Belum Ada Jualan' : 'Belum Ada Postingan',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              isMarket
                  ? 'Belum ada produk atau karya yang dijual saat ini. Mulai jual karyamu!'
                  : 'Jadilah yang pertama membuat utas atau menjual karya di SMKN 8!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.0,
                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: AppColors.adaptiveCanvas(context),
      padding: const EdgeInsets.fromLTRB(16.0, 28.0, 16.0, 100.0),
      child: Column(
        children: [
          Container(
            width: 32.0,
            height: 3.0,
            decoration: BoxDecoration(
              color: isDark ? const Color(0x1AFFFFFF) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          const SizedBox(height: 14.0),
          Text(
            'Scroll ke bawah untuk memuat postingan baru',
            style: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
            ),
          ),
          if (widget.onLogout != null) ...[
            const SizedBox(height: 16.0),
            TextButton.icon(
              onPressed: widget.onLogout,
              icon: Icon(
                Icons.logout_rounded,
                size: 16.0,
                color: isDark ? AppColors.darkTextSecondary : AppColors.muted,
              ),
              label: const Text(
                'Keluar Akun',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
