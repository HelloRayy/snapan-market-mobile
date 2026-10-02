import 'package:flutter/material.dart';
import 'package:snapan_market/features/splash/components/eraser_logo.dart';

/// Splash screen that coordinates:
/// 1. 750ms Static Hold (logo static in center)
/// 2. 450ms Right-to-Left Reverse Diagonal Eraser Wipe (easeInOutCubic)
/// 3. Calls [onCompleted] when logo is completely erased to trigger cross-fade to feed
class SplashScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const SplashScreen({
    super.key,
    required this.onCompleted,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _eraserAnim;

  // Timeline durations (SNAPS-1 spec + entrance motion)
  static const int _entranceMs = 200;
  static const int _holdMs = 750;
  static const int _wipeMs = 450;
  static const int _totalMs = _entranceMs + _holdMs + _wipeMs; // 1400ms

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalMs),
    );

    // 1. Entrance Fade & Scale: 0 -> 200ms
    final entranceEnd = _entranceMs / _totalMs; // 200 / 1400 ~ 0.1428
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, entranceEnd, curve: Curves.easeOutCubic),
      ),
    );
    _scaleAnim = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, entranceEnd, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Eraser wipe begins after entrance (200ms) + static hold (750ms) = 950ms
    final wipeStart = (_entranceMs + _holdMs) / _totalMs; // 950 / 1400 ~ 0.6785
    _eraserAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(wipeStart, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Opacity(
              opacity: _fadeAnim.value,
              child: Transform.scale(
                scale: _scaleAnim.value,
                child: EraserLogo(
                  progress: _eraserAnim.value,
                  height: 48.0,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
