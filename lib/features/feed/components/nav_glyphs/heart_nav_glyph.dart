import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// 3. Heart Nav Glyph using LucideIcons.heart with optional red indicator dot
class HeartNavGlyph extends StatelessWidget {
  final bool isActive;
  final bool hasBadge;

  const HeartNavGlyph({
    super.key,
    required this.isActive,
    this.hasBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      LucideIcons.heart,
      size: 20.5,
      color: isActive ? const Color(0xFF008BFF) : const Color(0xFF1A1A1A),
    );

    if (!hasBadge) return icon;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        icon,
        Positioned(
          top: -1.0,
          right: -2.0,
          child: Container(
            width: 7.0,
            height: 7.0,
            decoration: BoxDecoration(
              color: const Color(0xFFFF3040),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
