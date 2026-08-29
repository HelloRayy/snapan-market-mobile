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
        const SizedBox(width: 4.0),

        // Chevron Right Separator
        const Icon(
          Icons.chevron_right_rounded,
          size: 16.0,
          color: Color(0xFF94A3B8),
        ),
        const SizedBox(width: 2.0),

        // Topic Selector Breadcrumb ("Komunitas atau topik" / "#Topic")
        GestureDetector(
          key: topicTriggerKey,
          onTap: () {
            HapticFeedback.selectionClick();
            onTopicTriggerTap();
          },
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedTopic != null) ...[
                Icon(
                  selectedTopic!.isOfficial
                      ? Icons.stars_rounded
                      : Icons.tag_rounded,
                  size: 14.0,
                  color: selectedTopic!.isOfficial
                      ? AppColors.primary
                      : const Color(0xFF0F172A),
                ),
                const SizedBox(width: 3.0),
                Text(
                  selectedTopic!.name,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: selectedTopic!.isOfficial
                        ? AppColors.primary
                        : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 4.0),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTopicClear();
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14.0,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ] else ...[
                const Text(
                  'Komunitas atau topik',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
