import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/feed/components/media_lightbox_dialog.dart';
import 'package:snapan_market/features/messages/models/conversation_model.dart';

/// Top bar header title widget displaying user avatar, name, verification, and presence.
class ChatAppBarTitle extends StatelessWidget {
  final ConversationUser user;
  final VoidCallback onTapProfile;

  const ChatAppBarTitle({
    super.key,
    required this.user,
    required this.onTapProfile,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapProfile,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () {
                  if (user.avatar.isNotEmpty) {
                    MediaLightboxDialog.show(
                      context: context,
                      images: [user.avatar],
                      initialIndex: 0,
                    );
                  }
                },
                child: Container(
                  width: 34.0,
                  height: 34.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF1F5F9),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 0.8,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17.0),
                    child: Image.network(
                      user.avatar,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person_rounded,
                        color: AppColors.muted,
                        size: 18.0,
                      ),
                    ),
                  ),
                ),
              ),
              if (user.isOnline)
                Positioned(
                  bottom: -0.5,
                  right: -0.5,
                  child: Container(
                    width: 10.0,
                    height: 10.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF31A24C),
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8.0),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    if (user.isVerified) ...[
                      const SizedBox(width: 3.5),
                      const Icon(
                        Icons.verified_rounded,
                        size: 14.5,
                        color: AppColors.verifiedBlue,
                      ),
                    ],
                  ],
                ),
                Text(
                  user.isOnline ? "Aktif sekarang" : (user.classGroup ?? "Siswa SMKN 8 Semarang"),
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 11.0,
                    color: user.isOnline
                        ? const Color(0xFF31A24C)
                        : const Color(0xFF94A3B8),
                    fontWeight: user.isOnline ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
