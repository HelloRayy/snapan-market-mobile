import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// iOS-grade Parallax Page Route with Interactive Swipe-Back Gesture
/// Matching Threads & Instagram mobile motion design
class AppSlidePageRoute<T> extends PageRoute<T> with CupertinoRouteTransitionMixin<T> {
  final WidgetBuilder builder;
  @override
  final bool maintainState;
  final Duration transitionDurationOverride;

  AppSlidePageRoute({
    required this.builder,
    this.maintainState = true,
    this.transitionDurationOverride = const Duration(milliseconds: 320),
    super.settings,
  });

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  Duration get transitionDuration => transitionDurationOverride;

  @override
  String? get title => null;

  @override
  bool get fullscreenDialog => false;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Standard Cupertino Parallax & Swipe-Back transition with smooth cubic curve
    return CupertinoPageTransition(
      primaryRouteAnimation: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
      secondaryRouteAnimation: CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
      linearTransition: false,
      child: child,
    );
  }
}
