import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
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

    final firstReply = replies.first;
    final replierAvatar = firstReply.user.avatar;
    final replierName = firstReply.user.name;

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
            Container(
              width: 18.0,
              height: 18.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
              ),
              child: ClipOval(
                child: Image.network(
                  replierAvatar,
                  width: 18.0,
                  height: 18.0,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.primaryPastel,
                    child: Center(
                      child: Text(
                        replierName.isNotEmpty ? replierName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
