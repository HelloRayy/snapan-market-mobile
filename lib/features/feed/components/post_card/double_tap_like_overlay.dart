import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_animations.dart';

/// Overlay widget that displays an Instagram-style floating popping heart
/// in the center of the image when double-tapped.
class DoubleTapLikeOverlay extends StatefulWidget {
  final Widget child;
  final VoidCallback onDoubleTapLike;
  final VoidCallback? onSingleTap;

  const DoubleTapLikeOverlay({
    super.key,
    required this.child,
    required this.onDoubleTapLike,
    this.onSingleTap,
  });

  @override
  State<DoubleTapLikeOverlay> createState() => _DoubleTapLikeOverlayState();
}

class _DoubleTapLikeOverlayState extends State<DoubleTapLikeOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heartAnimController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _heartAnimController = AnimationController(
      vsync: this,
      duration: AppAnimations.doubleTapHeart,
    );

    // Pop scale: 0.0 -> 1.25 -> 1.0 (settle)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 40,
      ),
    ]).animate(_heartAnimController);

    // Opacity: stays 1.0 until 60%, then fades out to 0.0
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 40,
      ),
    ]).animate(_heartAnimController);

    _heartAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _showHeart = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _heartAnimController.dispose();
    super.dispose();
  }

  void _triggerDoubleTap() {
    AppAnimations.heavyImpact();
    setState(() {
      _showHeart = true;
    });
    _heartAnimController.forward(from: 0.0);
    widget.onDoubleTapLike();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onSingleTap,
      onDoubleTap: _triggerDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          if (_showHeart)
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _heartAnimController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 24.0,
                              spreadRadius: 2.0,
                            ),
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.heart_fill,
                          color: Color(0xFFF43F5E),
                          size: 88.0,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
