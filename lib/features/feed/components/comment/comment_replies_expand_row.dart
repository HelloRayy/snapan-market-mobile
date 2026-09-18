import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/feed/components/comment/thread_branch_painter.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Interactive row for "Tampilkan balasan" featuring Threads curved threadline,
/// mini avatar with reply arrow badge, and expand/collapse trigger.
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
        padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Curved elbow connector line (╰─)
            SizedBox(
              width: 36.0,
              height: 28.0,
              child: CustomPaint(
                painter: const ThreadBranchPainter(
                  color: Color(0xFFD1D5DB), // Subtle light slate threadline
                  strokeWidth: 1.8,
                  curveRadius: 14.0,
                  avatarCenterX: 18.0,
                  type: ThreadLineType.elbow,
                ),
              ),
            ),

            const SizedBox(width: 8.0),

            // Mini replier avatar with reply arrow badge
            SizedBox(
              width: 22.0,
              height: 22.0,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 20.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        replierAvatar,
                        width: 20.0,
                        height: 20.0,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: AppColors.primaryPastel,
                          child: Center(
                            child: Text(
                              replierName.isNotEmpty ? replierName[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                fontSize: 9.0,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Tiny reply arrow badge at bottom-right
                  Positioned(
                    right: -2.0,
                    bottom: -2.0,
                    child: Container(
                      width: 10.0,
                      height: 10.0,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F172A),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.subdirectory_arrow_right_rounded,
                          size: 7.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8.0),

            // Label text
            Text(
              isExpanded
                  ? 'Sembunyikan balasan'
                  : (replies.length > 1
                      ? 'Tampilkan ${replies.length} balasan'
                      : 'Tampilkan balasan'),
              style: const TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
                letterSpacing: -0.2,
              ),
            ),

            const SizedBox(width: 4.0),

            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 15.0,
              color: const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
