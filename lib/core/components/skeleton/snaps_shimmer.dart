import 'package:flutter/material.dart';

/// Snaps Shimmer Gradient Controller & Provider
/// Creates an organic, unified sweeping shimmer gradient across child skeleton elements.
class SnapsShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color? baseColor;
  final Color? highlightColor;

  const SnapsShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1400),
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<SnapsShimmer> createState() => _SnapsShimmerState();
}

class _SnapsShimmerState extends State<SnapsShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Threads / X standard: Base is elevated charcoal #242626, highlight is crisp ambient sweep #383A3A
    final effectiveBase = widget.baseColor ?? (isDark ? const Color(0xFF242626) : const Color(0xFFF1F3F5));
    final effectiveHighlight = widget.highlightColor ?? (isDark ? const Color(0xFF383A3A) : const Color(0xFFFFFFFF));

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final double progress = _controller.value;
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                effectiveBase,
                effectiveHighlight,
                effectiveBase,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(slidePercent: progress),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final double translation = bounds.width * 2 * (slidePercent - 0.5);
    return Matrix4.translationValues(translation, 0.0, 0.0);
  }
}

/// Sliced Skeleton Primitive Box (<50 lines)
class SnapsSkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  const SnapsSkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.margin,
    this.color,
  });

  const SnapsSkeletonBox.circle({
    super.key,
    required double size,
    this.margin,
    this.color,
  })  : width = size,
        height = size,
        borderRadius = size / 2.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = color ?? (isDark ? const Color(0xFF242626) : const Color(0xFFF1F3F5));

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
