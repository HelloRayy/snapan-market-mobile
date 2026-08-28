import 'package:flutter/material.dart';

/// 4. Heart Glyph (Outline / Solid Heart)
class HeartNavGlyph extends StatelessWidget {
  final bool isActive;
  final bool hasBadge;

  const HeartNavGlyph({
    super.key,
    required this.isActive,
    this.hasBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final heart = SizedBox(
      width: 24.0,
      height: 24.0,
      child: CustomPaint(
        painter: _HeartPainter(
          color: isActive ? const Color(0xFFF43F5E) : const Color(0xFF787574),
          isActive: isActive,
        ),
      ),
    );

    if (!hasBadge) return heart;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        heart,
        Positioned(
          top: -1.0,
          right: -2.0,
          child: Container(
            width: 7.0,
            height: 7.0,
            decoration: BoxDecoration(
              color: const Color(0xFFFF3B30),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeartPainter extends CustomPainter {
  final Color color;
  final bool isActive;

  _HeartPainter({required this.color, required this.isActive});

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
    path.moveTo(w * 0.5, h * 0.86);
    path.cubicTo(
      w * 0.12,
      h * 0.58,
      w * 0.04,
      h * 0.32,
      w * 0.08,
      h * 0.22,
    );
    path.cubicTo(
      w * 0.12,
      h * 0.08,
      w * 0.32,
      h * 0.06,
      w * 0.5,
      h * 0.26,
    );
    path.cubicTo(
      w * 0.68,
      h * 0.06,
      w * 0.88,
      h * 0.08,
      w * 0.92,
      h * 0.22,
    );
    path.cubicTo(
      w * 0.96,
      h * 0.32,
      w * 0.88,
      h * 0.58,
      w * 0.5,
      h * 0.86,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeartPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isActive != isActive;
  }
}
