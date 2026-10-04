import 'package:flutter/material.dart';
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
    return AppAvatar(
      avatarUrl: avatarUrl,
      size: size,
      name: name,
      username: username,
      onTap: onUserClick != null ? () => onUserClick!(username ?? name) : null,
      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 4.0,
          offset: Offset(0, 1),
        ),
      ],
    );
  }
}
