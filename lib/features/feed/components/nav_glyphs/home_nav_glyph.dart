import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// 1. Minimalist Threads-style Home Nav Glyph (Exact match to official Threads Home outline/fill)
class HomeNavGlyph extends StatelessWidget {
  final bool isActive;
  final double size;

  const HomeNavGlyph({
    super.key,
    required this.isActive,
    this.size = 22.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _ThreadsHomePainter(
          color: isActive ? AppColors.primary : const Color(0xFF64748B),
          isFilled: isActive,
        ),
      ),
    );
  }
}

class _ThreadsHomePainter extends CustomPainter {
  final Color color;
  final bool isFilled;

  const _ThreadsHomePainter({
    required this.color,
    required this.isFilled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Outer bounding coordinates with padding for 2.2px stroke
    final left = w * 0.12;
    final right = w * 0.88;
    final bottom = h * 0.88;
    final eaveY = h * 0.42;
    final peakY = h * 0.12;
    final peakX = w * 0.50;
    final r = w * 0.085; // Corner rounding radius (~2.0px)

    final path = Path();
    // 1. Start bottom-left, rounded into bottom edge
    path.moveTo(left + r, bottom);
    // 2. Bottom flat edge to bottom-right
    path.lineTo(right - r, bottom);
    // 3. Bottom-right rounded corner
    path.arcToPoint(
      Offset(right, bottom - r),
      radius: Radius.circular(r),
    );
    // 4. Right vertical wall up to eave
    path.lineTo(right, eaveY + r);
    // 5. Right eave rounded corner transitioning to roof slope
    path.arcToPoint(
      Offset(right - r * 0.6, eaveY - r * 0.4),
      radius: Radius.circular(r),
    );
    // 6. Roof slope up towards peak
    path.lineTo(peakX + r * 0.6, peakY + r * 0.5);
    // 7. Peak rounded top ridge
    path.arcToPoint(
      Offset(peakX - r * 0.6, peakY + r * 0.5),
      radius: Radius.circular(r),
    );
    // 8. Roof slope down towards left eave
    path.lineTo(left + r * 0.6, eaveY - r * 0.4);
    // 9. Left eave rounded corner transitioning into left wall
    path.arcToPoint(
      Offset(left, eaveY + r),
      radius: Radius.circular(r),
    );
    // 10. Left vertical wall down towards base
    path.lineTo(left, bottom - r);
    // 11. Bottom-left rounded corner back to start
    path.arcToPoint(
      Offset(left + r, bottom),
      radius: Radius.circular(r),
    );
    path.close();

    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (isFilled) {
      paint.style = PaintingStyle.fill;
      canvas.drawPath(path, paint);
    } else {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2.2;
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ThreadsHomePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isFilled != isFilled;
  }
}
