import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// 1. Home Nav Glyph using LucideIcons.home
class HomeNavGlyph extends StatelessWidget {
  final bool isActive;

  const HomeNavGlyph({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Icon(
      LucideIcons.home,
      size: 21.0,
      color: isActive ? const Color(0xFF008BFF) : const Color(0xFF1A1A1A),
    );
  }
}
