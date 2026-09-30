import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Fullscreen app entrance animation that reveals each letter of the official
/// sNaps brand logo sequentially dropping from top to bottom (s -> N -> a -> ps)
/// with a pure vertical bounce physics (Curves.bounceOut), settles briefly,
/// then smoothly fades out to reveal the home feed.
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

  // Pure vertical drop translations (Y-axis only)
  late final Animation<double> _s1Y;
  late final Animation<double> _s1Opacity;

  late final Animation<double> _nY;
  late final Animation<double> _nOpacity;

  late final Animation<double> _aY;
  late final Animation<double> _aOpacity;

  late final Animation<double> _psY;
  late final Animation<double> _psOpacity;

  // Background dissolve
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

    // Total duration: 1100ms (cadence: 180ms per letter drop)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    const double dropStart = -150.0;
    const double dropEnd = 0.0;

    // 1. Letter 's' : 0.00 -> 0.28 (0ms - 308ms)
    _s1Y = Tween<double>(begin: dropStart, end: dropEnd).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.28, curve: Curves.bounceOut),
      ),
    );
    _s1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.08, curve: Curves.easeIn),
      ),
    );

    // 2. Letter 'N' : 0.16 -> 0.44 (176ms - 484ms)
    _nY = Tween<double>(begin: dropStart, end: dropEnd).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.16, 0.44, curve: Curves.bounceOut),
      ),
    );
    _nOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.16, 0.24, curve: Curves.easeIn),
      ),
    );

    // 3. Letter 'a' : 0.32 -> 0.60 (352ms - 660ms)
    _aY = Tween<double>(begin: dropStart, end: dropEnd).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.32, 0.60, curve: Curves.bounceOut),
      ),
    );
    _aOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.32, 0.40, curve: Curves.easeIn),
      ),
    );

    // 4. Letter 'ps' : 0.48 -> 0.76 (528ms - 836ms)
    _psY = Tween<double>(begin: dropStart, end: dropEnd).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.48, 0.76, curve: Curves.bounceOut),
      ),
    );
    _psOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.48, 0.56, curve: Curves.easeIn),
      ),
    );

    // 5. Fade to Home Feed : 0.86 -> 1.00 (946ms - 1100ms)
    _bgOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.86, 1.00, curve: Curves.easeOut),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFinish();
      }
    });

    _controller.forward();
    _triggerHapticsSequence();
  }

  void _triggerHapticsSequence() {
    // Light impact on each letter landing
    Future.delayed(const Duration(milliseconds: 240), () {
      if (mounted) HapticFeedback.lightImpact();
    });
    Future.delayed(const Duration(milliseconds: 410), () {
      if (mounted) HapticFeedback.lightImpact();
    });
    Future.delayed(const Duration(milliseconds: 580), () {
      if (mounted) HapticFeedback.lightImpact();
    });
    Future.delayed(const Duration(milliseconds: 750), () {
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
          ignoring: _controller.value > 0.86,
          child: Opacity(
            opacity: _bgOpacity.value,
            child: Material(
              color: Colors.white,
              child: SizedBox.expand(
                child: Center(
                  child: SizedBox(
                    height: logoHeight,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // 1. Letter 's'
                        Transform.translate(
                          offset: Offset(0.0, _s1Y.value),
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
                        Transform.translate(
                          offset: Offset(0.0, _nY.value),
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
                        Transform.translate(
                          offset: Offset(0.0, _aY.value),
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
                        Transform.translate(
                          offset: Offset(0.0, _psY.value),
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
        );
      },
    );
  }
}
