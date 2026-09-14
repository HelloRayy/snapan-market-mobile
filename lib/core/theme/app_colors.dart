import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary (Electric Vivid Cyan)
  static const Color primary = Color(0xFF00A3FF);
  static const Color primaryDark = Color(0xFF0284C7);
  static const Color primaryPastel = Color(0xFFF0F9FF);
  static const Color primaryRing = Color(0x3300A3FF);

  // Gradient Palette (Electric Cyan Spectrum - AMOLED & Vibrant Display)
  static const Color gradientTop = Color(0xFF00A3FF); // Electric Cyan
  static const Color gradientMid = Color(0xFF38BDF8); // Sky 400
  static const Color gradientBottom = Color(0xFF7DD3FC); // Soft Cyan

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
