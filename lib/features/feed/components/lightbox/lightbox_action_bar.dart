import 'package:flutter/material.dart';
import 'package:snapan_market/core/utils/formatters.dart';
import 'package:snapan_market/features/feed/components/post_card/market_feed_icons.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Floating bottom action bar for Media Lightbox:
/// Like (animated), Comment, Repost, Share buttons.
class LightboxActionBar extends StatelessWidget {
  final MarketPostModel post;
  final double bottomPadding;
  final bool isLiked;
  final int likesCount;
  final bool isReposted;
  final int repostsCount;
  final Animation<double> likeScaleAnim;
  final VoidCallback onLikeToggle;
  final VoidCallback onCommentClick;
  final VoidCallback onRepostToggle;
  final VoidCallback onShareClick;

  const LightboxActionBar({
    super.key,
    required this.post,
    required this.bottomPadding,
    required this.isLiked,
    required this.likesCount,
    required this.isReposted,
    required this.repostsCount,
    required this.likeScaleAnim,
    required this.onLikeToggle,
    required this.onCommentClick,
    required this.onRepostToggle,
    required this.onShareClick,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final inactiveIconColor = isDark
        ? Colors.white.withValues(alpha: 0.85)
        : const Color(0xFF334155);

    final countTextColor = isDark
        ? Colors.white.withValues(alpha: 0.85)
        : const Color(0xFF475569);

    final likeActiveColor = isDark
        ? const Color(0xFFF43F5E)
        : const Color(0xFFE11D48);

    const repostActiveColor = Color(0xFF10B981);

    final gradientColors = isDark
        ? [
            const Color(0xFF0B0F17).withValues(alpha: 0.95),
            const Color(0xFF0B0F17).withValues(alpha: 0.70),
            Colors.transparent,
          ]
        : [
            Colors.white.withValues(alpha: 0.98),
            Colors.white.withValues(alpha: 0.85),
            Colors.white.withValues(alpha: 0.0),
          ];

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: 24.0,
          bottom: bottomPadding > 0 ? bottomPadding + 8.0 : 16.0,
          left: 20.0,
          right: 20.0,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: gradientColors,
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Like Button
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onLikeToggle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ScaleTransition(
                          scale: likeScaleAnim,
                          child: FeedHeartIcon(
                            isLiked: isLiked,
                            size: 20.0,
                            activeColor: likeActiveColor,
                            inactiveColor: inactiveIconColor,
                          ),
                        ),
                        if (likesCount > 0) ...[
                          const SizedBox(width: 5.0),
                          Text(
                            formatCompactNumber(likesCount),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isLiked ? FontWeight.w600 : FontWeight.w400,
                              color: isLiked ? likeActiveColor : countTextColor,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12.0),

              // Comment Button
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onCommentClick,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FeedCommentIcon(
                          size: 19.0,
                          color: inactiveIconColor,
                        ),
                        if (post.commentsCount > 0) ...[
                          const SizedBox(width: 5.0),
                          Text(
                            formatCompactNumber(post.commentsCount),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w400,
                              color: countTextColor,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12.0),

              // Repost Button
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onRepostToggle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FeedRepostIcon(
                          isReposted: isReposted,
                          size: 19.0,
                          activeColor: repostActiveColor,
                          inactiveColor: inactiveIconColor,
                        ),
                        if (repostsCount > 0) ...[
                          const SizedBox(width: 5.0),
                          Text(
                            formatCompactNumber(repostsCount),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isReposted ? FontWeight.w600 : FontWeight.w400,
                              color: isReposted
                                  ? repostActiveColor
                                  : countTextColor,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12.0),

              // Share Button
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onShareClick,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    child: FeedShareIcon(
                      size: 19.0,
                      color: inactiveIconColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
