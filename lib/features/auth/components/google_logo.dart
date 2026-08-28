import 'package:flutter/material.dart';

class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double strokeWidth = w * 0.22;
    final Rect rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      w - strokeWidth,
      h - strokeWidth,
    );

    final Paint redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Paint yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Paint greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Paint bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Red Arc (Top)
    canvas.drawArc(rect, -2.35, 1.57, false, redPaint);

    // Yellow Arc (Left)
    canvas.drawArc(rect, 2.35, 1.57, false, yellowPaint);

    // Green Arc (Bottom)
    canvas.drawArc(rect, 0.78, 1.57, false, greenPaint);

    // Blue Arc (Right)
    canvas.drawArc(rect, -0.78, 1.57, false, bluePaint);

    // Blue horizontal crossbar
    final Paint blueFill = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final Rect barRect = Rect.fromLTWH(
      w * 0.45,
      h * 0.39,
      w * 0.52,
      strokeWidth,
    );
    canvas.drawRect(barRect, blueFill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
