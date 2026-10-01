import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:snapan_market/core/theme/app_colors.dart';

/// 4. User Nav Glyph using circular avatar with fallback to CupertinoIcons (person_fill / person)
class UserNavGlyph extends StatelessWidget {
  final bool isActive;
  final String? userAvatar;

  const UserNavGlyph({
    super.key,
    required this.isActive,
    this.userAvatar,
  });

  @override
  Widget build(BuildContext context) {
    if (userAvatar != null && userAvatar!.isNotEmpty) {
      return Container(
        width: 22.0,
        height: 22.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? AppColors.primary : const Color(0xFFCBD5E1),
            width: isActive ? 1.8 : 1.0,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            userAvatar!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildFallbackGlyph(),
          ),
        ),
      );
    }

    return _buildFallbackGlyph();
  }

  Widget _buildFallbackGlyph() {
    return Icon(
      isActive ? CupertinoIcons.person_fill : CupertinoIcons.person,
      size: 20.0,
      color: isActive ? AppColors.primary : const Color(0xFF64748B),
    );
  }
}
