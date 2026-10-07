import 'package:flutter/material.dart';
import 'package:snapan_market/features/feed/components/navigation/home_bottom_nav_bar.dart';

/// Animated Directional Slide Tab Switcher for Bottom Nav (Preserves State)
class HomeNavTabSwitcher extends StatelessWidget {
  final HomeNavTab currentNavTab;
  final Widget feedTab;
  final Widget messagesTab;
  final Widget activityTab;
  final Widget profileTab;

  const HomeNavTabSwitcher({
    super.key,
    required this.currentNavTab,
    required this.feedTab,
    required this.messagesTab,
    required this.activityTab,
    required this.profileTab,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          _buildNavTabScreen(index: 0, child: feedTab),
          _buildNavTabScreen(index: 1, child: messagesTab),
          _buildNavTabScreen(index: 2, child: activityTab),
          _buildNavTabScreen(index: 3, child: profileTab),
        ],
      ),
    );
  }

  Widget _buildNavTabScreen({required int index, required Widget child}) {
    final int currentIndex = currentNavTab.index;
    final bool isCurrent = currentIndex == index;

    final Offset targetOffset = isCurrent
        ? Offset.zero
        : (index > currentIndex ? const Offset(1.0, 0.0) : const Offset(-0.25, 0.0));

    final double targetOpacity = isCurrent ? 1.0 : (index > currentIndex ? 1.0 : 0.0);

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !isCurrent,
        child: AnimatedSlide(
          offset: targetOffset,
          duration: const Duration(milliseconds: 280),
          curve: const Cubic(0.22, 1.0, 0.36, 1.0),
          child: AnimatedOpacity(
            opacity: targetOpacity,
            duration: const Duration(milliseconds: 240),
            curve: const Cubic(0.22, 1.0, 0.36, 1.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: index > 0
                    ? const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 18.0,
                          offset: Offset(-4, 0),
                        ),
                      ]
                    : null,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
