import 'package:flutter/cupertino.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// 1. Home Nav Glyph using CupertinoIcons (house_alt_fill / house_alt)
class HomeNavGlyph extends StatelessWidget {
  final bool isActive;

  const HomeNavGlyph({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Icon(
      isActive ? CupertinoIcons.house_alt_fill : CupertinoIcons.house_alt,
      size: 22.0,
      color: isActive ? AppColors.primary : const Color(0xFF64748B),
    );
  }
}
