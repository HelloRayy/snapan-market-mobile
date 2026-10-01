import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Top profile header and create post action button in HomeNavDrawer (<80 lines).
class HomeNavHeader extends StatelessWidget {
  final Map<String, dynamic>? userProfile;
  final VoidCallback? onCreatePost;

  const HomeNavHeader({
    super.key,
    this.userProfile,
    this.onCreatePost,
  });

  @override
  Widget build(BuildContext context) {
    final String displayName = userProfile?['full_name'] as String? ?? 'Siswa SMKN 8';
    final String username = userProfile?['username'] as String? ?? 'siswa';
    final String major = userProfile?['major'] as String? ?? 'XII PPLG';
    final String? avatarUrl = userProfile?['avatar_url'] as String?;

    return Row(
      children: [
        // 1. Avatar with subtle gradient ring
        Container(
          width: 40.0,
          height: 40.0,
          padding: const EdgeInsets.all(1.5),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF6366F1)],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          child: ClipOval(
            child: avatarUrl != null && avatarUrl.isNotEmpty
                ? Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildFallbackAvatar(displayName),
                  )
                : _buildFallbackAvatar(displayName),
          ),
        ),
        const SizedBox(width: 12.0),

        // 2. Name & Handle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 1.5),
              Text(
                '@$username • $major',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFA1A1AA),
                ),
              ),
            ],
          ),
        ),

        // 3. Create Action Button (+)
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onCreatePost?.call();
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF18181B),
              border: Border.all(color: const Color(0xFF27272A), width: 1.0),
            ),
            child: const Center(
              child: Icon(
                CupertinoIcons.plus,
                size: 16.0,
                color: Color(0xFFD4D4D8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackAvatar(String name) {
    return Container(
      color: const Color(0xFF161618),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'S',
        style: const TextStyle(
          fontFamily: 'SFPro',
          fontSize: 15.0,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
