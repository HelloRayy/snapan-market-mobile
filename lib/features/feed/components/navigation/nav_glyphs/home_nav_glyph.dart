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

    // Geometric proportions calibrated 1:1 to reference outline:
    final left = w * 0.13;
    final right = w * 0.87;
    final bottom = h * 0.87;
    final eaveY = h * 0.43;
    final peakY = h * 0.13;
    final peakX = w * 0.50;
    final cornerR = w * 0.08; // Bottom corner radius (~1.8px)

    final path = Path()
      ..moveTo(left, eaveY)
      ..lineTo(peakX, peakY)
      ..lineTo(right, eaveY)
      ..lineTo(right, bottom - cornerR)
      ..arcToPoint(
        Offset(right - cornerR, bottom),
        radius: Radius.circular(cornerR),
      )
      ..lineTo(left + cornerR, bottom)
      ..arcToPoint(
        Offset(left, bottom - cornerR),
        radius: Radius.circular(cornerR),
      )
      ..close();

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (isFilled) {
      final fillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
    } else {
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ThreadsHomePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isFilled != isFilled;
  }
}
