import 'package:flutter/material.dart';

/// Global Navigation Service to allow popping open screens/modals
/// and redirecting directly to login or suspended screen from anywhere
/// in the app (e.g. background Realtime suspension triggers).
class NavigationService {
  NavigationService._();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext? get currentContext => navigatorKey.currentContext;

  /// Closes all dialogs, bottomsheets, or nested push screens back to the root route
  static void popToRoot() {
    final state = navigatorKey.currentState;
    if (state != null && state.canPop()) {
      state.popUntil((route) => route.isFirst);
    }
  }
}
