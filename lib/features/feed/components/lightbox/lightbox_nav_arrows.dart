import 'package:flutter/material.dart';

/// Floating left & right chevron navigation buttons for Media Lightbox.
class LightboxNavArrows extends StatelessWidget {
  final int currentIndex;
  final int totalImages;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const LightboxNavArrows({
    super.key,
    required this.currentIndex,
    required this.totalImages,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    if (totalImages <= 1) return const SizedBox.shrink();

    return Stack(
      children: [
        if (currentIndex > 0)
          Positioned(
            left: 16.0,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildArrowButton(
                icon: Icons.chevron_left_rounded,
                onTap: onPrevious,
              ),
            ),
          ),
        if (currentIndex < totalImages - 1)
          Positioned(
            right: 16.0,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildArrowButton(
                icon: Icons.chevron_right_rounded,
                onTap: onNext,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 8.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 24.0,
            color: const Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }
}
