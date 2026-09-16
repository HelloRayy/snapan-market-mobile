import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// 4. User Nav Glyph using circular avatar with fallback to LucideIcons.user
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
            color: isActive ? const Color(0xFF008BFF) : const Color(0xFFCBD5E1),
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
      LucideIcons.user,
      size: 20.0,
      color: isActive ? const Color(0xFF008BFF) : const Color(0xFF1A1A1A),
    );
  }
}
