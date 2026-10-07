import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:snapan_market/core/theme/app_colors.dart';

/// 3. Heart Nav Glyph using CupertinoIcons (heart_fill / heart) with optional red indicator dot
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
      isActive ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
      size: 21.0,
      color: isActive ? AppColors.primary : const Color(0xFF64748B),
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
