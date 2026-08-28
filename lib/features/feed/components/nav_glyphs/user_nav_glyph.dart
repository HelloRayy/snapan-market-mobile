import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// 5. User Glyph (Minimalist Person Icon / Avatar)
class UserNavGlyph extends StatelessWidget {
  final bool isActive;
  final String? userAvatar;

  const UserNavGlyph({
    super.key,
    required this.isActive,
    this.userAvatar,
  });

  @override
  Widget build(BuildContext context) {
    if (userAvatar != null && userAvatar!.isNotEmpty) {
      return Container(
        width: 26.0,
        height: 26.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? AppColors.ink : const Color(0xFFCBD5E1),
            width: 1.0,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13.0),
          child: Image.network(
            userAvatar!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildFallbackGlyph(),
          ),
        ),
      );
    }

    return _buildFallbackGlyph();
  }

  Widget _buildFallbackGlyph() {
    return SizedBox(
      width: 24.0,
      height: 24.0,
      child: CustomPaint(
        painter: _UserPainter(
          color: isActive ? AppColors.ink : const Color(0xFF787574),
          isActive: isActive,
        ),
      ),
    );
  }
}

class _UserPainter extends CustomPainter {
  final Color color;
  final bool isActive;

  _UserPainter({required this.color, required this.isActive});

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

    // Head circle
    canvas.drawCircle(Offset(w * 0.5, h * 0.32), w * 0.22, paint);

    // Body arc
    final bodyPath = Path();
    bodyPath.moveTo(w * 0.16, h * 0.88);
    bodyPath.quadraticBezierTo(w * 0.16, h * 0.64, w * 0.5, h * 0.64);
    bodyPath.quadraticBezierTo(w * 0.84, h * 0.64, w * 0.84, h * 0.88);

    if (isActive) {
      bodyPath.close();
    }

    canvas.drawPath(bodyPath, paint);
  }

  @override
  bool shouldRepaint(covariant _UserPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isActive != isActive;
  }
}
