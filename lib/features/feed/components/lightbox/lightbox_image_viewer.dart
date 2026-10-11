import 'package:flutter/material.dart';

/// Full-width edge-to-edge interactive image item with pinch-to-zoom
/// and zoom-state awareness to disambiguate swipe-to-dismiss gestures.
class LightboxImageViewer extends StatefulWidget {
  final String imageUrl;
  final double screenWidth;
  final ValueChanged<bool>? onZoomChanged;

  const LightboxImageViewer({
    super.key,
    required this.imageUrl,
    required this.screenWidth,
    this.onZoomChanged,
  });

  @override
  State<LightboxImageViewer> createState() => _LightboxImageViewerState();
}

class _LightboxImageViewerState extends State<LightboxImageViewer> {
  late final TransformationController _controller;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
    _controller.addListener(_handleTransform);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTransform);
    _controller.dispose();
    super.dispose();
  }

  void _handleTransform() {
    final scale = _controller.value.getMaxScaleOnAxis();
    final zoomed = scale > 1.05;
    if (zoomed != _isZoomed) {
      setState(() => _isZoomed = zoomed);
      widget.onZoomChanged?.call(zoomed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InteractiveViewer(
        transformationController: _controller,
        minScale: 1.0,
        maxScale: 4.0,
        panEnabled: _isZoomed,
        clipBehavior: Clip.none,
        child: SizedBox(
          width: widget.screenWidth,
          child: Image.network(
            widget.imageUrl,
            width: widget.screenWidth,
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
            errorBuilder: (_, _, _) => const Center(
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
