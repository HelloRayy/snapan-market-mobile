import 'package:flutter/material.dart';
import 'package:snapan_market/core/components/snaps_skeleton.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/feed/components/home_feed_tab_switch.dart';
import 'package:snapan_market/features/feed/components/market_post_card.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

class HomeFeedScrollableList extends StatelessWidget {
  final ScrollController scrollController;
  final FeedTab activeTab;
  final ValueChanged<FeedTab> onTabChanged;
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final List<MarketPostModel> posts;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
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
  final VoidCallback? onLogout;

  const HomeFeedScrollableList({
    super.key,
    required this.scrollController,
    required this.activeTab,
    required this.onTabChanged,
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.posts,
    required this.onRefresh,
    required this.onRetry,
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
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
          return false;
        }

        if (notification is ScrollUpdateNotification) {
          final double delta = notification.scrollDelta ?? 0.0;
          final double currentOffset = notification.metrics.pixels;
          final double maxScroll = notification.metrics.maxScrollExtent;

          if (currentOffset <= 10.0) {
            onShowFab();
          } else if (currentOffset < maxScroll) {
            if (delta > 2.0) {
              onHideFab();
            } else if (delta < -2.0) {
              onShowFab();
            }
          }
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: onRefresh,
        color: AppColors.primary,
        backgroundColor: Colors.white,
        child: CustomScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: HomeFeedTabSwitch(
                  activeTab: activeTab,
                  onTabChanged: onTabChanged,
                ),
              ),
            ),
            if (isLoading && posts.isEmpty)
              const SliverToBoxAdapter(
                child: FeedTimelineSkeleton(itemCount: 4),
              )
            else if (hasError && posts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildErrorState(),
              )
            else if (posts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            else ...[
              SliverList.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return MarketPostCard(
                    key: ValueKey(post.id),
                    item: post,
                    onLikeToggle: onLikeToggle,
                    onRepostToggle: onRepostToggle,
                    onPostClick: onPostClick,
                    onTopicClick: onTopicClick,
                    onUserClick: onUserClick,
                    onImageClick: onImageClick,
                    onDeletePost: onDeletePost,
                  );
                },
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
    return Center(
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
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54.0,
              height: 54.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: const Icon(
                Icons.dynamic_feed_rounded,
                size: 28.0,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 14.0),
            const Text(
              'Belum Ada Utas',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6.0),
            const Text(
              'Jadilah yang pertama membuat utas atau menjual karya di SMKN 8!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.0,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
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
          if (onLogout != null) ...[
            const SizedBox(height: 16.0),
            TextButton.icon(
              onPressed: onLogout,
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
          const SizedBox(height: 160.0),
        ],
      ),
    );
  }
}
