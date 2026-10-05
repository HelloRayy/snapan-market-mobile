import 'package:flutter/cupertino.dart';

import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/ui/default_profile_avatar.dart';

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
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: SupabaseService.instance.currentUserProfileNotifier,
      builder: (context, profile, _) {
        final effectiveAvatar = (profile?['avatar_url'] as String?)?.trim() ??
            (userAvatar?.trim().isNotEmpty == true ? userAvatar!.trim() : null) ??
            (SupabaseService.instance.currentUser?.userMetadata?['avatar_url'] as String?)?.trim();

        if (!kForceDefaultProfileAvatar && effectiveAvatar != null && effectiveAvatar.isNotEmpty) {
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
                effectiveAvatar,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFallbackGlyph(),
              ),
            ),
          );
        }

        return _buildFallbackGlyph();
      },
    );
  }

  Widget _buildFallbackGlyph() {
    return Icon(
      isActive ? CupertinoIcons.person_fill : CupertinoIcons.person,
      size: 20.0,
      color: isActive ? AppColors.primary : const Color(0xFF64748B),
    );
  }
}
