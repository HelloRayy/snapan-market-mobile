import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/utils/formatters.dart';
import 'package:snapan_market/features/feed/components/comment/comment_heart_button.dart';

/// Minimalist Instagram-Style Sub-Action Row under comment text
/// Displays: [Timestamp (e.g. 2j)]   [Balas]   [Love + LikesCount]   [•••]
class CommentSubActionRow extends StatelessWidget {
  final dynamic timestamp;
  final int likesCount;
  final bool isLiked;
  final VoidCallback onReply;
  final VoidCallback? onLike;
  final VoidCallback? onOptions;

  const CommentSubActionRow({
    super.key,
    required this.timestamp,
    required this.likesCount,
    this.isLiked = false,
    required this.onReply,
    this.onLike,
    this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Timestamp
        Text(
          formatSmartTimestamp(timestamp),
          style: const TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.normal,
            color: Color(0xFF94A3B8),
          ),
        ),

        // 2. Balas (Reply CTA)
        const SizedBox(width: 14.0),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onReply();
          },
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 2.0),
            child: Text(
              'Balas',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ),

        // 3. Love / Suka Button sejajar dengan Balas
        if (onLike != null) ...[
          const SizedBox(width: 12.0),
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
                  size: 13.5,
                  hitBoxSize: 22.0,
                ),
                if (likesCount > 0) ...[
                  const SizedBox(width: 3.5),
                  Text(
                    '$likesCount',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: isLiked ? const Color(0xFFF43F5E) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ] else if (likesCount > 0) ...[
          const SizedBox(width: 14.0),
          Text(
            '$likesCount suka',
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],

        // 4. Subtle 3-dots Menu for Sheet Options
        if (onOptions != null) ...[
          const SizedBox(width: 12.0),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onOptions!();
            },
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
              child: Icon(
                Icons.more_horiz_rounded,
                size: 15.0,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
