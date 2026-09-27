import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Fullscreen app entrance animation that reveals each letter of the official
/// sNaps brand logo sequentially from left to right (s -> N -> a -> ps) with a spring pop,
/// holds briefly as a complete word, then smoothly glides up into the top AppBar header.
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

  // Staggered letter animations (s -> N -> a -> ps)
  late final Animation<double> _s1Scale;
  late final Animation<double> _s1Opacity;

  late final Animation<double> _nScale;
  late final Animation<double> _nOpacity;

  late final Animation<double> _aScale;
  late final Animation<double> _aOpacity;

  late final Animation<double> _psScale;
  late final Animation<double> _psOpacity;

  // Stage 2: Glide to top header
  late final Animation<Offset> _glideOffset;
  late final Animation<double> _glideScale;
  late final Animation<double> _bgOpacity;

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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1850),
    );

    // Letter 1: 's' (0.00 -> 0.28)
    _s1Scale = Tween<double>(begin: 0.50, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.26, curve: Curves.easeOutBack),
      ),
    );
    _s1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.16, curve: Curves.easeOut),
      ),
    );

    // Letter 2: 'N' (0.12 -> 0.38)
    _nScale = Tween<double>(begin: 0.50, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.12, 0.38, curve: Curves.easeOutBack),
      ),
    );
    _nOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.12, 0.26, curve: Curves.easeOut),
      ),
    );

    // Letter 3: 'a' (0.24 -> 0.50)
    _aScale = Tween<double>(begin: 0.50, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.24, 0.50, curve: Curves.easeOutBack),
      ),
    );
    _aOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.24, 0.38, curve: Curves.easeOut),
      ),
    );

    // Letter 4: 'ps' (0.36 -> 0.62)
    _psScale = Tween<double>(begin: 0.50, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.36, 0.62, curve: Curves.easeOutBack),
      ),
    );
    _psOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.36, 0.48, curve: Curves.easeOut),
      ),
    );

    // Glide to header (0.72 -> 1.00)
    _glideOffset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -0.86),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.72, 1.00, curve: Curves.easeInOutCubicEmphasized),
      ),
    );

    _glideScale = Tween<double>(begin: 1.0, end: 0.472).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.72, 1.00, curve: Curves.easeInOutCubic),
      ),
    );

    _bgOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
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

    // Haptic feedback sequence matching letter appearances
    _triggerHapticsSequence();
  }

  void _triggerHapticsSequence() {
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) HapticFeedback.lightImpact();
    });
    Future.delayed(const Duration(milliseconds: 440), () {
      if (mounted) HapticFeedback.lightImpact();
    });
    Future.delayed(const Duration(milliseconds: 660), () {
      if (mounted) HapticFeedback.mediumImpact();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double logoHeight = 72.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.isCompleted) {
          return const SizedBox.shrink();
        }

        return IgnorePointer(
          ignoring: _controller.value > 0.72,
          child: Opacity(
            opacity: _bgOpacity.value,
            child: Material(
              color: Colors.white,
              child: SizedBox.expand(
                child: Center(
                  child: SlideTransition(
                    position: _glideOffset,
                    child: Transform.scale(
                      scale: _glideScale.value,
                      child: SizedBox(
                        height: logoHeight,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 1. Letter 's'
                            Transform.scale(
                              scale: _s1Scale.value,
                              child: Opacity(
                                opacity: _s1Opacity.value,
                                child: SvgPicture.asset(
                                  'assets/logo/letter_s1.svg',
                                  height: logoHeight,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            // 2. Letter 'N'
                            Transform.scale(
                              scale: _nScale.value,
                              child: Opacity(
                                opacity: _nOpacity.value,
                                child: SvgPicture.asset(
                                  'assets/logo/letter_n.svg',
                                  height: logoHeight,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            // 3. Letter 'a'
                            Transform.scale(
                              scale: _aScale.value,
                              child: Opacity(
                                opacity: _aOpacity.value,
                                child: SvgPicture.asset(
                                  'assets/logo/letter_a.svg',
                                  height: logoHeight,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            // 4. Letter 'ps'
                            Transform.scale(
                              scale: _psScale.value,
                              child: Opacity(
                                opacity: _psOpacity.value,
                                child: SvgPicture.asset(
                                  'assets/logo/letter_ps.svg',
                                  height: logoHeight,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
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
