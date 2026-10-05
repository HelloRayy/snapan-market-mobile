import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/ui/oreo_avatar_helper.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Minimalist row for expanding/collapsing comment replies in Instagram / Threads style
class CommentRepliesExpandRow extends StatelessWidget {
  final List<PostCommentModel> replies;
  final bool isExpanded;
  final int? remainingCount;
  final VoidCallback onToggle;

  const CommentRepliesExpandRow({
    super.key,
    required this.replies,
    required this.isExpanded,
    this.remainingCount,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (replies.isEmpty) return const SizedBox.shrink();

    final firstReplier = replies.first.user;

    String labelText;
    if (isExpanded) {
      if (remainingCount != null && remainingCount! > 0) {
        labelText = 'Lihat $remainingCount balasan lainnya';
      } else {
        labelText = 'Sembunyikan balasan';
      }
    } else {
      labelText = replies.length == 1
          ? 'Lihat 1 balasan'
          : 'Lihat ${replies.length} balasan';
    }

    final showChevronUp = isExpanded && (remainingCount == null || remainingCount! <= 0);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onToggle();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Clean horizontal indicator dash (──)
            Container(
              width: 32.0,
              height: 1.2,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(1.0),
              ),
            ),

            const SizedBox(width: 8.0),

            // Mini replier avatar when collapsed or loading more
            if (!isExpanded || (remainingCount != null && remainingCount! > 0)) ...[
              AppAvatar(
                size: 18.0,
                avatarUrl: firstReplier.avatar,
                name: firstReplier.name,
                username: firstReplier.username,
              ),
              const SizedBox(width: 7.0),
            ],

            // Label text following best-practice UX writing
            Text(
              labelText,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
                letterSpacing: -0.2,
              ),
            ),

            const SizedBox(width: 3.0),

            Icon(
              showChevronUp
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 16.0,
              color: const Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }
}
