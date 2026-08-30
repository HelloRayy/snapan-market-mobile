import 'package:flutter/material.dart';

/// 1. Lucide-Style Heart Icon (Active: Solid Rose, Inactive: Sleek Outline)
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

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FeedHeartPainter(
          isLiked: isLiked,
          color: isLiked ? effectiveActiveColor : effectiveInactiveColor,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _FeedHeartPainter extends CustomPainter {
  final bool isLiked;
  final Color color;
  final double strokeWidth;

  _FeedHeartPainter({
    required this.isLiked,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sx = w / 24.0;
    final sy = h / 24.0;

    final paint = Paint()
      ..color = color
      ..style = isLiked ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = strokeWidth * (w / 24.0)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(19.0 * sx, 14.0 * sy);
    path.relativeCubicTo(
      1.49 * sx,
      -1.46 * sy,
      3.0 * sx,
      -3.21 * sy,
      3.0 * sx,
      -5.5 * sy,
    );
    path.arcToPoint(
      Offset(16.5 * sx, 3.0 * sy),
      radius: Radius.circular(5.5 * sx),
      clockwise: false,
    );
    path.relativeCubicTo(
      -1.76 * sx,
      0.0,
      -3.0 * sx,
      0.5 * sy,
      -4.5 * sx,
      2.0 * sy,
    );
    path.relativeCubicTo(
      -1.5 * sx,
      -1.5 * sy,
      -2.74 * sx,
      -2.0 * sy,
      -4.5 * sx,
      -2.0 * sy,
    );
    path.arcToPoint(
      Offset(2.0 * sx, 8.5 * sy),
      radius: Radius.circular(5.5 * sx),
      clockwise: false,
    );
    path.relativeCubicTo(
      0.0,
      2.3 * sy,
      1.5 * sx,
      4.05 * sy,
      3.0 * sx,
      5.5 * sy,
    );
    path.lineTo(12.0 * sx, 21.0 * sy);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FeedHeartPainter oldDelegate) {
    return oldDelegate.isLiked != isLiked ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// 2. Smooth Rounded Comment Icon (Identical to Web React SmoothCommentIcon)
class FeedCommentIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const FeedCommentIcon({
    super.key,
    this.size = 18.0,
    this.color,
    this.strokeWidth = 1.85,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? const Color(0xFF334155);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FeedCommentPainter(
          color: effectiveColor,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _FeedCommentPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _FeedCommentPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sx = w / 24.0;
    final sy = h / 24.0;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * (w / 24.0)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // SVG: M2.992 16.342a2 2 0 0 1 .094 1.167l-.8 2.5c-.25.78.47 1.5 1.25 1.25l2.5-.8a2 2 0 0 1 1.1.09 10 10 0 1 0-4.144-4.207Z
    final path = Path();
    path.moveTo(2.992 * sx, 16.342 * sy);
    path.arcToPoint(
      Offset((2.992 + 0.094) * sx, (16.342 + 1.167) * sy),
      radius: Radius.circular(2.0 * sx),
      clockwise: true,
    );
    path.relativeLineTo(-0.8 * sx, 2.5 * sy);
    path.relativeCubicTo(
      -0.25 * sx,
      0.78 * sy,
      0.47 * sx,
      1.5 * sy,
      1.25 * sx,
      1.25 * sy,
    );
    path.relativeLineTo(2.5 * sx, -0.8 * sy);
    path.arcToPoint(
      Offset((6.036 + 1.1) * sx, (20.459 + 0.09) * sy),
      radius: Radius.circular(2.0 * sx),
      clockwise: true,
    );
    path.arcToPoint(
      Offset(2.992 * sx, 16.342 * sy),
      radius: Radius.circular(10.0 * sx),
      largeArc: true,
      clockwise: false,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FeedCommentPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

/// 3. Lucide Repeat2 Repost Icon (Active: Emerald Green, Inactive: Slate Gray)
class FeedRepostIcon extends StatelessWidget {
  final bool isReposted;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final double strokeWidth;

  const FeedRepostIcon({
    super.key,
    required this.isReposted,
    this.size = 19.0,
    this.activeColor,
    this.inactiveColor,
    this.strokeWidth = 1.85,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? const Color(0xFF10B981);
    final effectiveInactiveColor = inactiveColor ?? const Color(0xFF334155);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FeedRepostPainter(
          color: isReposted ? effectiveActiveColor : effectiveInactiveColor,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _FeedRepostPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _FeedRepostPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sx = w / 24.0;
    final sy = h / 24.0;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * (w / 24.0)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Top-left arrow: m2 9 3-3 3 3
    path.moveTo(2.0 * sx, 9.0 * sy);
    path.lineTo(5.0 * sx, 6.0 * sy);
    path.lineTo(8.0 * sx, 9.0 * sy);

    // Bottom left curve: M13 18H7a2 2 0 0 1-2-2V6
    path.moveTo(13.0 * sx, 18.0 * sy);
    path.lineTo(7.0 * sx, 18.0 * sy);
    path.arcToPoint(
      Offset(5.0 * sx, 16.0 * sy),
      radius: Radius.circular(2.0 * sx),
      clockwise: false,
    );
    path.lineTo(5.0 * sx, 6.0 * sy);

    // Bottom-right arrow: m22 15-3 3-3-3
    path.moveTo(22.0 * sx, 15.0 * sy);
    path.lineTo(19.0 * sx, 18.0 * sy);
    path.lineTo(16.0 * sx, 15.0 * sy);

    // Top right curve: M11 6h6a2 2 0 0 1 2 2v10
    path.moveTo(11.0 * sx, 6.0 * sy);
    path.lineTo(17.0 * sx, 6.0 * sy);
    path.arcToPoint(
      Offset(19.0 * sx, 8.0 * sy),
      radius: Radius.circular(2.0 * sx),
      clockwise: false,
    );
    path.lineTo(19.0 * sx, 18.0 * sy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FeedRepostPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

/// 4. Lucide Send Paperplane Share Icon (Clean Angular Lines)
class FeedShareIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const FeedShareIcon({
    super.key,
    this.size = 18.0,
    this.color,
    this.strokeWidth = 1.85,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? const Color(0xFF334155);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FeedSharePainter(
          color: effectiveColor,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _FeedSharePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _FeedSharePainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sx = w / 24.0;
    final sy = h / 24.0;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * (w / 24.0)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    // Outer body: m22 2-7 20-4-9-9-4Z
    path.moveTo(22.0 * sx, 2.0 * sy);
    path.lineTo(15.0 * sx, 22.0 * sy);
    path.lineTo(11.0 * sx, 13.0 * sy);
    path.lineTo(2.0 * sx, 9.0 * sy);
    path.close();

    // Center fold: M22 2 11 13
    path.moveTo(22.0 * sx, 2.0 * sy);
    path.lineTo(11.0 * sx, 13.0 * sy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FeedSharePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

/// 5. Threads 3-Dot Topic Glyph (Matches ThreadsTopicIcon.tsx)
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
    final effectiveColor = color ?? const Color(0xFF1D64EC);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ThreadsTopicPainter(color: effectiveColor),
      ),
    );
  }
}

class _ThreadsTopicPainter extends CustomPainter {
  final Color color;

  _ThreadsTopicPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sx = w / 24.0;
    final sy = h / 24.0;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final r = 3.0 * sx;

    // Circle (6, 8)
    canvas.drawCircle(Offset(6.0 * sx, 8.0 * sy), r, paint);
    // Circle (6, 16)
    canvas.drawCircle(Offset(6.0 * sx, 16.0 * sy), r, paint);
    // Circle (15, 12)
    canvas.drawCircle(Offset(15.0 * sx, 12.0 * sy), r, paint);
  }

  @override
  bool shouldRepaint(covariant _ThreadsTopicPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// 6. Presentation / PJBL Topic Glyph
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

/// 7. Verified Badge Icon
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
      color: color ?? const Color(0xFF3D38F5),
    );
  }
}

/// 8. Lucide Box Icon (Isometric 3D parcel box matching Web React Lucide Box 1:1)
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
    final effectiveColor = color ?? const Color(0xFF71717A);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FeedBoxPainter(
          color: effectiveColor,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _FeedBoxPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _FeedBoxPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sx = w / 24.0;
    final sy = h / 24.0;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * (w / 24.0)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Outer 3D Hexagonal Cube outline
    path.moveTo(3.0 * sx, 7.5 * sy);
    path.lineTo(12.0 * sx, 2.5 * sy);
    path.lineTo(21.0 * sx, 7.5 * sy);
    path.lineTo(21.0 * sx, 16.5 * sy);
    path.lineTo(12.0 * sx, 21.5 * sy);
    path.lineTo(3.0 * sx, 16.5 * sy);
    path.close();

    // Center Y-fold lines (top-left to center, top-right to center, center to bottom)
    path.moveTo(3.0 * sx, 7.5 * sy);
    path.lineTo(12.0 * sx, 12.0 * sy);
    path.lineTo(21.0 * sx, 7.5 * sy);
    path.moveTo(12.0 * sx, 12.0 * sy);
    path.lineTo(12.0 * sx, 21.5 * sy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FeedBoxPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}


