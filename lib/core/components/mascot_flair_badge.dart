import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/models/mascot_flair_model.dart';

/// Micro mascot badge rendered next to username in post headers and profile (SNAPS-13)
class MascotFlairBadge extends StatelessWidget {
  final MascotFlairModel flair;
  final double size;
  final VoidCallback? onTap;
  final bool enableGradientFade;

  const MascotFlairBadge({
    super.key,
    required this.flair,
    this.size = 24.0,
    this.onTap,
    this.enableGradientFade = false,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = Image.asset(
      flair.assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );

    Widget content = SizedBox(
      width: size,
      height: size,
      child: enableGradientFade
          ? ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF000000),
                    Color(0xFF000000),
                    Color(0x99000000), // ~60% opacity at waist
                    Color(0x22000000), // ~13% opacity near legs
                    Color(0x00000000), // 0% completely transparent at bottom
                  ],
                  stops: [0.0, 0.48, 0.68, 0.88, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: imageWidget,
            )
          : imageWidget,
    );

    if (onTap != null) {
      content = GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return Tooltip(
      message: '${flair.bundle.label} (${flair.emotion.label})',
      child: content,
    );
  }
}
