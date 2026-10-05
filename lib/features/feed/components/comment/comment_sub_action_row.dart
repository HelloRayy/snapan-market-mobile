import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/features/feed/components/comment/comment_heart_button.dart';
import 'package:snapan_market/features/feed/components/market_feed_icons.dart';

/// Simplified Minimalist Action Row under comment text
/// Displays: [♡ (count)]   [💬] (icon-only without text labels, repost removed)
class CommentSubActionRow extends StatelessWidget {
  final dynamic timestamp;
  final int likesCount;
  final bool isLiked;
  final VoidCallback onReply;
  final VoidCallback? onLike;
  final VoidCallback? onOptions;
  final VoidCallback? onRepost;

  const CommentSubActionRow({
    super.key,
    required this.timestamp,
    required this.likesCount,
    this.isLiked = false,
    required this.onReply,
    this.onLike,
    this.onOptions,
    this.onRepost,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Suka / Love Icon
          if (onLike != null)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onLike!();
              },
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CommentHeartButton(
                    isLiked: isLiked,
                    onToggle: onLike!,
                    size: 16.0,
                    hitBoxSize: 24.0,
                  ),
                  if (likesCount > 0) ...[
                    const SizedBox(width: 4.0),
                    Text(
                      '$likesCount',
                      style: TextStyle(
                        fontFamily: 'SFPro',
                        fontSize: 12.0,
                        fontWeight: isLiked ? FontWeight.w600 : FontWeight.w500,
                        color: isLiked ? const Color(0xFFF43F5E) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const FeedHeartIcon(
                  isLiked: false,
                  size: 16.0,
                  inactiveColor: Color(0xFF64748B),
                ),
                if (likesCount > 0) ...[
                  const SizedBox(width: 4.0),
                  Text(
                    '$likesCount',
                    style: const TextStyle(
                      fontFamily: 'SFPro',
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),

          const SizedBox(width: 14.0),

          // 2. Balas / Comment Icon Only
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onReply();
            },
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
              child: Icon(
                CupertinoIcons.chat_bubble,
                size: 16.0,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
