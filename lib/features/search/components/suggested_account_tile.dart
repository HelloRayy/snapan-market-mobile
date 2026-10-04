import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:snapan_market/core/theme/app_colors.dart";
import "package:snapan_market/core/ui/default_profile_avatar.dart";
import "package:snapan_market/core/services/follow_service.dart";
import "package:snapan_market/features/search/models/search_models.dart";

class SuggestedAccountTile extends StatelessWidget {
  final SuggestedAccount account;
  final VoidCallback? onTap;
  final VoidCallback? onFollowTap;
  final bool? isFollowing;

  const SuggestedAccountTile({
    super.key,
    required this.account,
    this.onTap,
    this.onFollowTap,
    this.isFollowing,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FollowService.instance,
      builder: (context, _) {
        final isMe = FollowService.instance.isCurrentUser(account.id, account.username);
        final following = isFollowing ?? FollowService.instance.isFollowing(account.id, account.username);
        return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User Avatar (Standard 40x40 circle)
            AppAvatar(
              avatarUrl: account.avatar,
              size: 40.0,
              name: account.fullName,
              username: account.username,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 3.0,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            const SizedBox(width: 12.0),

            // User Info Column (Consistent spacing rhythm identical to HomeFeed)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Username + Verified Badge Row
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          account.username,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                            height: 1.15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (account.isVerified) ...[
                        const SizedBox(width: 4.0),
                        const Icon(
                          CupertinoIcons.checkmark_seal_fill,
                          size: 15.0,
                          color: AppColors.verifiedBlue,
                        ),
                      ],
                    ],
                  ),

                  // 2. Full Name
                  const SizedBox(height: 1.5),
                  Text(
                    account.fullName,
                    style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF64748B),
                      height: 1.20,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!isMe) ...[
              const SizedBox(width: 10.0),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (onFollowTap != null) {
                    onFollowTap!();
                  } else {
                    FollowService.instance.toggleFollow(
                      targetUserId: account.id,
                      targetUsername: account.username,
                    );
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 78.0,
                  height: 32.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: following
                        ? const Color(0xFFF1F5F9)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x08000000),
                        blurRadius: 2.0,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    following ? "Mengikuti" : "Ikuti",
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: following
                          ? const Color(0xFF64748B)
                          : const Color(0xFF0F172A),
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
      },
    );
  }
}
