import 'package:flutter/material.dart';
import 'package:snapan_market/features/feed/components/post_card/dynamic_feed_image.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Media display for single image or multi-image horizontal carousel
class PostMediaSection extends StatelessWidget {
  final MarketPostModel item;
  final bool isDetail;
  final void Function(MarketPostModel item, int imageIndex)? onImageClick;

  const PostMediaSection({
    super.key,
    required this.item,
    this.isDetail = false,
    this.onImageClick,
  });

  @override
  Widget build(BuildContext context) {
    if (item.images.isEmpty) return const SizedBox.shrink();

    // 1. Single Image Display (Dynamic Aspect Ratio: 16:9, 1:1, 4:3 up to 4:5)
    if (item.images.length == 1) {
      return DynamicFeedImage(
        imageUrl: item.images.first,
        onTap: () => onImageClick?.call(item, 0),
      );
    }

    // 2. Multi-Image Carousel (2+ photos) - 16:9 Proportional Horizontal Cards
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * (isDetail ? 0.82 : 0.78);
    final cardHeight = cardWidth * (9 / 16);

    return SizedBox(
      height: cardHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(item.images.length, (idx) {
            final imgUrl = item.images[idx];
            final isLast = idx == item.images.length - 1;
            return Padding(
              padding: EdgeInsets.only(right: isLast ? 0.0 : 10.0),
              child: GestureDetector(
                onTap: () => onImageClick?.call(item, idx),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.0),
                  child: Container(
                    width: cardWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(18.0),
                      border: Border.all(color: const Color(0x14000000), width: 1.0),
                    ),
                    child: Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Center(
                          child: Icon(Icons.image_outlined, color: Color(0xFF94A3B8), size: 36.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
