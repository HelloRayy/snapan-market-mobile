import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Enum representing the available tabs in Home Feed
enum FeedTab {
  forYou,
  latest;

  String get label {
    switch (this) {
      case FeedTab.forYou:
        return 'Untuk Anda';
      case FeedTab.latest:
        return 'Terbaru';
    }
  }
}

/// Home Feed Tab Switch Bar ("Untuk Anda" & "Terbaru")
///
/// Features a 47px fixed height container, balanced 50/50 tab buttons,
/// a smooth 2.5px active indicator bar transition, and tactile micro-tap interactions.
class HomeFeedTabSwitch extends StatelessWidget implements PreferredSizeWidget {
  final FeedTab activeTab;
  final ValueChanged<FeedTab> onTabChanged;

  const HomeFeedTabSwitch({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(47.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 47.0,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF1F5F9),
            width: 1.0,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Animated Bottom Indicator Bar (2.5px height)
          AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: activeTab == FeedTab.forYou
                ? Alignment.bottomLeft
                : Alignment.bottomRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 2.5,
                  decoration: const BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(2.0),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Tab Buttons Row (50% / 50% distribution)
          Row(
            children: [
              Expanded(
                child: _TabButton(
                  tab: FeedTab.forYou,
                  isActive: activeTab == FeedTab.forYou,
                  onTap: () {
                    if (activeTab != FeedTab.forYou) {
                      HapticFeedback.selectionClick();
                      onTabChanged(FeedTab.forYou);
                    }
                  },
                ),
              ),
              Expanded(
                child: _TabButton(
                  tab: FeedTab.latest,
                  isActive: activeTab == FeedTab.latest,
                  onTap: () {
                    if (activeTab != FeedTab.latest) {
                      HapticFeedback.selectionClick();
                      onTabChanged(FeedTab.latest);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Interactive Tab Item Button with tactile scale and subtle tap highlight
class _TabButton extends StatefulWidget {
  final FeedTab tab;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          height: 47.0,
          alignment: Alignment.center,
          color: _isPressed
              ? Colors.black.withValues(alpha: 0.04)
              : Colors.transparent,
          child: Text(
            widget.tab.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w500,
              color: widget.isActive
                  ? AppColors.ink
                  : const Color(0xFF8E8E93),
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}
