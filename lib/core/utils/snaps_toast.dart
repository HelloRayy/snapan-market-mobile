import 'package:flutter/material.dart';

/// Centralized Snaps toast helper dynamically positioning toasts above bottom nav bars (<100 lines).
class SnapsToast {
  SnapsToast._();

  /// Calculate safe floating bottom margin based on bottom nav and screen safe area
  static double getBottomMargin(BuildContext context, {bool hasBottomNav = true}) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    if (hasBottomNav) {
      // HomeBottomNavBar height: 62px, nav bottom: bottomPadding > 0 ? bottomPadding + 8.0 : 18.0
      // 12px breathing room above the navbar dock
      return (bottomPadding > 0 ? bottomPadding + 8.0 : 18.0) + 62.0 + 12.0;
    }
    return bottomPadding > 0 ? bottomPadding + 12.0 : 20.0;
  }

  /// Display a floating toast safely above bottom nav bars
  static void show(
    BuildContext context,
    String message, {
    bool hasBottomNav = true,
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
    Color backgroundColor = const Color(0xFF1E293B),
    Color textColor = Colors.white,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final margin = getBottomMargin(context, hasBottomNav: hasBottomNav);

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: textColor,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, margin),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: const BorderSide(color: Color(0x14FFFFFF), width: 0.8),
        ),
      ),
    );
  }
}
