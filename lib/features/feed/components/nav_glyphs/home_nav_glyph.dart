import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// 1. Home Glyph (Solid Rounded House Polygon)
class HomeNavGlyph extends StatelessWidget {
  final bool isActive;

  const HomeNavGlyph({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24.0,
      height: 24.0,
      child: CustomPaint(
        painter: _HomePainter(
          color: isActive ? AppColors.ink : const Color(0xFF787574),
          isActive: isActive,
        ),
      ),
    );
  }
}

class _HomePainter extends CustomPainter {
  final Color color;
  final bool isActive;

  _HomePainter({required this.color, required this.isActive});

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
    path.moveTo(w * 0.5, h * 0.08);
    path.lineTo(w * 0.92, h * 0.42);
    path.lineTo(w * 0.88, h * 0.82);
    path.quadraticBezierTo(w * 0.88, h * 0.94, w * 0.76, h * 0.94);
    path.lineTo(w * 0.24, h * 0.94);
    path.quadraticBezierTo(w * 0.12, h * 0.94, w * 0.12, h * 0.82);
    path.lineTo(w * 0.08, h * 0.42);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HomePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isActive != isActive;
  }
}
