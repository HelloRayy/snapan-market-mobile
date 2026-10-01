import 'package:flutter/material.dart';
import 'package:snapan_market/core/components/snaps_logo.dart';

/// Renders the Snaps logo with a hardware-accelerated reverse diagonal (315°) eraser mask.
/// [progress] animates from 0.0 (fully visible) to 1.0 (fully erased right-to-left).
class EraserLogo extends StatelessWidget {
  final double progress;
  final double height;
  final double feather;

  const EraserLogo({
    super.key,
    required this.progress,
    this.height = 48.0,
    this.feather = 0.14,
  });

  @override
  Widget build(BuildContext context) {
    if (progress <= 0.0) {
      return SnapsLogo(height: height);
    }
    if (progress >= 1.0) {
      return SizedBox(height: height, width: height * 1.7);
    }

    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (Rect bounds) {
        final offset = progress * (1.0 + feather * 2) - feather;
        final stop1 = offset.clamp(0.0, 1.0);
        final stop2 = (offset + feather).clamp(0.0, 1.0);

        return LinearGradient(
          begin: const Alignment(1.2, 0.8), // bottom-right (last letter 's')
          end: const Alignment(-1.2, -0.8),  // top-left (first letter 's')
          colors: const [
            Colors.transparent,
            Colors.transparent,
            Colors.black,
            Colors.black,
          ],
          stops: [
            0.0,
            stop1,
            stop2,
            1.0,
          ],
        ).createShader(bounds);
      },
      child: SnapsLogo(height: height),
    );
  }
}
