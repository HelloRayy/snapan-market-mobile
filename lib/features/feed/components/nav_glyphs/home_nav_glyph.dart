import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:snapan_market/core/theme/app_colors.dart';

/// 1. Home Nav Glyph using LucideIcons.home
class HomeNavGlyph extends StatelessWidget {
  final bool isActive;

  const HomeNavGlyph({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Icon(
      LucideIcons.home,
      size: 21.0,
      color: isActive ? AppColors.primary : const Color(0xFF64748B),
    );
  }
}
