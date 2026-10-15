import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_animations.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Enum representing the available tabs in Home Feed
enum FeedTab {
  forYou,
  market;

  String get label {
    switch (this) {
      case FeedTab.forYou:
        return 'Untuk Anda';
      case FeedTab.market:
        return 'Jualan';
    }
  }
}

/// Home Feed Tab Switch Bar ("Untuk Anda" & "Jualan") - Threads-Style Tap-Only.
///
/// Features a 47px fixed height container, balanced 50/50 tab buttons,
/// a responsive 2.5px active indicator bar with polished spring motion,
/// and crisp tactile micro-tap interactions (SNAPS-26).
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
    final bgColor = AppColors.adaptiveCanvas(context);
    final borderColor = AppColors.adaptiveDivider(context);
    final indicatorColor = AppColors.adaptiveText(context);

    return Container(
      height: 47.0,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(
            color: borderColor,
            width: 1.0,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Polished Spring Sliding Indicator Bar (2.5px height)
          AnimatedAlign(
            duration: const Duration(milliseconds: 220),
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
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    borderRadius: const BorderRadius.vertical(
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
                      AppAnimations.tabSwipeHaptic();
                      onTabChanged(FeedTab.forYou);
                    }
                  },
                ),
              ),
              Expanded(
                child: _TabButton(
                  tab: FeedTab.market,
                  isActive: activeTab == FeedTab.market,
                  onTap: () {
                    if (activeTab != FeedTab.market) {
                      AppAnimations.tabSwipeHaptic();
                      onTabChanged(FeedTab.market);
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

/// Interactive Tab Item Button with tactile scale and smooth state transition
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeTextColor = AppColors.adaptiveText(context);
    final inactiveTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF8E8E93);

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
              ? (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.04))
              : Colors.transparent,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 15.0,
              fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w500,
              color: widget.isActive ? activeTextColor : inactiveTextColor,
              letterSpacing: -0.2,
            ),
            child: Text(
              widget.tab.label,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
