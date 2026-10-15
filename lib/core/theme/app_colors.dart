import 'package:flutter/material.dart';

class AppColors {
  // Brand Signature: Electric Indigo (#3D38F5) matching src/index.css (WCAG AA 6.86:1 contrast)
  static const Color primary = Color(0xFF3D38F5);
  static const Color primaryDark = Color(0xFF312BD9);
  static const Color primaryPastel = Color(0xFFEEF0FF);
  static const Color pastelPrimary = primaryPastel;
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

  // Neutral Canvas & Ink (Aligned with Meta Threads Barcelona / WDS Paper White #FAFAFA)
  static const Color canvas = Color(0xFFFAFAFA);
  static const Color white = Colors.white;
  static const Color ink = Color(0xFF1A1A1A);
  static const Color slateInk = Color(0xFF334155);
  static const Color muted = Color(0xFF727272);
  static const Color mutedGray = muted;
  static const Color lightMuted = Color(0xFF999999);
  static const Color border = Color(0xFFE2E8F0);
  static const Color separator = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color selectionBg = Color(0xFFEDEDED);
  static const Color inputBg = Color(0xFFF8FAFC);

  // Status & Highlights
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color linkBlue = Color(0xFF008BFF);

  // Threads Design Tokens (THREAD-INSPO.md)
  static const Color inkBlack = Color(0xFF000000);
  static const Color paperWhite = Color(0xFFFAFAFA);
  static const Color mistGray = Color(0xFFEFEFEF);
  static const Color cloudGray = Color(0xFFD5D5D5);
  static const Color ashGray = Color(0xFF969696);
  static const Color graphite = Color(0xFF424242);
  static const Color metaBlue = Color(0xFF1D64EC);
  static const Color verifiedBlue = Color(0xFF1D64EC);

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

  // ===========================================================================
  // PRODUCTION META THREADS DARK MODE TOKENS (PROJECT BARCELONA / WDS)
  // ===========================================================================

  /// Canvas / Root OLED pure black background (--surface-background)
  static const Color darkCanvas = Color(0xFF000000);

  /// Card Surface default for feed posts (--WDS-surface-default)
  static const Color darkSurface = Color(0xFF161717);

  /// Elevated containers for modal sheets, dialogs (--WDS-surface-elevated-default)
  static const Color darkSurfaceElevated = Color(0xFF1D1F1F);

  /// Floating popover menus and tooltips (--WDS-surface-elevated-emphasized)
  static const Color darkSurfaceEmphasized = Color(0xFF242626);

  /// State hover / highlight touch feedback (--WDS-surface-highlight)
  static const Color darkSurfaceHighlight = Color(0x1AFFFFFF); // 10% white

  /// State pressed / active touch feedback (--WDS-surface-pressed)
  static const Color darkSurfacePressed = Color(0x33FFFFFF); // 20% white

  /// Primary high-contrast text on dark surface
  static const Color darkTextPrimary = Color(0xFFF8FAFC);

  /// Secondary muted text (60% white - prevents glare & halation)
  static const Color darkTextSecondary = Color(0x99FFFFFF); // ~60% white

  /// Disabled text and input placeholders (--WDS-content-disabled)
  static const Color darkTextDisabled = Color(0xFF424445);

  /// Subtle border lines & feed dividers (--WDS-lines-divider / --card-border-color)
  static const Color darkBorder = Color(0x1AFFFFFF); // 10% white
  static const Color darkDivider = Color(0x1AFFFFFF);

  /// Dark mode brand accent adjustment (softer luminance glow on dark background)
  static const Color darkPrimary = Color(0xFF6366F1);
  static const Color darkPrimaryDark = Color(0xFF4F46E5);
  static const Color darkPrimaryPastel = Color(0xFF1E1B4B);

  /// Context-Aware Adaptive Color Helpers
  static Color adaptiveCanvas(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCanvas : canvas;

  static Color adaptiveSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurface : Colors.white;

  static Color adaptiveSurfaceElevated(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurfaceElevated : Colors.white;

  static Color adaptiveText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : ink;

  static Color adaptiveMuted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : muted;

  static Color adaptiveBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBorder : border;

  static Color adaptiveDivider(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkDivider : separator;
}
