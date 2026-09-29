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
            // Circular Avatar Container (Threads standard: borderless, shadowless, pure image fill)
            SizedBox(
              width: 42.0,
              height: 42.0,
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

            // Thumb-friendly '+' Follow Badge (Clean flat circle, no glow shadow, 1.5px white cutout ring)
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
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFollowed
                            ? const Color(0xFF10B981) // Emerald when followed
                            : const Color(0xFF000000), // Threads Ink Black #000000
                        border: Border.all(color: Colors.white, width: 1.5),
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
