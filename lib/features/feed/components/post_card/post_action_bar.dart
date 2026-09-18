import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/utils/formatters.dart';
import 'package:snapan_market/features/feed/components/market_feed_icons.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Interactive action bar with Like, Comment, Repost, Share, and Stock pill
class PostActionBar extends StatelessWidget {
  final MarketPostModel item;
  final bool isLiked;
  final int likesCount;
  final bool isReposted;
  final int repostsCount;
  final Animation<double> likeScaleAnim;
  final Animation<double> repostRotateAnim;
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
    required this.likeScaleAnim,
    required this.repostRotateAnim,
    required this.onLikeToggle,
    required this.onRepostToggle,
    this.onPostClick,
    this.onShareClick,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Action buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Like Button (Zero background splash)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onLikeToggle,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 36.0,
                  color: Colors.transparent,
                  padding: EdgeInsets.only(
                    left: 0.0,
                    right: likesCount > 0 ? 8.0 : 4.0,
                  ),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: likeScaleAnim,
                        child: FeedHeartIcon(
                          isLiked: isLiked,
                          size: 19.0,
                          activeColor: const Color(0xFFE11D48),
                          inactiveColor: const Color(0xFF334155),
                        ),
                      ),
                      if (likesCount > 0) ...[
                        const SizedBox(width: 4.5),
                        Text(
                          formatCompactNumber(likesCount),
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: isLiked ? FontWeight.w600 : FontWeight.w400,
                            color: isLiked ? const Color(0xFFE11D48) : const Color(0xFF475569),
                            fontFeatures: const [FontFeature.tabularFigures()],
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8.0),

            // 2. Comment Button (Zero background splash)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onPostClick?.call(item),
                behavior: HitTestBehavior.opaque,
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
                      const FeedCommentIcon(
                        size: 18.0,
                        color: Color(0xFF334155),
                      ),
                      if (item.commentsCount > 0) ...[
                        const SizedBox(width: 4.5),
                        Text(
                          formatCompactNumber(item.commentsCount),
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF475569),
                            fontFeatures: [FontFeature.tabularFigures()],
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8.0),

            // 3. Repost Button (Zero background splash)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onRepostToggle,
                behavior: HitTestBehavior.opaque,
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
                          inactiveColor: const Color(0xFF334155),
                        ),
                      ),
                      if (repostsCount > 0) ...[
                        const SizedBox(width: 4.5),
                        Text(
                          formatCompactNumber(repostsCount),
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: isReposted ? FontWeight.w600 : FontWeight.w400,
                            color: isReposted ? const Color(0xFF10B981) : const Color(0xFF475569),
                            fontFeatures: const [FontFeature.tabularFigures()],
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8.0),

            // 4. Share Button (Zero background splash)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  if (onShareClick != null) {
                    onShareClick!(item);
                  } else {
                    Clipboard.setData(ClipboardData(text: 'https://snapan.id/post/${item.id}'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tautan disalin ke papan klip')),
                    );
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 36.0,
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  alignment: Alignment.center,
                  child: const FeedShareIcon(
                    size: 18.0,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
            ),
          ],
        ),

        // 5. Stock Indicator Pill (for products with stock > 0)
        if (item.isProduct && item.stock != null && item.stock! > 0)
          Container(
            constraints: const BoxConstraints(minHeight: 26.0),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9).withOpacity(0.9),
              borderRadius: BorderRadius.circular(13.0),
              border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.8), width: 1.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const FeedBoxIcon(
                  size: 14.0,
                  color: Color(0xFF71717A),
                  strokeWidth: 1.8,
                ),
                const SizedBox(width: 4.5),
                Text(
                  '${item.stock}',
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
