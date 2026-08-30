import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ProfileTab {
  threads,
  replies,
  media,
}

/// 3-Tab Sliding Switcher for Profile Screen (Utas, Balasan, Media)
/// Matching ProfilePage.tsx with 47px fixed height and animated 2px underline indicator
class ProfileTabBar extends StatelessWidget implements PreferredSizeWidget {
  final ProfileTab activeTab;
  final ValueChanged<ProfileTab> onTabChanged;

  const ProfileTabBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(47.0);

  @override
  Widget build(BuildContext context) {
    final double indicatorAlignment;
    switch (activeTab) {
      case ProfileTab.threads:
        indicatorAlignment = -1.0;
        break;
      case ProfileTab.replies:
        indicatorAlignment = 0.0;
        break;
      case ProfileTab.media:
        indicatorAlignment = 1.0;
        break;
    }

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
                isSelected: activeTab == ProfileTab.threads,
              ),
              _buildTabItem(
                title: 'Balasan',
                tab: ProfileTab.replies,
                isSelected: activeTab == ProfileTab.replies,
              ),
              _buildTabItem(
                title: 'Media',
                tab: ProfileTab.media,
                isSelected: activeTab == ProfileTab.media,
              ),
            ],
          ),

          // Smooth Sliding Underline Indicator
          AnimatedAlign(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
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
          onTabChanged(tab);
        },
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }
}
