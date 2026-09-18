import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

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
    return GestureDetector(
      onTap: () {
        onUserClick?.call(username ?? name);
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 4.0,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.network(
            avatarUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: AppColors.primaryPastel,
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: TextStyle(
                    fontSize: size * 0.4,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
