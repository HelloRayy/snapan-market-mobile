import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/components/snaps_logo.dart';

/// Pure white fullscreen app entrance splash that presents only the official
/// sNaps brand text vector logo, springing smoothly in center then morph-gliding
/// up directly into the top AppBar header.
class AppEntranceSplash extends StatefulWidget {
  final VoidCallback onFinish;

  const AppEntranceSplash({
    super.key,
    required this.onFinish,
  });

  @override
  State<AppEntranceSplash> createState() => _AppEntranceSplashState();
}

class _AppEntranceSplashState extends State<AppEntranceSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Stage 1: Spring pop in center (0.0 -> 0.40)
  late final Animation<double> _entranceScale;
  late final Animation<double> _entranceOpacity;

  // Stage 2: Morph glide to top header (0.60 -> 1.0)
  late final Animation<Offset> _glideOffset;
  late final Animation<double> _glideScale;
  late final Animation<double> _bgOpacity;

  @override
  void initState() {
    super.initState();

    // Ensure status bar & nav bar are clean edge-to-edge white
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1550),
    );

    // 1. Entrance Spring Scale
    _entranceScale = Tween<double>(begin: 0.70, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.42, curve: Curves.easeOutBack),
      ),
    );

    // 2. Entrance Fade In
    _entranceOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.28, curve: Curves.easeOut),
      ),
    );

    // 3. Morph Glide Up to AppBar Header Position
    _glideOffset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -0.86),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.60, 1.0, curve: Curves.easeInOutCubicEmphasized),
      ),
    );

    // Scale from 72.0px down to ~34.0px to match AppBar logo size
    _glideScale = Tween<double>(begin: 1.0, end: 0.472).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.60, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    // 4. Pure White Curtain Fade Out
    _bgOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.70, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFinish();
      }
    });

    _controller.forward();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        HapticFeedback.lightImpact();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.isCompleted) {
          return const SizedBox.shrink();
        }

        return IgnorePointer(
          ignoring: _controller.value > 0.60,
          child: Opacity(
            opacity: _bgOpacity.value,
            child: Material(
              color: Colors.white,
              child: SizedBox.expand(
                child: Center(
                  child: SlideTransition(
                    position: _glideOffset,
                    child: Transform.scale(
                      scale: _entranceScale.value * _glideScale.value,
                      child: Opacity(
                        opacity: _entranceOpacity.value,
                        // Pure vector logo text without any container box, frame, or subtitle
                        child: const SnapsLogo(
                          height: 72.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
