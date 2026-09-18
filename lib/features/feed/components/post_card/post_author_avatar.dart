import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// 42x42px circular author avatar with thumb-friendly '+' follow badge
class PostAuthorAvatar extends StatelessWidget {
  final SellerModel seller;
  final bool isFollowed;
  final VoidCallback onFollowToggle;
  final VoidCallback? onUserClick;

  const PostAuthorAvatar({
    super.key,
    required this.seller,
    required this.isFollowed,
    required this.onFollowToggle,
    this.onUserClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onUserClick,
      child: SizedBox(
        width: 44.0,
        height: 44.0,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Circular Avatar Container
            Container(
              width: 42.0,
              height: 42.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 4.0,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  seller.avatar,
                  width: 42.0,
                  height: 42.0,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.primaryPastel,
                    child: Center(
                      child: Text(
                        seller.name.isNotEmpty ? seller.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Thumb-friendly '+' Follow Badge
            Positioned(
              right: -6.0,
              bottom: -6.0,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onFollowToggle();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5.0),
                    color: Colors.transparent,
                    child: Container(
                      width: 22.5,
                      height: 22.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isFollowed
                              ? const [
                                  Color(0xFF10B981), // Emerald 500
                                  Color(0xFF059669), // Emerald 600
                                ]
                              : const [
                                  Color(0xFF3B82F6), // Blue 500
                                  Color(0xFF1D64EC), // Primary Blue
                                ],
                        ),
                        border: Border.all(color: Colors.white, width: 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: (isFollowed
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF1D64EC))
                                .withOpacity(0.35),
                            blurRadius: 4.0,
                            offset: const Offset(0, 1.5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            isFollowed ? Icons.check_rounded : Icons.add_rounded,
                            key: ValueKey(isFollowed),
                            size: isFollowed ? 14.0 : 15.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
