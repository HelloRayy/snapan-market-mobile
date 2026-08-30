import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ProfileTab {
  threads,
  replies,
  media,
}

/// 3-Tab Sliding Switcher for Profile Screen (Utas, Balasan, Media)
/// Matching ProfilePage.tsx with animated 2px underline indicator
class ProfileTabBar extends StatelessWidget {
  final ProfileTab activeTab;
  final ValueChanged<ProfileTab> onTabChanged;

  const ProfileTabBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
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
          SizedBox(
            height: 2.0,
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment(indicatorAlignment, 0),
              child: FractionallySizedBox(
                widthFactor: 1 / 3,
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
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          alignment: Alignment.center,
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
