import "package:flutter/material.dart";
import "package:snapan_market/core/theme/app_colors.dart";
import "package:snapan_market/core/ui/default_profile_avatar.dart";

class CheckoutSellerCard extends StatelessWidget {
  final String sellerName;
  final String sellerUsername;
  final String sellerAvatar;
  final String department;
  final VoidCallback? onChatTap;
  final VoidCallback? onProfileTap;

  const CheckoutSellerCard({
    super.key,
    required this.sellerName,
    required this.sellerUsername,
    required this.sellerAvatar,
    required this.department,
    this.onChatTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final cardBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: cardBorder, width: 0.8),
      ),
      child: Row(
        children: [
          // Avatar
          AppAvatar(
            avatarUrl: sellerAvatar,
            size: 44.0,
            name: sellerName,
            onTap: onProfileTap,
          ),
          const SizedBox(width: 12.0),

          // Name & Bio
          Expanded(
            child: GestureDetector(
              onTap: onProfileTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          sellerName,
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                            color: primaryTextColor,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      const Icon(Icons.verified_rounded, size: 14.5, color: AppColors.verifiedBlue),
                    ],
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    "@$sellerUsername • $department",
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: secondaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Chat Action Button
          if (onChatTap != null)
            IconButton(
              onPressed: onChatTap,
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20.0, color: Color(0xFF3D38F5)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36.0, minHeight: 36.0),
              splashRadius: 20.0,
            ),
        ],
      ),
    );
  }
}
