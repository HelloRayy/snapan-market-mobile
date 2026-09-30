import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// iOS-grade Parallax Page Route with Interactive Swipe-Back Gesture.
/// Matching Threads & Instagram mobile motion design:
/// - Consistent 380ms entry duration with genuine Apple decelerating ease-out
/// - 320ms exit duration with responsive return acceleration
/// - Native interactive edge-swipe gesture support
class AppSlidePageRoute<T> extends PageRoute<T> with CupertinoRouteTransitionMixin<T> {
  final WidgetBuilder builder;
  @override
  final bool maintainState;
  final Duration _duration;
  final Duration _reverseDuration;

  AppSlidePageRoute({
    required this.builder,
    this.maintainState = true,
    Duration transitionDuration = const Duration(milliseconds: 380),
    Duration reverseTransitionDuration = const Duration(milliseconds: 320),
    super.settings,
  }) : _duration = transitionDuration,
       _reverseDuration = reverseTransitionDuration;

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  Duration get transitionDuration => _duration;

  @override
  Duration get reverseTransitionDuration => _reverseDuration;

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
    // Delegates to CupertinoRouteTransitionMixin.buildPageTransitions which correctly
    // pairs the single iOS native linearToEaseOut curve, underlying route parallax shift,
    // and interactive swipe-back gesture detector without double-curve compounding.
    return super.buildTransitions(context, animation, secondaryAnimation, child);
  }
}
