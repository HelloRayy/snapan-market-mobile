import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:snapan_market/core/components/snaps_logo.dart";
import "package:snapan_market/core/theme/app_colors.dart";
import "package:snapan_market/core/ui/default_profile_avatar.dart";
import "package:snapan_market/core/utils/mention_text_span_helper.dart";
import "package:snapan_market/features/activity/models/activity_notification_model.dart";

class ActivityItemTile extends StatelessWidget {
  final ActivityNotification notification;
  final VoidCallback? onTap;

  const ActivityItemTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        color: notification.isRead ? Colors.white : const Color(0xFFF8FAFC),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Actor Avatar with Action Icon Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22.0),
                  child: notification.type == ActivityType.system
                      ? Container(
                          width: 44.0,
                          height: 44.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                          ),
                          padding: const EdgeInsets.all(7.0),
                          child: const Center(
                            child: SnapsLogo(height: 18.0),
                          ),
                        )
                      : AppAvatar(
                          avatarUrl: notification.actorAvatar,
                          size: 44.0,
                          name: notification.actorName,
                        ),
                ),

                Positioned(
                  right: -2.0,
                  bottom: -2.0,
                  child: Container(
                    width: 20.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      color: _getBadgeColor(notification.type),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Icon(
                      _getBadgeIcon(notification.type),
                      size: 11.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12.0),

            // Notification Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          notification.type == ActivityType.system ||
                                  notification.actorName.toLowerCase().startsWith('admin')
                              ? 'Snaps'
                              : notification.actorName,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (notification.type == ActivityType.system ||
                          notification.actorName.toLowerCase().startsWith('admin')) ...[
                        const SizedBox(width: 4.0),
                        const Icon(
                          CupertinoIcons.checkmark_seal_fill,
                          size: 13.0,
                          color: Color(0xFF0283F3),
                        ),
                      ],
                      const SizedBox(width: 6.0),
                      Text(
                        "• ${notification.timeAgo}",
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2.0),
                  Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w500,
                        color: notification.isRead ? const Color(0xFF64748B) : const Color(0xFF334155),
                        height: 1.3,
                      ),
                      children: MentionTextSpanHelper.buildSpans(
                        context: context,
                        text: notification.message,
                        defaultStyle: TextStyle(
                          fontSize: 13.0,
                          fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w500,
                          color: notification.isRead ? const Color(0xFF64748B) : const Color(0xFF334155),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Post Thumbnail or Unread Dot
            if (notification.postThumbnail != null) ...[
              const SizedBox(width: 10.0),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  notification.postThumbnail!,
                  width: 44.0,
                  height: 44.0,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ] else if (!notification.isRead) ...[
              const SizedBox(width: 8.0),
              Container(
                width: 8.0,
                height: 8.0,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBadgeColor(ActivityType type) {
    switch (type) {
      case ActivityType.like:
        return const Color(0xFFF43F5E);
      case ActivityType.comment:
        return const Color(0xFF3B82F6);
      case ActivityType.mention:
        return AppColors.primary;
      case ActivityType.follow:
        return const Color(0xFF6366F1);
      case ActivityType.order:
        return const Color(0xFF10B981);
      case ActivityType.system:
        return const Color(0xFF3D38F5);
    }
  }

  IconData _getBadgeIcon(ActivityType type) {
    switch (type) {
      case ActivityType.like:
        return CupertinoIcons.heart_fill;
      case ActivityType.comment:
        return CupertinoIcons.chat_bubble_fill;
      case ActivityType.mention:
        return CupertinoIcons.at;
      case ActivityType.follow:
        return CupertinoIcons.person_badge_plus_fill;
      case ActivityType.order:
        return CupertinoIcons.bag_fill;
      case ActivityType.system:
        return CupertinoIcons.checkmark_seal_fill;
    }
  }
}
