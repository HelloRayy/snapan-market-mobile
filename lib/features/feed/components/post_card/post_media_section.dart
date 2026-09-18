import 'package:flutter/material.dart';
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

    // 1. Single Image Display (18px rounded, 4:5 ratio)
    if (item.images.length == 1) {
      return GestureDetector(
        onTap: () => onImageClick?.call(item, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.0),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 380.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(18.0),
              border: Border.all(color: const Color(0x14000000), width: 1.0),
            ),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: Image.network(
                item.images.first,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFFF1F5F9),
                  child: const Center(
                    child: Icon(Icons.image_outlined, color: Color(0xFF94A3B8), size: 40.0),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 2. Multi-Image Carousel (2+ photos) - Persistent SingleChildScrollView
    return SizedBox(
      height: isDetail ? 260.0 : 240.0,
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
                    width: MediaQuery.of(context).size.width * (isDetail ? 0.78 : 0.72),
                    height: isDetail ? 260.0 : 240.0,
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
