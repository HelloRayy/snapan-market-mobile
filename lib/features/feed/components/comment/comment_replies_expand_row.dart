import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/ui/default_profile_avatar.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Minimalist row for expanding/collapsing comment replies in Instagram / X style
class CommentRepliesExpandRow extends StatelessWidget {
  final List<PostCommentModel> replies;
  final bool isExpanded;
  final VoidCallback onToggle;

  const CommentRepliesExpandRow({
    super.key,
    required this.replies,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (replies.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onToggle();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Clean horizontal indicator dash (──)
            Container(
              width: 24.0,
              height: 1.2,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(1.0),
              ),
            ),

            const SizedBox(width: 8.0),

            // Mini replier avatar
            const DefaultProfileAvatar(
              size: 18.0,
            ),

            const SizedBox(width: 8.0),

            // Label text
            Text(
              isExpanded
                  ? 'Sembunyikan balasan'
                  : (replies.length > 1
                      ? 'Lihat ${replies.length} balasan'
                      : 'Lihat balasan'),
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
                letterSpacing: -0.2,
              ),
            ),

            const SizedBox(width: 4.0),

            Icon(
              isExpanded
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
