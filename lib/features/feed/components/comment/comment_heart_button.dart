import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/features/feed/components/market_feed_icons.dart';

/// Minimalist Instagram-Style Heart Button for comments
/// Positioned on the right side of the comment row with bounce scale animation.
class CommentHeartButton extends StatefulWidget {
  final bool isLiked;
  final VoidCallback onToggle;
  final double size;
  final double hitBoxSize;

  const CommentHeartButton({
    super.key,
    required this.isLiked,
    required this.onToggle,
    this.size = 15.0,
    this.hitBoxSize = 32.0,
  });

  @override
  State<CommentHeartButton> createState() => _CommentHeartButtonState();
}

class _CommentHeartButtonState extends State<CommentHeartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(covariant CommentHeartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isLiked && widget.isLiked) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    if (!widget.isLiked) {
      _animController.forward(from: 0.0);
    }
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: widget.hitBoxSize,
        height: widget.hitBoxSize,
        alignment: Alignment.center,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: FeedHeartIcon(
            isLiked: widget.isLiked,
            size: widget.size,
            activeColor: const Color(0xFFF43F5E),
            inactiveColor: const Color(0xFF94A3B8),
            strokeWidth: 1.6,
          ),
        ),
      ),
    );
  }
}
