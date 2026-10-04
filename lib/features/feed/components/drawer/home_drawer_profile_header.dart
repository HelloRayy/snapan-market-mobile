import 'package:flutter/material.dart';
import 'package:snapan_market/core/ui/default_profile_avatar.dart';

/// User profile banner header for the navigation drawer.
class HomeDrawerProfileHeader extends StatelessWidget {
  final Map<String, dynamic>? userProfile;
  final String displayName;
  final String displayEmail;
  final Color borderColor;
  final Color inkColor;
  final Color mutedColor;
  final bool isDark;

  const HomeDrawerProfileHeader({
    super.key,
    this.userProfile,
    required this.displayName,
    required this.displayEmail,
    required this.borderColor,
    required this.inkColor,
    required this.mutedColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E2E) : const Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          AppAvatar(
            avatarUrl: userProfile?['avatar_url'] as String?,
            size: 40.0,
            name: displayName,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: inkColor,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  displayEmail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 12.0,
                    color: mutedColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
