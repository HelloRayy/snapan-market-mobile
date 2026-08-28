import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary (Kumo Pure Blue)
  static const Color primary = Color(0xFF1D64EC);
  static const Color primaryDark = Color(0xFF154EC1);
  static const Color primaryPastel = Color(0xFFEFF6FF);
  static const Color primaryRing = Color(0x261D64EC);

  // Gradient Palette (Pure Kumo Blue Spectrum - 100% Pure Blue on AMOLED & sRGB)
  static const Color gradientTop = Color(0xFF1D64EC); // Kumo Primary Blue
  static const Color gradientMid = Color(0xFF3B82F6); // Blue 500
  static const Color gradientBottom = Color(0xFF93C5FD); // Blue 300 / Sky

  // Backward-compatible Aliases
  static const Color gradientIndigo = gradientTop;
  static const Color gradientLavender = gradientMid;
  static const Color gradientSky = gradientBottom;

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
      gradientTop,
      gradientMid,
      gradientBottom,
    ],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primary,
      gradientMid,
      gradientBottom,
    ],
  );
}
