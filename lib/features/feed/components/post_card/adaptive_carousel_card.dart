import 'dart:io';
import 'package:flutter/material.dart';

/// Renders a carousel card with dynamic width based on its natural aspect ratio
/// and a fixed height, preventing unwanted cropping and achieving WYSIWYG
/// consistency between create-post preview and the home feed (SNAPS-79).
class AdaptiveCarouselCard extends StatefulWidget {
  final String imageUrl;
  final double height;
  final double maxCardWidth;
  final double minCardWidth;
  final double? customWidth;
  final Widget? child;
  final VoidCallback? onTap;
  final ValueChanged<double>? onRatioResolved;

  static final Map<String, double> ratioCache = {};

  static double? getCachedRatio(String url) => ratioCache[url];

  const AdaptiveCarouselCard({
    super.key,
    required this.imageUrl,
    this.height = 230.0,
    this.maxCardWidth = 340.0,
    this.minCardWidth = 120.0,
    this.customWidth,
    this.child,
    this.onTap,
    this.onRatioResolved,
  });

  @override
  State<AdaptiveCarouselCard> createState() => _AdaptiveCarouselCardState();
}

class _AdaptiveCarouselCardState extends State<AdaptiveCarouselCard> {
  ImageStream? _imageStream;
  ImageStreamListener? _listener;
  double? _resolvedRatio;

  @override
  void initState() {
    super.initState();
    _resolveRatio();
  }

  @override
  void didUpdateWidget(covariant AdaptiveCarouselCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _resolvedRatio = AdaptiveCarouselCard.ratioCache[widget.imageUrl];
      _resolveRatio();
    }
  }

  void _resolveRatio() {
    final cached = AdaptiveCarouselCard.ratioCache[widget.imageUrl];
    if (cached != null) {
      _resolvedRatio = cached;
      return;
    }

    final isNetwork = widget.imageUrl.startsWith('http://') || widget.imageUrl.startsWith('https://');
    final ImageProvider provider = isNetwork
        ? NetworkImage(widget.imageUrl)
        : FileImage(File(widget.imageUrl)) as ImageProvider;

    if (_imageStream != null && _listener != null) {
      _imageStream!.removeListener(_listener!);
    }
    _imageStream = provider.resolve(const ImageConfiguration());
    _listener = ImageStreamListener(
      (info, _) {
        if (!mounted) return;
        final w = info.image.width;
        final h = info.image.height;
        if (w > 0 && h > 0) {
          final naturalRatio = w / h;
          AdaptiveCarouselCard.ratioCache[widget.imageUrl] = naturalRatio;
          setState(() {
            _resolvedRatio = naturalRatio;
          });
          widget.onRatioResolved?.call(naturalRatio);
        }
      },
      onError: (_, _) {
        // Fallback silently without throwing unhandled exceptions
      },
    );
    _imageStream!.addListener(_listener!);
  }

  @override
  void dispose() {
    if (_imageStream != null && _listener != null) {
      _imageStream!.removeListener(_listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Default fallback to 4:3 if aspect ratio is not yet resolved
    final ratio = _resolvedRatio ?? (4 / 3);
    final calculatedWidth = widget.customWidth ??
        (widget.height * ratio).clamp(
          widget.minCardWidth,
          widget.maxCardWidth,
        );

    final isNetwork = widget.imageUrl.startsWith('http://') || widget.imageUrl.startsWith('https://');

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        width: calculatedWidth,
        height: widget.height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B1D1E) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isDark ? const Color(0x1AFFFFFF) : const Color(0xFFE2E8F0),
            width: 0.8,
          ),
        ),
        child: widget.child ??
            (isNetwork
                ? Image.network(
                    widget.imageUrl,
                    cacheWidth: 800,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _errorPlaceholder(calculatedWidth, isDark),
                  )
                : Image.file(
                    File(widget.imageUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _errorPlaceholder(calculatedWidth, isDark),
                  )),
      ),
    );

    if (widget.onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: content,
      );
    }

    return content;
  }

  Widget _errorPlaceholder(double width, bool isDark) {
    return Container(
      width: width,
      height: widget.height,
      color: isDark ? const Color(0xFF1E2021) : const Color(0xFFF1F5F9),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          size: 36.0,
        ),
      ),
    );
  }
}
