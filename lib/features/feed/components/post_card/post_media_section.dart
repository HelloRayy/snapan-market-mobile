import 'package:flutter/material.dart';
import 'package:snapan_market/features/feed/components/post_card/adaptive_carousel_card.dart';
import 'package:snapan_market/features/feed/components/post_card/double_tap_like_overlay.dart';
import 'package:snapan_market/features/feed/components/post_card/dynamic_feed_image.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Media display for single image or multi-image horizontal carousel
/// Enhanced with Instagram-style double tap to like (SNAPS-19).
class PostMediaSection extends StatefulWidget {
  final MarketPostModel item;
  final bool isDetail;
  final void Function(MarketPostModel item, int imageIndex)? onImageClick;
  final VoidCallback? onDoubleTapLike;

  const PostMediaSection({
    super.key,
    required this.item,
    this.isDetail = false,
    this.onImageClick,
    this.onDoubleTapLike,
  });

  @override
  State<PostMediaSection> createState() => _PostMediaSectionState();
}

class _PostMediaSectionState extends State<PostMediaSection> {
  @override
  Widget build(BuildContext context) {
    if (widget.item.images.isEmpty) return const SizedBox.shrink();

    // 1. Single Image Display (Dynamic Aspect Ratio: 16:9, 1:1, 4:3 up to 4:5)
    if (widget.item.images.length == 1) {
      final childImage = DynamicFeedImage(
        imageUrl: widget.item.images.first,
        onTap: widget.onDoubleTapLike != null ? null : () => widget.onImageClick?.call(widget.item, 0),
      );

      if (widget.onDoubleTapLike != null) {
        return DoubleTapLikeOverlay(
          onSingleTap: () => widget.onImageClick?.call(widget.item, 0),
          onDoubleTapLike: widget.onDoubleTapLike!,
          child: childImage,
        );
      }

      return childImage;
    }

    // 2. Multi-Image Layout (2+ photos) - Threads Dual Strategy: 50-50 Split or Peeking Carousel (SNAPS-79)
    final screenWidth = MediaQuery.of(context).size.width;
    final carouselHeight = widget.isDetail ? 250.0 : 230.0;
    final maxCardWidth = screenWidth * 0.82; // 82% to guarantee clear peeking cue for next slide

    // Hitung lebar pasti kolom konten tanpa LayoutBuilder agar aman di dalam IntrinsicHeight MarketPostCard:
    // Feed: screenWidth - 14(kiri) - 14(kanan) - 46(avatar) - 10(jarak) = screenWidth - 84.
    // Detail: screenWidth - 16(kiri) - 16(kanan) = screenWidth - 32.
    final availableWidth = widget.isDetail ? (screenWidth - 32.0) : (screenWidth - 84.0);

    // Opsi A Gap Spacing:
    // 50/50 Split grid spacing = 6.0 dp
    // Carousel peeking item gap = 6.0 dp
    const double gridGap = 6.0;
    const double carouselGap = 6.0;

    // POLA A THREADS: Tepat 2 foto.
    // Keduanya HARUS sudah ter-resolve dan terbukti foto potret / persegi (naturalRatio <= 1.15).
    // Jika rasio belum ter-resolve (null) atau salah satu lanskap (>1.15), default ke Carousel
    // agar foto lanskap TIDAK ter-crop agresif sebelum rasionya terdeteksi.
    if (widget.item.images.length == 2 && availableWidth > 0) {
      final ratio0 = AdaptiveCarouselCard.getCachedRatio(widget.item.images[0]);
      final ratio1 = AdaptiveCarouselCard.getCachedRatio(widget.item.images[1]);
      final bool isBothPortraitOrSquare = (ratio0 != null && ratio0 <= 1.15) &&
          (ratio1 != null && ratio1 <= 1.15);

      if (isBothPortraitOrSquare) {
        final halfWidth = (availableWidth - gridGap) / 2;

        return SizedBox(
          height: carouselHeight,
          child: Row(
            children: [
              Expanded(
                child: _buildInteractiveCard(
                  context,
                  widget.item.images[0],
                  0,
                  carouselHeight,
                  halfWidth,
                ),
              ),
              const SizedBox(width: gridGap),
              Expanded(
                child: _buildInteractiveCard(
                  context,
                  widget.item.images[1],
                  1,
                  carouselHeight,
                  halfWidth,
                ),
              ),
            ],
          ),
        );
      }
    }

    // POLA B THREADS: 3+ foto, kombinasi lanskap-potret, atau saat rasio gambar baru sedang di-resolve
    return SizedBox(
      height: carouselHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(widget.item.images.length, (idx) {
            final imgUrl = widget.item.images[idx];
            final isLast = idx == widget.item.images.length - 1;

            final imageWidget = _buildInteractiveCard(
              context,
              imgUrl,
              idx,
              carouselHeight,
              null,
              maxCardWidth: maxCardWidth,
            );

            return Padding(
              padding: EdgeInsets.only(right: isLast ? 0.0 : carouselGap),
              child: imageWidget,
            );
          }),
        ),
      ),
    );
  }

  Widget _buildInteractiveCard(
    BuildContext context,
    String imgUrl,
    int idx,
    double height,
    double? customWidth, {
    double maxCardWidth = 340.0,
  }) {
    final cardContent = AdaptiveCarouselCard(
      imageUrl: imgUrl,
      height: height,
      customWidth: customWidth,
      maxCardWidth: maxCardWidth,
      onRatioResolved: (resolvedRatio) {
        // Trigger safe auto-rebuild if this is a 2-image post so layout switches seamlessly
        // from safe initial Carousel to 50/50 Split without requiring user to pull-to-refresh
        if (mounted && widget.item.images.length == 2) {
          setState(() {});
        }
      },
    );

    if (widget.onDoubleTapLike != null) {
      return DoubleTapLikeOverlay(
        onSingleTap: () => widget.onImageClick?.call(widget.item, idx),
        onDoubleTapLike: widget.onDoubleTapLike!,
        child: cardContent,
      );
    } else {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onImageClick?.call(widget.item, idx),
        child: cardContent,
      );
    }
  }
}
