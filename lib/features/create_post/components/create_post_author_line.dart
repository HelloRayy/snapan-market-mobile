import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/components/mascot_flair_badge.dart';
import 'package:snapan_market/core/components/snaps_skeleton.dart';
import 'package:snapan_market/core/models/mascot_flair_model.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/create_post/models/create_post_types.dart';

/// Author username and topic tag badge trigger
class CreatePostAuthorLine extends StatelessWidget {
  final String authorName;
  final TopicOption? selectedTopic;
  final GlobalKey topicTriggerKey;
  final VoidCallback onTopicTriggerTap;
  final VoidCallback onTopicClear;
  final MascotFlairModel? selectedMascotFlair;
  final bool isBetaPilotUser;
  final VoidCallback? onMascotTriggerTap;
  final GlobalKey? mascotTriggerKey;
  final bool isMascotDropdownOpen;

  const CreatePostAuthorLine({
    super.key,
    required this.authorName,
    required this.selectedTopic,
    required this.topicTriggerKey,
    required this.onTopicTriggerTap,
    required this.onTopicClear,
    this.selectedMascotFlair,
    this.isBetaPilotUser = false,
    this.onMascotTriggerTap,
    this.mascotTriggerKey,
    this.isMascotDropdownOpen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Author Username or Skeleton Box if loading
        if (authorName.trim().isEmpty)
          const SnapsSkeletonBox(width: 80.0, height: 14.0, borderRadius: 4.0)
        else
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

        // Mascot Flair Trigger (SNAPS-13: Interactive container encompassing mascot and dropdown arrow)
        if (isBetaPilotUser) ...[
          GestureDetector(
            key: mascotTriggerKey,
            onTap: () {
              HapticFeedback.selectionClick();
              onMascotTriggerTap?.call();
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedMascotFlair != null)
                    MascotFlairBadge(
                      flair: selectedMascotFlair!,
                      size: 26.0,
                      enableGradientFade: false,
                      onTap: onMascotTriggerTap,
                    )
                  else
                    const Icon(
                      CupertinoIcons.sparkles,
                      size: 16.0,
                      color: Color(0xFF64748B),
                    ),
                  const SizedBox(width: 3.0),
                  const Icon(
                    CupertinoIcons.chevron_down,
                    size: 11.0,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4.0),
        ],

        // Chevron Right Separator
        const Icon(
          CupertinoIcons.chevron_forward,
          size: 13.0,
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
                      ? CupertinoIcons.star_fill
                      : CupertinoIcons.tag_fill,
                  size: 13.0,
                  color: selectedTopic!.isOfficial
                      ? AppColors.primary
                      : const Color(0xFF64748B),
                ),
                const SizedBox(width: 4.0),
                Text(
                  selectedTopic!.name,
                  style: TextStyle(
                    fontSize: 13.5,
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
                  child: const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      size: 14.0,
                      color: Color(0xFF94A3B8),
                    ),
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
