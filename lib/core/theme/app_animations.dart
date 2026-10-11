import 'package:flutter/animation.dart';
import 'package:flutter/services.dart';

/// Motion and Animation Tokens for Snaps Mobile
/// Governs durations, physics curves, and tactile haptic feedback (SNAPS-26).
class AppAnimations {
  AppAnimations._();

  // --- Durations ---
  /// Micro interactions (icon pops, press states)
  static const Duration quick = Duration(milliseconds: 160);

  /// Elastic like bounce duration
  static const Duration likeBounce = Duration(milliseconds: 280);

  /// Double tap heart animation duration
  static const Duration doubleTapHeart = Duration(milliseconds: 700);

  /// Standard tab transitions and sliding indicators
  static const Duration tabDuration = Duration(milliseconds: 280);

  /// Full page slide or screen push transitions
  static const Duration pageDuration = Duration(milliseconds: 320);

  /// Modal and sheet reveal animations
  static const Duration modalDuration = Duration(milliseconds: 300);

  // --- Curves ---
  /// Natural decelerating curve (easeOutCubic) for finger releases and tab snapping
  static const Curve tabCurve = Cubic(0.22, 1.0, 0.36, 1.0);

  /// Spring curve for tactile glyph bounces
  static const Curve bounce = Curves.easeOutBack;

  /// Smooth entry curve
  static const Curve easeOut = Curves.easeOutCubic;

  /// Elastic bounce curve for like explosion
  static const Curve elasticSpring = Curves.elasticOut;

  // --- Gesture Thresholds ---
  /// Left edge drag width reserved strictly for navigation drawer (in dp)
  static const double drawerEdgeDragWidth = 28.0;

  // --- Haptic Feedback Helpers ---
  /// Subtle tactile click when snapping to a new tab via horizontal thumb swipe
  static void tabSwipeHaptic() {
    HapticFeedback.selectionClick();
  }

  /// Light impact for button presses and drawer toggle
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact when activating like or bookmark
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact when double tapping photo to like
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }
}
