import 'package:flutter/material.dart';
import 'package:snapan_market/core/navigation/app_slide_page_route.dart';
import 'package:snapan_market/features/create_post/models/create_post_types.dart';
import 'package:snapan_market/features/feed/components/home_bottom_nav_bar.dart';
export 'package:snapan_market/features/feed/components/home_bottom_nav_bar.dart' show HomeNavTab, HomeBottomNavBar;
import 'package:snapan_market/features/feed/components/home_feed_fab_group.dart';
import 'package:snapan_market/features/feed/components/home_nav_tab_switcher.dart';
import 'package:snapan_market/features/search/screens/search_screen.dart';

/// Overlay widget combining FAB Group and HomeBottomNavBar (<60 lines).
class HomeDockOverlay extends StatelessWidget {
  final HomeNavTab currentNavTab;
  final AnimationController fabAnimationController;
  final Animation<double>? fabAnimation;
  final double fabBottom;
  final void Function([PostMode mode]) onCreatePost;
  final ValueChanged<HomeNavTab> onTabSelected;
  final String? userAvatar;

  const HomeDockOverlay({
    super.key,
    required this.currentNavTab,
    required this.fabAnimationController,
    required this.fabAnimation,
    required this.fabBottom,
    required this.onCreatePost,
    required this.onTabSelected,
    this.userAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        HomeFeedFabGroup(
          currentNavTab: currentNavTab,
          fabAnimationController: fabAnimationController,
          fabAnimation: fabAnimation,
          fabBottomVisible: fabBottom,
          onCreatePost: onCreatePost,
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: RepaintBoundary(
            child: HomeBottomNavBar(
              currentTab: currentNavTab,
              hasUnreadMessages: true,
              unreadMessagesCount: 20,
              userAvatar: userAvatar,
              onSearchTap: () => Navigator.push(
                context,
                AppSlidePageRoute(builder: (context) => SearchScreen(onBack: () => Navigator.pop(context))),
              ),
              onPostTap: onCreatePost,
              onTabSelected: onTabSelected,
            ),
          ),
        ),
      ],
    );
  }
}
