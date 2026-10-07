import 'package:flutter/cupertino.dart';

/// Global flag to force default profile avatar across the entire app.
/// Set to false so that users with an avatar in the database display their photo,
/// while users without a photo gracefully fallback to DefaultProfileAvatar.
const bool kForceDefaultProfileAvatar = false;

/// Standard default profile avatar with neutral gray background and person silhouette icon,
/// matching standard mobile app design (Instagram/X/TikTok) when a user has no profile photo.
class DefaultProfileAvatar extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final BoxBorder? border;

  const DefaultProfileAvatar({
    super.key,
    required this.size,
    this.backgroundColor,
    this.iconColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? const Color(0xFFE2E8F0),
        border: border,
      ),
      child: Center(
        child: Icon(
          CupertinoIcons.person_fill,
          size: (size * 0.56).clamp(10.0, 72.0),
          color: iconColor ?? const Color(0xFF94A3B8),
        ),
      ),
    );
  }
}

/// Universal AppAvatar widget that handles forced default avatars and graceful fallbacks.
class AppAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double size;
  final String? name;
  final String? username;
  final VoidCallback? onTap;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Color? backgroundColor;
  final Color? iconColor;

  const AppAvatar({
    super.key,
    this.avatarUrl,
    required this.size,
    this.name,
    this.username,
    this.onTap,
    this.border,
    this.boxShadow,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final cleanUrl = avatarUrl?.trim();
    if (kForceDefaultProfileAvatar || cleanUrl == null || cleanUrl.isEmpty) {
      Widget avatar = DefaultProfileAvatar(
        size: size,
        border: border,
        backgroundColor: backgroundColor,
        iconColor: iconColor,
      );
      if (boxShadow != null && boxShadow!.isNotEmpty) {
        avatar = Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: boxShadow,
          ),
          child: avatar,
        );
      }
      if (onTap != null) {
        avatar = GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: avatar,
        );
      }
      return avatar;
    }

    Widget content;
    if (cleanUrl.startsWith('assets/')) {
      content = Image.asset(
        cleanUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => DefaultProfileAvatar(
          size: size,
          backgroundColor: backgroundColor,
          iconColor: iconColor,
        ),
      );
    } else {
      content = Image.network(
        cleanUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => DefaultProfileAvatar(
          size: size,
          backgroundColor: backgroundColor,
          iconColor: iconColor,
        ),
      );
    }

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
        boxShadow: boxShadow,
      ),
      child: ClipOval(child: content),
    );

    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: avatar,
      );
    }
    return avatar;
  }
}
