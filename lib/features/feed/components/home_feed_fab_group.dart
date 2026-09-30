import 'package:flutter/material.dart';
import 'package:snapan_market/features/create_post/models/create_post_types.dart';
import 'package:snapan_market/features/feed/components/floating_marketplace_squircle_button.dart';
import 'package:snapan_market/features/feed/components/floating_plus_squircle_button.dart';
import 'package:snapan_market/features/feed/components/home_bottom_nav_bar.dart';

class HomeFeedFabGroup extends StatelessWidget {
  final HomeNavTab currentNavTab;
  final AnimationController fabAnimationController;
  final Animation<double>? fabAnimation;
  final double fabBottomVisible;
  final ValueChanged<PostMode> onCreatePost;

  const HomeFeedFabGroup({
    super.key,
    required this.currentNavTab,
    required this.fabAnimationController,
    required this.fabAnimation,
    required this.fabBottomVisible,
    required this.onCreatePost,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20.0,
      bottom: fabBottomVisible,
      child: AnimatedBuilder(
        animation: fabAnimationController,
        builder: (context, _) {
          final double fabProgress = fabAnimation?.value ?? 1.0;
          final double fabOffsetY = (1.0 - fabProgress) * 48.0;
          final double fabScale = 0.6 + 0.4 * fabProgress;
          final double fabOpacity = fabProgress.clamp(0.0, 1.0);
          final bool isHomeTab = currentNavTab == HomeNavTab.home;

          return AnimatedOpacity(
            opacity: isHomeTab ? fabOpacity : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: AnimatedScale(
              scale: isHomeTab ? fabScale : 0.6,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              alignment: Alignment.bottomRight,
              child: Transform.translate(
                offset: Offset(0, fabOffsetY),
                child: IgnorePointer(
                  ignoring: !isHomeTab || fabProgress < 0.2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FloatingMarketplaceSquircleButton(
                        onTap: () => onCreatePost(PostMode.product),
                      ),
                      const SizedBox(height: 6.0),
                      FloatingPlusSquircleButton(
                        onTap: () => onCreatePost(PostMode.thread),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
