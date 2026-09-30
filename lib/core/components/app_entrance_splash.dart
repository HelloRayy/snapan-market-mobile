import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/components/snaps_logo.dart';

/// Clean, static fullscreen splash screen displaying the official sNaps vector logo.
/// Holds the literal SVG logo statically in the center without any animations,
/// then smoothly reveals the home feed.
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
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Static display: 800ms static hold, 200ms clean dissolve to home feed
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.80, 1.00, curve: Curves.easeOut),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFinish();
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
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        if (_controller.isCompleted) {
          return const SizedBox.shrink();
        }

        return IgnorePointer(
          ignoring: _controller.value > 0.80,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: const Material(
              color: Colors.white,
              child: SizedBox.expand(
                child: Center(
                  child: SnapsLogo(height: 52.0),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
