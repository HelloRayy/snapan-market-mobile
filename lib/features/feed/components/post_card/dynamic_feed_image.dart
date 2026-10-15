import 'package:flutter/material.dart';

/// Renders a feed image with dynamic aspect ratio bounded between
/// [minAspectRatio] (default 0.8 for 4:5 vertical limit) and
/// [maxAspectRatio] (default 1.91 for 16:9 landscape limit).
///
/// Prevents cropping for 16:9, 4:3, 1:1, and other common formats.
class DynamicFeedImage extends StatefulWidget {
  final String imageUrl;
  final VoidCallback? onTap;
  final double minAspectRatio;
  final double maxAspectRatio;

  const DynamicFeedImage({
    super.key,
    required this.imageUrl,
    this.onTap,
    this.minAspectRatio = 0.8,
    this.maxAspectRatio = 1.91,
  });

  @override
  State<DynamicFeedImage> createState() => _DynamicFeedImageState();
}

class _DynamicFeedImageState extends State<DynamicFeedImage> {
  static final Map<String, double> _ratioCache = {};
  ImageStream? _imageStream;
  ImageStreamListener? _listener;
  double? _resolvedRatio;

  @override
  void initState() {
    super.initState();
    _resolveRatio();
  }

  @override
  void didUpdateWidget(covariant DynamicFeedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _resolvedRatio = _ratioCache[widget.imageUrl];
      _resolveRatio();
    }
  }

  void _resolveRatio() {
    final cached = _ratioCache[widget.imageUrl];
    if (cached != null) {
      _resolvedRatio = cached;
      return;
    }

    final provider = NetworkImage(widget.imageUrl);
    _imageStream?.removeListener(_listener!);
    _imageStream = provider.resolve(const ImageConfiguration());
    _listener = ImageStreamListener(
      (info, _) {
        if (!mounted) return;
        final w = info.image.width;
        final h = info.image.height;
        if (w > 0 && h > 0) {
          final naturalRatio = w / h;
          final clampedRatio = naturalRatio.clamp(
            widget.minAspectRatio,
            widget.maxAspectRatio,
          );
          _ratioCache[widget.imageUrl] = clampedRatio;
          setState(() {
            _resolvedRatio = clampedRatio;
          });
        }
      },
      onError: (_, __) {
        // Fallback gracefully without breaking layout
      },
    );
    _imageStream!.addListener(_listener!);
  }

  @override
  void dispose() {
    if (_listener != null && _imageStream != null) {
      _imageStream?.removeListener(_listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = _resolvedRatio ?? (16 / 9);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholderColor = isDark ? const Color(0xFF1E2021) : const Color(0xFFF1F5F9);

    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 460.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B1D1E) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: isDark ? const Color(0x1AFFFFFF) : const Color(0xFFE2E8F0),
              width: 0.6,
            ),
          ),
          child: AspectRatio(
            aspectRatio: ratio,
            child: Image.network(
              widget.imageUrl,
              cacheWidth: 800,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: placeholderColor,
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    size: 40.0,
                  ),
                ),
              ),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: placeholderColor,
                  child: Center(
                    child: SizedBox(
                      width: 24.0,
                      height: 24.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? const Color(0xFF424445) : const Color(0xFFCBD5E1),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
