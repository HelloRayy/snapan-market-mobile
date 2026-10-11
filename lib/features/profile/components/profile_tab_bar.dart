import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ProfileTab {
  threads,
  replies,
  media,
}

/// 3-Tab Sliding Switcher for Profile Screen (Utas, Balasan, Media)
/// Matching ProfilePage.tsx with 47px fixed height, real-time 1:1 indicator tracking,
/// and smooth pageController synchronization.
class ProfileTabBar extends StatelessWidget implements PreferredSizeWidget {
  final ProfileTab activeTab;
  final ValueChanged<ProfileTab> onTabChanged;
  final PageController? pageController;

  const ProfileTabBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
    this.pageController,
  });

  @override
  Size get preferredSize => const Size.fromHeight(47.0);

  @override
  Widget build(BuildContext context) {
    if (pageController != null) {
      return AnimatedBuilder(
        animation: pageController!,
        builder: (context, _) => _buildBar(context),
      );
    }
    return _buildBar(context);
  }

  Widget _buildBar(BuildContext context) {
    double pageOffset = activeTab.index.toDouble();
    if (pageController != null &&
        pageController!.hasClients &&
        pageController!.position.haveDimensions) {
      pageOffset = pageController!.page ?? activeTab.index.toDouble();
    }
    final double clampedOffset = pageOffset.clamp(0.0, 2.0);
    final double indicatorAlignment = -1.0 + clampedOffset;

    final int activeIndex = clampedOffset.round().clamp(0, 2);
    final ProfileTab currentActiveTab = ProfileTab.values[activeIndex];

    return Container(
      height: 47.0,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 0.5),
        ),
      ),
      child: Stack(
        children: [
          // 3-Tab Row stretching full height
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTabItem(
                title: 'Utas',
                tab: ProfileTab.threads,
                isSelected: currentActiveTab == ProfileTab.threads,
              ),
              _buildTabItem(
                title: 'Balasan',
                tab: ProfileTab.replies,
                isSelected: currentActiveTab == ProfileTab.replies,
              ),
              _buildTabItem(
                title: 'Media',
                tab: ProfileTab.media,
                isSelected: currentActiveTab == ProfileTab.media,
              ),
            ],
          ),

          // Real-time 1:1 Sliding Underline Indicator
          Align(
            alignment: Alignment(indicatorAlignment, 1.0),
            child: FractionallySizedBox(
              widthFactor: 1 / 3,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 2.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(1.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required ProfileTab tab,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          if (pageController != null && pageController!.hasClients) {
            pageController!.animateToPage(
              tab.index,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
            );
          }
          onTabChanged(tab);
        },
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF94A3B8),
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }
}

/// Sliver Header Delegate to pin ProfileTabBar smoothly in NestedScrollView
class ProfileTabBarDelegate extends SliverPersistentHeaderDelegate {
  final ProfileTab activeTab;
  final ValueChanged<ProfileTab> onTabChanged;
  final PageController? pageController;

  const ProfileTabBarDelegate({
    required this.activeTab,
    required this.onTabChanged,
    this.pageController,
  });

  @override
  double get minExtent => 47.0;

  @override
  double get maxExtent => 47.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ProfileTabBar(
      activeTab: activeTab,
      onTabChanged: onTabChanged,
      pageController: pageController,
    );
  }

  @override
  bool shouldRebuild(covariant ProfileTabBarDelegate oldDelegate) {
    return oldDelegate.activeTab != activeTab ||
        oldDelegate.pageController != pageController;
  }
}
