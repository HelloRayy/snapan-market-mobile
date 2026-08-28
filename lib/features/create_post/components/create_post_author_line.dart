import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/create_post/models/create_post_types.dart';

/// Author username and topic tag badge trigger
class CreatePostAuthorLine extends StatelessWidget {
  final String authorName;
  final TopicOption? selectedTopic;
  final GlobalKey topicTriggerKey;
  final VoidCallback onTopicTriggerTap;
  final VoidCallback onTopicClear;

  const CreatePostAuthorLine({
    super.key,
    required this.authorName,
    required this.selectedTopic,
    required this.topicTriggerKey,
    required this.onTopicTriggerTap,
    required this.onTopicClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Author Username
        Text(
          authorName,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(width: 6.0),

        // Topic Tag Badge Trigger ("#Komunitas atau topik")
        GestureDetector(
          key: topicTriggerKey,
          onTap: () {
            HapticFeedback.selectionClick();
            onTopicTriggerTap();
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: selectedTopic != null ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: selectedTopic != null ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedTopic != null ? '#${selectedTopic!.name}' : '# Topik',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: selectedTopic != null ? FontWeight.w700 : FontWeight.w500,
                    color: selectedTopic != null ? AppColors.primary : const Color(0xFF64748B),
                  ),
                ),
                if (selectedTopic != null) ...[
                  const SizedBox(width: 4.0),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onTopicClear();
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      size: 12.0,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
