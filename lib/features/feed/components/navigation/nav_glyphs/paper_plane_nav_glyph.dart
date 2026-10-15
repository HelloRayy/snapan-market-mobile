import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:snapan_market/core/theme/app_colors.dart';

/// 2. Messages Nav Glyph using CupertinoIcons (chat_bubble_fill / chat_bubble) with Azure badge
class PaperPlaneNavGlyph extends StatelessWidget {
  final bool isActive;
  final bool hasBadge;
  final int badgeCount;
  final Color? activeColor;
  final Color? inactiveColor;

  const PaperPlaneNavGlyph({
    super.key,
    required this.isActive,
    this.hasBadge = false,
    this.badgeCount = 1,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveActive = activeColor ?? (isDark ? Colors.white : AppColors.primary);
    final effectiveInactive = inactiveColor ?? (isDark ? const Color(0x99FFFFFF) : const Color(0xFF64748B));

    final icon = Icon(
      isActive ? CupertinoIcons.chat_bubble_fill : CupertinoIcons.chat_bubble,
      size: 21.5,
      color: isActive ? effectiveActive : effectiveInactive,
    );

    if (!hasBadge || badgeCount <= 0) {
      return icon;
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        icon,
        Positioned(
          top: -5.0,
          right: -8.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.0),
            constraints: const BoxConstraints(
              minWidth: 16.0,
              minHeight: 16.0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF008BFF),
              shape: badgeCount > 9 ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: badgeCount > 9 ? BorderRadius.circular(9.0) : null,
              border: Border.all(
                color: isDark ? AppColors.darkSurface : Colors.white,
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x29000000),
                  blurRadius: 3.0,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Text(
                badgeCount > 99 ? '99+' : badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
