import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reusable vector brand logo widget for Snaps
class SnapsLogo extends StatelessWidget {
  final double height;
  final double? width;
  final BoxFit fit;

  const SnapsLogo({
    super.key,
    this.height = 34.0,
    this.width,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logo/snaps-logo-clean.svg',
      height: height,
      width: width,
      fit: fit,
      semanticsLabel: 'Snaps Logo',
    );
  }
}
