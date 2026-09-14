import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// 2. Paper Plane Glyph (Curved Paperplane with Red Badge)
class PaperPlaneNavGlyph extends StatelessWidget {
  final bool isActive;
  final bool hasBadge;
  final int badgeCount;

  const PaperPlaneNavGlyph({
    super.key,
    required this.isActive,
    this.hasBadge = false,
    this.badgeCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    final plane = SizedBox(
      width: 24.0,
      height: 24.0,
      child: CustomPaint(
        painter: _PaperPlanePainter(
          color: isActive ? AppColors.ink : const Color(0xFF787574),
          isActive: isActive,
        ),
      ),
    );

    if (!hasBadge) {
      return plane;
    }

    // Mini dot badge when badgeCount is 0 or unread indicator
    if (badgeCount <= 0) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          plane,
          Positioned(
            top: -2.0,
            right: -3.0,
            child: Container(
              width: 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                color: const Color(0xFFFF3040),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2.0,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        plane,
        Positioned(
          top: -4.0,
          right: -7.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.0),
            constraints: const BoxConstraints(
              minWidth: 16.0,
              minHeight: 16.0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF008BFF), // pen.dev Primary Azure (#008BFF)
              shape: badgeCount > 9 ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: badgeCount > 9 ? BorderRadius.circular(9.0) : null,
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF008BFF).withValues(alpha: 0.35),
                  blurRadius: 4.0,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Text(
                badgeCount > 99 ? '99+' : badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PaperPlanePainter extends CustomPainter {
  final Color color;
  final bool isActive;

  _PaperPlanePainter({required this.color, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = isActive ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(w * 0.94, h * 0.08);
    path.lineTo(w * 0.40, h * 0.92);
    path.lineTo(w * 0.40, h * 0.58);
    path.lineTo(w * 0.08, h * 0.44);
    path.close();

    if (!isActive) {
      path.moveTo(w * 0.40, h * 0.58);
      path.lineTo(w * 0.94, h * 0.08);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PaperPlanePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isActive != isActive;
  }
}
