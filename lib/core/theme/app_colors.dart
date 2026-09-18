import 'package:flutter/material.dart';

class AppColors {
  // Brand Signature: Electric Indigo (#3D38F5) matching src/index.css (WCAG AA 6.86:1 contrast)
  static const Color primary = Color(0xFF3D38F5);
  static const Color primaryDark = Color(0xFF312BD9);
  static const Color primaryPastel = Color(0xFFEEF0FF);
  static const Color primaryBorder = Color(0xFFD8DBFE);
  static const Color primaryRing = Color(0x263D38F5);

  // Gradient Palette (Electric Indigo Spectrum)
  static const Color gradientTop = Color(0xFF534EF7); // Light Indigo Specular
  static const Color gradientMid = Color(0xFF3D38F5); // Brand Primary
  static const Color gradientBottom = Color(0xFF312BD9); // Deep Indigo Base

  // Backward-compatible Aliases
  static const Color gradientIndigo = gradientTop;
  static const Color gradientLavender = gradientMid;
  static const Color gradientSky = gradientBottom;

  // Neutral Canvas & Ink (Matching pen.dev #1A1A1A, #EDEDED, #727272, #999999)
  static const Color canvas = Color(0xFFF8FAFC);
  static const Color white = Colors.white;
  static const Color ink = Color(0xFF1A1A1A);
  static const Color slateInk = Color(0xFF334155);
  static const Color muted = Color(0xFF727272);
  static const Color lightMuted = Color(0xFF999999);
  static const Color border = Color(0xFFE2E8F0);
  static const Color selectionBg = Color(0xFFEDEDED);
  static const Color inputBg = Color(0xFFF8FAFC);

  // Status & Highlights
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color linkBlue = Color(0xFF008BFF);

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
