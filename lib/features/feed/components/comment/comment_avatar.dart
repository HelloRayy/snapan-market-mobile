import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/ui/oreo_avatar_helper.dart';

/// Standard 36x36 Circular Avatar for comment authors & replies
class CommentAvatar extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String? username;
  final double size;
  final ValueChanged<String>? onUserClick;

  const CommentAvatar({
    super.key,
    required this.avatarUrl,
    required this.name,
    this.username,
    this.size = 36.0,
    this.onUserClick,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveUser = (username != null && username!.trim().isNotEmpty)
        ? username!.trim().replaceAll('@', '')
        : name;
    return AppAvatar(
      avatarUrl: avatarUrl,
      size: size,
      name: name,
      username: username,
      onTap: onUserClick != null
          ? () {
              HapticFeedback.lightImpact();
              onUserClick!(effectiveUser);
            }
          : null,
    );
  }
}
