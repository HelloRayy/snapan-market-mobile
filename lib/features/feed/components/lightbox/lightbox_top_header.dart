import 'dart:ui';
import 'package:flutter/material.dart';

/// Top header bar for Media Lightbox:
/// Circular close button (top-left) + image counter badge (top-right).
class LightboxTopHeader extends StatelessWidget {
  final double topPadding;
  final int currentIndex;
  final int totalImages;
  final VoidCallback onClose;

  const LightboxTopHeader({
    super.key,
    required this.topPadding,
    required this.currentIndex,
    required this.totalImages,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topPadding + 12.0,
      left: 16.0,
      right: 16.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Close button
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClose,
              child: Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 6.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 20.0,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),

          // Counter Badge [ 1 / N ]
          if (totalImages > 1)
            Container(
              height: 32.0,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 4.0,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                '${currentIndex + 1} / $totalImages',
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                  fontFeatures: [FontFeature.tabularFigures()],
                  letterSpacing: -0.2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
