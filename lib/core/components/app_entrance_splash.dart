import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Fullscreen app entrance animation where the official sNaps brand logo
/// rests cleanly at the center, then is smoothly erased from right to left
/// by an animated glowing pencil-eraser stroke line before transitioning
/// to the home feed.
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

  // Eraser sweep: 0.0 (right, fully visible) -> 1.0 (left, fully erased)
  late final Animation<double> _wipeProgress;

  // Eraser line opacity and entrance/exit
  late final Animation<double> _strokeOpacity;

  // Final background dissolve to home feed
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

    // Total Duration: 1750ms
    // - 0ms - 550ms   : Peaceful static hold (official brand display)
    // - 550ms - 1450ms : Soft pencil-eraser sweep from right to left
    // - 1450ms - 1750ms: Line fade & background dissolve into feed
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1750),
    );

    _wipeProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.32, 0.84, curve: Curves.easeInOutCubic),
      ),
    );

    _strokeOpacity = TweenSequence<double>([
      // Fade in stroke as erasing begins
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 15.0,
      ),
      // Stay visible during the sweep
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 65.0,
      ),
      // Fade out as it reaches the left boundary
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 20.0,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.88),
      ),
    );

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
    // Subtle tactile tick when eraser starts sweep
    Future.delayed(const Duration(milliseconds: 560), () {
      if (mounted) HapticFeedback.selectionClick();
    });
    // Soft completion impact when logo is erased and feed opens
    Future.delayed(const Duration(milliseconds: 1480), () {
      if (mounted) HapticFeedback.lightImpact();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double logoHeight = 64.0;
    // viewBox is 760 x 445 -> aspect ratio ~ 1.708
    const double logoWidth = logoHeight * (760.0 / 445.0);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.isCompleted) {
          return const SizedBox.shrink();
        }

        final double progress = _wipeProgress.value;
        // Position of the cut edge from left (logoWidth -> 0.0)
        final double cutX = logoWidth * (1.0 - progress);
        final double strokeAlpha = _strokeOpacity.value;

        return IgnorePointer(
          ignoring: _controller.value > 0.86,
          child: Opacity(
            opacity: _bgOpacity.value,
            child: Material(
              color: Colors.white,
              child: SizedBox.expand(
                child: Center(
                  child: SizedBox(
                    width: logoWidth,
                    height: logoHeight,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 1. Masked sNaps Logo (Feathered Erase from Right to Left)
                        ShaderMask(
                          shaderCallback: (Rect bounds) {
                            // Soft feather band width
                            const double feather = 8.0;
                            final double localCut = bounds.width * (1.0 - progress);

                            final double stopVisible =
                                ((localCut - feather) / bounds.width).clamp(0.0, 1.0);
                            final double stopTransparent =
                                (localCut / bounds.width).clamp(0.0, 1.0);

                            return ui.Gradient.linear(
                              Offset.zero,
                              Offset(bounds.width, 0.0),
                              const [
                                Color(0xFFFFFFFF),
                                Color(0xFFFFFFFF),
                                Color(0x00FFFFFF),
                                Color(0x00FFFFFF),
                              ],
                              [
                                0.0,
                                stopVisible,
                                stopTransparent,
                                1.0,
                              ],
                            );
                          },
                          blendMode: BlendMode.dstIn,
                          child: SvgPicture.asset(
                            'assets/logo/snaps-logo-clean.svg',
                            width: logoWidth,
                            height: logoHeight,
                            fit: BoxFit.contain,
                          ),
                        ),

                        // 2. Animated Pencil Eraser Stroke Line (Trailing the Cut Edge)
                        if (strokeAlpha > 0.0)
                          Positioned(
                            left: cutX - 2.5,
                            top: -8.0,
                            bottom: -8.0,
                            child: Opacity(
                              opacity: strokeAlpha,
                              child: Transform.rotate(
                                angle: -0.06, // subtle 3.5 deg organic pencil tilt
                                child: Container(
                                  width: 4.5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3.0),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppColors.primary.withValues(alpha: 0.0),
                                        AppColors.primary.withValues(alpha: 0.85),
                                        const Color(0xFF0283F3),
                                        AppColors.primary.withValues(alpha: 0.85),
                                        AppColors.primary.withValues(alpha: 0.0),
                                      ],
                                      stops: const [0.0, 0.25, 0.50, 0.75, 1.0],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.40),
                                        blurRadius: 10.0,
                                        spreadRadius: 1.5,
                                      ),
                                    ],
                                  ),
                                ),
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
