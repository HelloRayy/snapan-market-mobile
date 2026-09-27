import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snapan_market/core/components/snaps_logo.dart';

/// Fullscreen app entrance animation that reveals the official Snaps vector logo
/// with a spring scale pop, holds briefly, then morphs and glides up into the top AppBar header.
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

  // Stage 1: Entrance Pop (0.0 -> 0.45)
  late final Animation<double> _entranceScale;
  late final Animation<double> _entranceOpacity;

  // Subtitle fade in (0.30 -> 0.55)
  late final Animation<double> _subtitleOpacity;

  // Stage 2: Morph Glide Up to Header (0.65 -> 1.0)
  late final Animation<Offset> _glideOffset;
  late final Animation<double> _glideScale;
  late final Animation<double> _bgOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1650),
    );

    // Entrance pop
    _entranceScale = Tween<double>(begin: 0.60, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.42, curve: Curves.easeOutBack),
      ),
    );

    _entranceOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.30, curve: Curves.easeOut),
      ),
    );

    // Subtitle fade in
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.45, curve: Curves.easeIn),
      ),
    );

    // Glide up to header
    _glideOffset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -0.88),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 1.0, curve: Curves.easeInOutCubicEmphasized),
      ),
    );

    _glideScale = Tween<double>(begin: 1.0, end: 0.42).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    // Background white curtain fade out
    _bgOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.72, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFinish();
      }
    });

    // Start sequence with subtle tactile feedback
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 280), () {
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
          // Allow clicks to pass through once morphing begins
          ignoring: _controller.value > 0.65,
          child: Opacity(
            opacity: _bgOpacity.value,
            child: Container(
              color: Colors.white,
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.center,
              child: SlideTransition(
                position: _glideOffset,
                child: Transform.scale(
                  scale: _entranceScale.value * _glideScale.value,
                  child: Opacity(
                    opacity: _entranceOpacity.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Large vector logo in center
                        const SnapsLogo(
                          height: 64.0,
                        ),
                        const SizedBox(height: 14.0),
                        // Subtitle
                        Opacity(
                          opacity: _subtitleOpacity.value *
                              (1.0 - (_controller.value > 0.60
                                  ? ((_controller.value - 0.60) / 0.15).clamp(0.0, 1.0)
                                  : 0.0)),
                          child: Text(
                            'SNAPANIANS 2026',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.4,
                              color: const Color(0xFF94A3B8),
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
