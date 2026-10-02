import 'package:flutter/material.dart';

/// Full-width edge-to-edge interactive image item with pinch-to-zoom.
class LightboxImageViewer extends StatelessWidget {
  final String imageUrl;
  final double screenWidth;

  const LightboxImageViewer({
    super.key,
    required this.imageUrl,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InteractiveViewer(
        minScale: 1.0,
        maxScale: 4.0,
        clipBehavior: Clip.none,
        child: SizedBox(
          width: screenWidth,
          child: Image.network(
            imageUrl,
            width: screenWidth,
            fit: BoxFit.fitWidth,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2.0,
                  color: const Color(0xFF008BFF),
                ),
              );
            },
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 48.0,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
