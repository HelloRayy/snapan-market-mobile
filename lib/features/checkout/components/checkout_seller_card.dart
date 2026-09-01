import "package:flutter/material.dart";
import "package:snapan_market/core/theme/app_colors.dart";

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
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: onProfileTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.network(
                sellerAvatar,
                width: 44.0,
                height: 44.0,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 44.0,
                  height: 44.0,
                  color: const Color(0xFFE2E8F0),
                  child: const Icon(Icons.person, color: Color(0xFF94A3B8)),
                ),
              ),
            ),
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
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      const Icon(Icons.verified, size: 14.0, color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    "@$sellerUsername • $department",
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
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
