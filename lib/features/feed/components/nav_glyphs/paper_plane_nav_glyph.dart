import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// 2. Messages Nav Glyph using LucideIcons.messageSquare with Azure badge
class PaperPlaneNavGlyph extends StatelessWidget {
  final bool isActive;
  final bool hasBadge;
  final int badgeCount;

  const PaperPlaneNavGlyph({
    super.key,
    required this.isActive,
    this.hasBadge = false,
    this.badgeCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      LucideIcons.messageSquare,
      size: 20.0,
      color: isActive ? const Color(0xFF008BFF) : const Color(0xFF1A1A1A),
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
                color: Colors.white,
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
