import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late final Animation<double> _slideAnim;
  late final Animation<double> _eraserAnim;

  // Timeline durations (Polished smooth motion)
  static const int _entranceMs = 450;
  static const int _holdMs = 650;
  static const int _wipeMs = 600;
  static const int _totalMs = _entranceMs + _holdMs + _wipeMs; // 1700ms

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalMs),
    );

    // 1. Entrance Motion (Fade + Scale + Subtle Upward Drift): 0 -> 450ms
    final entranceEnd = _entranceMs / _totalMs; // ~0.2647
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, entranceEnd, curve: Curves.easeOutCubic),
      ),
    );
    _scaleAnim = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, entranceEnd, curve: Curves.easeOutCubic),
      ),
    );
    _slideAnim = Tween<double>(begin: 14.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, entranceEnd, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Eraser wipe begins after entrance (450ms) + static hold (650ms) = 1100ms
    final wipeStart = (_entranceMs + _holdMs) / _totalMs; // ~0.6470
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

    // Pause until Android OS splash window dismiss is fully settled on device
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 160), () {
        if (mounted) {
          _controller.forward();
        }
      });
    });
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
              child: Transform.translate(
                offset: Offset(0, _slideAnim.value),
                child: Transform.scale(
                  scale: _scaleAnim.value,
                  child: EraserLogo(
                    progress: _eraserAnim.value,
                    height: 64.0,
                    feather: 0.22,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
