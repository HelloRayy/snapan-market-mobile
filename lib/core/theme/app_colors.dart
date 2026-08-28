import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary
  static const Color primary = Color(0xFF3D38F5);
  static const Color primaryDark = Color(0xFF312BD9);
  static const Color primaryPastel = Color(0xFFEEF0FF);
  static const Color primaryRing = Color(0x263D38F5);

  // Gradient Palette
  static const Color gradientIndigo = Color(0xFF6366F1);
  static const Color gradientLavender = Color(0xFF818CF8);
  static const Color gradientSky = Color(0xFF93C5FD);

  // Neutral Canvas & Ink
  static const Color canvas = Color(0xFFF8FAFC);
  static const Color white = Colors.white;
  static const Color ink = Color(0xFF0F172A);
  static const Color slateInk = Color(0xFF334155);
  static const Color muted = Color(0xFF64748B);
  static const Color lightMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color inputBg = Color(0xFFF8FAFC);

  // Status & Highlights
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color linkBlue = Color(0xFF0EA5E9);

  // Gradients
  static const LinearGradient authGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      gradientIndigo,
      gradientLavender,
      gradientSky,
    ],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primary,
      gradientIndigo,
      gradientLavender,
    ],
  );
}
