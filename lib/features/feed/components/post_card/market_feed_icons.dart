import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// 1. Heart Icon (Active: Solid Rose #E11D48, Inactive: Sleek Outline)
class FeedHeartIcon extends StatelessWidget {
  final bool isLiked;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final double strokeWidth;

  const FeedHeartIcon({
    super.key,
    required this.isLiked,
    this.size = 19.0,
    this.activeColor,
    this.inactiveColor,
    this.strokeWidth = 1.85,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? const Color(0xFFE11D48);
    final effectiveInactiveColor = inactiveColor ?? const Color(0xFF334155);

    return Icon(
      isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
      size: size,
      color: isLiked ? effectiveActiveColor : effectiveInactiveColor,
    );
  }
}

/// 2. Comment Icon (Cupertino Speech Bubble)
class FeedCommentIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const FeedCommentIcon({
    super.key,
    this.size = 19.0,
    this.color,
    this.strokeWidth = 1.85,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      CupertinoIcons.chat_bubble,
      size: size,
      color: color ?? const Color(0xFF334155),
    );
  }
}

/// 3. Repost Icon (Active: Solid Emerald #10B981, Inactive: Slate)
class FeedRepostIcon extends StatelessWidget {
  final bool isReposted;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final double strokeWidth;

  const FeedRepostIcon({
    super.key,
    this.isReposted = false,
    this.size = 19.0,
    this.activeColor,
    this.inactiveColor,
    this.strokeWidth = 1.85,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? const Color(0xFF10B981);
    final effectiveInactiveColor = inactiveColor ?? const Color(0xFF334155);

    return Icon(
      CupertinoIcons.arrow_2_squarepath,
      size: size,
      color: isReposted ? effectiveActiveColor : effectiveInactiveColor,
    );
  }
}

/// 4. Share Icon (Cupertino Paperplane)
class FeedShareIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const FeedShareIcon({
    super.key,
    this.size = 19.0,
    this.color,
    this.strokeWidth = 1.85,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      CupertinoIcons.paperplane,
      size: size,
      color: color ?? const Color(0xFF334155),
    );
  }
}

/// 5. Bookmark Icon (Active: Solid Indigo #3D38F5, Inactive: Slate)
class FeedBookmarkIcon extends StatelessWidget {
  final bool isBookmarked;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const FeedBookmarkIcon({
    super.key,
    required this.isBookmarked,
    this.size = 19.0,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppColors.primary;
    final effectiveInactiveColor = inactiveColor ?? const Color(0xFF334155);

    return Icon(
      isBookmarked ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
      size: size,
      color: isBookmarked ? effectiveActiveColor : effectiveInactiveColor,
    );
  }
}

/// 6. Threads Topic Glyph
class ThreadsTopicGlyph extends StatelessWidget {
  final double size;
  final Color? color;

  const ThreadsTopicGlyph({
    super.key,
    this.size = 14.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      CupertinoIcons.bubble_left_bubble_right,
      size: size,
      color: color ?? const Color(0xFF1D64EC),
    );
  }
}

/// 7. Presentation / PJBL Topic Glyph
class PresentationTopicGlyph extends StatelessWidget {
  final double size;
  final Color? color;

  const PresentationTopicGlyph({
    super.key,
    this.size = 14.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.slideshow_rounded,
      size: size,
      color: color ?? const Color(0xFF1D64EC),
    );
  }
}

/// 8. Verified Badge Icon
class VerifiedBadgeIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const VerifiedBadgeIcon({
    super.key,
    this.size = 15.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.verified_rounded,
      size: size,
      color: color ?? AppColors.verifiedBlue,
    );
  }
}

/// 9. Feed Box / Parcel Icon for Product Stock
class FeedBoxIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const FeedBoxIcon({
    super.key,
    this.size = 13.5,
    this.color,
    this.strokeWidth = 1.8,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      CupertinoIcons.cube_box,
      size: size,
      color: color ?? const Color(0xFF71717A),
    );
  }
}
