import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reusable vector brand logo widget for Snaps
class SnapsLogo extends StatelessWidget {
  final double height;
  final double? width;
  final BoxFit fit;
  final Color? color;

  const SnapsLogo({
    super.key,
    this.height = 34.0,
    this.width,
    this.fit = BoxFit.contain,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = color ?? (isDark ? Colors.white : null);

    return SvgPicture.asset(
      'assets/logo/snaps-logo-clean.svg',
      height: height,
      width: width,
      fit: fit,
      colorFilter: effectiveColor != null
          ? ColorFilter.mode(effectiveColor, BlendMode.srcIn)
          : null,
      semanticsLabel: 'Snaps Logo',
    );
  }
}
