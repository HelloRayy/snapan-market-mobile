import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/create_post/models/create_post_types.dart';
import 'package:snapan_market/features/feed/components/post_card/adaptive_carousel_card.dart';
class CreatePostSellingIntentBanner extends StatelessWidget {
  final VoidCallback onSwitchToProduct;

  const CreatePostSellingIntentBanner({super.key, required this.onSwitchToProduct});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: AppColors.primaryPastel,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.sparkles, size: 15.0, color: AppColors.primary),
          const SizedBox(width: 6.0),
          const Expanded(
            child: Text(
              'Ingin menjual barang?',
              style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
            ),
          ),
          TextButton(
            onPressed: onSwitchToProduct,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
            ),
            child: const Text('Beralih ke Jual', style: TextStyle(fontSize: 11.0, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class CreatePostImagesPreview extends StatelessWidget {
  final List<String> images;
  final VoidCallback onAddImage;
  final ValueChanged<int> onRemoveImage;
  final void Function(int oldIndex, int newIndex) onReorderImage;

  const CreatePostImagesPreview({
    super.key,
    required this.images,
    required this.onAddImage,
    required this.onRemoveImage,
    required this.onReorderImage,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    const previewHeight = 220.0;
    final maxCardWidth = screenWidth * 0.82;
    final canAddMore = images.length < 5;

    return SizedBox(
      height: previewHeight,
      child: Transform.translate(
        offset: const Offset(-64.0, 0),
        child: OverflowBox(
          minWidth: screenWidth,
          maxWidth: screenWidth,
          minHeight: previewHeight,
          maxHeight: previewHeight,
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: screenWidth,
            height: previewHeight,
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              padding: const EdgeInsets.only(left: 64.0, right: 16.0),
              itemCount: images.length,
              // ignore: deprecated_member_use
              onReorder: onReorderImage,
              buildDefaultDragHandles: true,
              proxyDecorator: (child, index, animation) {
                if (index < 0 || index >= images.length) return child;
                return _DragProxyCard(
                  imageUrl: images[index],
                  height: previewHeight,
                  maxCardWidth: maxCardWidth,
                  animation: animation,
                );
              },
              footer: canAddMore
                  ? GestureDetector(
                      onTap: onAddImage,
                      child: Container(
                        width: 115.0,
                        height: previewHeight,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.plus, size: 26.0, color: Color(0xFF64748B)),
                            SizedBox(height: 6.0),
                            Text(
                              'Tambah Foto',
                              style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    )
                  : null,
              itemBuilder: (context, index) {
                final img = images[index];

                return Container(
                  key: ValueKey('preview_img_$img'),
                  margin: const EdgeInsets.only(right: 10.0),
                  child: Stack(
                    children: [
                      AdaptiveCarouselCard(
                        imageUrl: img,
                        height: previewHeight,
                        maxCardWidth: maxCardWidth,
                      ),
                      Positioned(
                        top: 8.0,
                        right: 8.0,
                        child: GestureDetector(
                          onTap: () => onRemoveImage(index),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.all(5.0),
                            decoration: const BoxDecoration(color: Color(0xB3000000), shape: BoxShape.circle),
                            child: const Icon(CupertinoIcons.xmark, size: 13.0, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
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

class CreatePostGifPreview extends StatelessWidget {
  final PresetGif gif;
  final VoidCallback onRemove;

  const CreatePostGifPreview({super.key, required this.gif, required this.onRemove});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return SizedBox(
      height: 150.0,
      child: Transform.translate(
        offset: const Offset(-64.0, 0),
        child: OverflowBox(
          minWidth: screenWidth,
          maxWidth: screenWidth,
          minHeight: 150.0,
          maxHeight: 150.0,
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: screenWidth,
            child: Padding(
              padding: const EdgeInsets.only(left: 64.0, right: 16.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.network(
                      gif.url,
                      height: 150.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        height: 150.0,
                        width: double.infinity,
                        color: const Color(0xFFF1F5F9),
                        child: const Icon(CupertinoIcons.photo, size: 32.0, color: AppColors.muted),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6.0,
                    right: 6.0,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(5.0),
                        decoration: const BoxDecoration(color: Color(0xB3000000), shape: BoxShape.circle),
                        child: const Icon(CupertinoIcons.xmark, size: 12.0, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DragProxyCard extends StatefulWidget {
  final String imageUrl;
  final double height, maxCardWidth;
  final Animation<double> animation;

  const _DragProxyCard({
    required this.imageUrl,
    required this.height,
    required this.maxCardWidth,
    required this.animation,
  });

  @override
  State<_DragProxyCard> createState() => _DragProxyCardState();
}

class _DragProxyCardState extends State<_DragProxyCard> {
  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(widget.animation.value);
        final scale = lerpDouble(1.0, 1.05, t)!;
        final rotation = lerpDouble(0.0, -0.04, t)!;
        final borderAlpha = lerpDouble(0.0, 0.9, t)!;
        final shadowAlpha = lerpDouble(0.0, 0.22, t)!;

        return Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Transform.rotate(
              angle: rotation,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: shadowAlpha),
                        blurRadius: 18.0,
                        offset: const Offset(0, 8.0),
                      ),
                    ],
                  ),
                  foregroundDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: borderAlpha),
                      width: 1.5,
                    ),
                  ),
                  child: AdaptiveCarouselCard(
                    imageUrl: widget.imageUrl,
                    height: widget.height,
                    maxCardWidth: widget.maxCardWidth,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
