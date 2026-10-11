import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_animations.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/utils/formatters.dart';
import 'package:snapan_market/features/feed/components/post_card/market_feed_icons.dart';

/// Interactive Love Button with:
/// 1. Dramatic Elastic Heart Pop (1.0 -> 0.72 -> 1.48 -> 0.92 -> 1.0)
/// 2. Vibrant Twitter-style Expanding Ring & Particle Burst Canvas
/// 3. Prominent Vertical Rolling Digit Wheel (Height bounded, clear bottom-to-top travel)
/// 4. Tactile medium/light haptic feedback
class InteractiveLikeButton extends StatefulWidget {
  final bool isLiked;
  final int likesCount;
  final VoidCallback onToggle;
  final double iconSize;

  const InteractiveLikeButton({
    super.key,
    required this.isLiked,
    required this.likesCount,
    required this.onToggle,
    this.iconSize = 19.0,
  });

  @override
  State<InteractiveLikeButton> createState() => _InteractiveLikeButtonState();
}

class _InteractiveLikeButtonState extends State<InteractiveLikeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _heartScaleAnim;
  late final Animation<double> _burstProgressAnim;

  @override
  void initState() {
    super.initState();
    // 360ms for dramatic, prominent and satisfying rebound
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );

    // High-visibility elastic squash & stretch bounce
    _heartScaleAnim = TweenSequence<double>([
      // 1. Clear anticipation squeeze
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.70)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 20,
      ),
      // 2. Big energetic spring pop (overshoot up to 1.48x)
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.70, end: 1.48)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      // 3. Physical under-bounce
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.48, end: 0.92)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 16,
      ),
      // 4. Return to natural resting scale
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.92, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 14,
      ),
    ]).animate(_animController);

    // Burst ring & particle progression
    _burstProgressAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(covariant InteractiveLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If state changed to liked from outside, trigger animation if not already running
    if (!oldWidget.isLiked && widget.isLiked && !_animController.isAnimating) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isLiked) {
      AppAnimations.mediumImpact();
      _animController.forward(from: 0.0);
    } else {
      AppAnimations.lightImpact();
      _animController.reset();
    }
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFFF43F5E);
    const inactiveColor = AppColors.ashGray;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 36.0,
          color: Colors.transparent,
          padding: EdgeInsets.only(
            left: 0.0,
            right: widget.likesCount > 0 ? 8.0 : 4.0,
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon with Burst Canvas
              SizedBox(
                width: widget.iconSize + 12.0,
                height: widget.iconSize + 12.0,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Burst Particles Canvas
                    AnimatedBuilder(
                      animation: _burstProgressAnim,
                      builder: (context, _) {
                        if (_animController.isAnimating && widget.isLiked) {
                          return CustomPaint(
                            size: Size(widget.iconSize + 12.0, widget.iconSize + 12.0),
                            painter: _LikeBurstPainter(
                              progress: _burstProgressAnim.value,
                              color: activeColor,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // Heart Glyph with Spring Scale
                    ScaleTransition(
                      scale: _heartScaleAnim,
                      child: FeedHeartIcon(
                        isLiked: widget.isLiked,
                        size: widget.iconSize,
                        activeColor: activeColor,
                        inactiveColor: inactiveColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Prominent Vertical Rolling Digit Wheel (Slot Machine Style)
              if (widget.likesCount > 0) ...[
                const SizedBox(width: 3.5),
                Container(
                  height: 20.0,
                  alignment: Alignment.centerLeft,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 340),
                    reverseDuration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutBack, // Playful bounce up
                    switchOutCurve: Curves.easeInQuad,
                    layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                      return Stack(
                        alignment: Alignment.centerLeft,
                        children: <Widget>[
                          ...previousChildren,
                          ?currentChild,
                        ],
                      );
                    },
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      final isIncoming = child.key == ValueKey<int>(widget.likesCount);

                      // Big, visible vertical travel distance:
                      // LIKED: Old text slides up and out (-1.4), New text slides up from bottom (+1.4 -> 0.0)
                      // UNLIKED: Old text slides down (+1.4), New text slides down from top (-1.4 -> 0.0)
                      final Offset startOffset = widget.isLiked
                          ? (isIncoming ? const Offset(0.0, 1.4) : const Offset(0.0, -1.4))
                          : (isIncoming ? const Offset(0.0, -1.4) : const Offset(0.0, 1.4));

                      final slideAnimation = Tween<Offset>(
                        begin: startOffset,
                        end: Offset.zero,
                      ).animate(animation);

                      return FadeTransition(
                        opacity: CurvedAnimation(
                          parent: animation,
                          curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
                        ),
                        child: SlideTransition(
                          position: slideAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      formatCompactNumber(widget.likesCount),
                      key: ValueKey<int>(widget.likesCount),
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: widget.isLiked ? FontWeight.w600 : FontWeight.w400,
                        color: widget.isLiked ? activeColor : AppColors.graphite,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// CustomPainter for expanding ring and sparkles when liking
class _LikeBurstPainter extends CustomPainter {
  final double progress;
  final Color color;

  _LikeBurstPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 1.05;

    // 1. Expanding Ring (expands then fades out quickly)
    if (progress < 0.65) {
      final ringProgress = progress / 0.65;
      final ringRadius = maxRadius * 0.65 * ringProgress;
      final ringOpacity = (1.0 - ringProgress).clamp(0.0, 1.0);
      final ringPaint = Paint()
        ..color = color.withValues(alpha: ringOpacity * 0.50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (2.2 * (1.0 - ringProgress)).clamp(0.5, 2.2);

      canvas.drawCircle(center, ringRadius, ringPaint);
    }

    // 2. Sparkles/Dots Burst (6 radial particles shooting outward)
    if (progress > 0.12) {
      final dotProgress = (progress - 0.12) / 0.88;
      final dotDistance = maxRadius * (0.42 + (0.58 * dotProgress));
      final dotOpacity = (1.0 - dotProgress).clamp(0.0, 1.0);
      final dotRadius = (2.0 * (1.0 - dotProgress)).clamp(0.5, 2.0);

      final dotPaint = Paint()
        ..color = color.withValues(alpha: dotOpacity * 0.90)
        ..style = PaintingStyle.fill;

      const particleCount = 6;
      for (int i = 0; i < particleCount; i++) {
        final angle = (i * (2 * math.pi / particleCount)) - (math.pi / 2);
        final dotX = center.dx + (dotDistance * math.cos(angle));
        final dotY = center.dy + (dotDistance * math.sin(angle));
        canvas.drawCircle(Offset(dotX, dotY), dotRadius, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LikeBurstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
