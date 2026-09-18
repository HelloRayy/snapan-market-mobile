import 'package:flutter/material.dart';

enum ThreadLineType {
  /// Vertical line that curves 90 degrees to the right at the bottom (╰─)
  elbow,

  /// Straight continuous vertical line (|)
  straight,

  /// Continuous vertical line with a branch to the right (├─)
  tBranch,
}

/// Custom painter that draws Threads-style curved thread connection lines
class ThreadBranchPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double curveRadius;
  final double avatarCenterX;
  final ThreadLineType type;

  const ThreadBranchPainter({
    this.color = const Color(0xFFE2E8F0),
    this.strokeWidth = 1.8,
    this.curveRadius = 16.0,
    this.avatarCenterX = 18.0,
    this.type = ThreadLineType.elbow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final x = avatarCenterX;
    final r = curveRadius.clamp(4.0, size.height / 2);

    switch (type) {
      case ThreadLineType.elbow:
        // Start from top, go down, then smooth curve to the right
        path.moveTo(x, 0);
        if (size.height > r) {
          path.lineTo(x, size.height - r);
          path.quadraticBezierTo(
            x,
            size.height,
            x + r,
            size.height,
          );
          if (size.width > x + r) {
            path.lineTo(size.width, size.height);
          }
        } else {
          path.lineTo(x, size.height);
        }
        break;

      case ThreadLineType.straight:
        path.moveTo(x, 0);
        path.lineTo(x, size.height);
        break;

      case ThreadLineType.tBranch:
        // Straight line top to bottom
        path.moveTo(x, 0);
        path.lineTo(x, size.height);
        // Branch to the right at half height or top
        final branchY = (size.height / 2).clamp(r, size.height - r);
        path.moveTo(x, branchY - r);
        path.quadraticBezierTo(x, branchY, x + r, branchY);
        path.lineTo(size.width, branchY);
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ThreadBranchPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.curveRadius != curveRadius ||
        oldDelegate.avatarCenterX != avatarCenterX ||
        oldDelegate.type != type;
  }
}
