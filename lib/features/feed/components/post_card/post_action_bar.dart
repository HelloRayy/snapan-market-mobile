import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/utils/formatters.dart';
import 'package:snapan_market/core/utils/snaps_toast.dart';
import 'package:snapan_market/features/feed/components/post_card/interactive_like_button.dart';
import 'package:snapan_market/features/feed/components/post_card/market_feed_icons.dart';
import 'package:snapan_market/features/feed/components/post_card/tactile_bounce_wrapper.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Interactive action bar with Like, Comment, Repost, Share, and Stock pill
/// Enhanced with micro-motion bounce, spring tactile physics, and sparkles (SNAPS-19).
class PostActionBar extends StatelessWidget {
  final MarketPostModel item;
  final bool isLiked;
  final int likesCount;
  final bool isReposted;
  final int repostsCount;
  final Animation<double>? likeScaleAnim;
  final Animation<double> repostRotateAnim;
  final bool isDetail;
  final VoidCallback onLikeToggle;
  final VoidCallback onRepostToggle;
  final ValueChanged<MarketPostModel>? onPostClick;
  final ValueChanged<MarketPostModel>? onShareClick;

  const PostActionBar({
    super.key,
    required this.item,
    required this.isLiked,
    required this.likesCount,
    required this.isReposted,
    required this.repostsCount,
    this.likeScaleAnim,
    required this.repostRotateAnim,
    this.isDetail = false,
    required this.onLikeToggle,
    required this.onRepostToggle,
    this.onPostClick,
    this.onShareClick,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? AppColors.darkTextSecondary : AppColors.ashGray;
    final counterColor = isDark ? AppColors.darkTextSecondary : AppColors.graphite;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Action buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Interactive Like Button (Elastic spring, particle sparkles, animated counter)
            InteractiveLikeButton(
              isLiked: isLiked,
              likesCount: likesCount,
              onToggle: onLikeToggle,
              iconSize: 19.0,
            ),

            const SizedBox(width: 8.0),

            // 2. Comment Button (Tactile press spring bounce)
            TactileBounceWrapper(
              onTap: () => onPostClick?.call(item),
              child: Container(
                height: 36.0,
                color: Colors.transparent,
                padding: EdgeInsets.symmetric(
                  horizontal: item.commentsCount > 0 ? 8.0 : 6.0,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FeedCommentIcon(
                      size: 18.0,
                      color: iconColor,
                    ),
                    if (item.commentsCount > 0) ...[
                      const SizedBox(width: 4.5),
                      Text(
                        formatCompactNumber(item.commentsCount),
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                          color: counterColor,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8.0),

            // 3. Repost Button (Tactile press spring bounce + smooth rotation)
            TactileBounceWrapper(
              onTap: onRepostToggle,
              child: Container(
                height: 36.0,
                color: Colors.transparent,
                padding: EdgeInsets.symmetric(
                  horizontal: repostsCount > 0 ? 8.0 : 6.0,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RotationTransition(
                      turns: repostRotateAnim,
                      child: FeedRepostIcon(
                        isReposted: isReposted,
                        size: 19.0,
                        activeColor: const Color(0xFF10B981),
                        inactiveColor: iconColor,
                      ),
                    ),
                    if (repostsCount > 0) ...[
                      const SizedBox(width: 4.5),
                      Text(
                        formatCompactNumber(repostsCount),
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: isReposted ? FontWeight.w600 : FontWeight.w400,
                          color: isReposted ? const Color(0xFF10B981) : counterColor,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8.0),

            // 4. Share Button (Tactile press spring bounce)
            TactileBounceWrapper(
              onTap: () {
                if (onShareClick != null) {
                  onShareClick!(item);
                } else {
                  Clipboard.setData(ClipboardData(text: 'https://snapan.id/post/${item.id}'));
                  SnapsToast.show(context, 'Tautan disalin ke papan klip');
                }
              },
              child: Container(
                height: 36.0,
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                alignment: Alignment.center,
                child: FeedShareIcon(
                  size: 18.0,
                  color: iconColor,
                ),
              ),
            ),
          ],
        ),

        // 5. Trailing metrics: Views count (Hanya di Detail Page, clean minimalis) & Stock Indicator Pill
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Views Counter (HANYA MUNCUL DI DETAIL SCREEN, TIDAK DI FEED BERANDA)
            if (isDetail) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.eye,
                      size: 14.5,
                      color: iconColor,
                    ),
                    const SizedBox(width: 4.5),
                    Text(
                      formatCompactNumber(item.viewsCount),
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        color: counterColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.isProduct && item.stock != null && item.stock! > 0)
                const SizedBox(width: 8.0),
            ],

            // Stock Indicator Pill (for products with stock > 0)
            if (item.isProduct && item.stock != null && item.stock! > 0)
              Container(
                constraints: const BoxConstraints(minHeight: 26.0),
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1D1F1F)
                      : const Color(0xFFF1F5F9).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(13.0),
                  border: Border.all(
                    color: isDark
                        ? const Color(0x1AFFFFFF)
                        : const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FeedBoxIcon(
                      size: 14.0,
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF71717A),
                      strokeWidth: 1.8,
                    ),
                    const SizedBox(width: 4.5),
                    Text(
                      '${item.stock}',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E293B),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
