import 'package:flutter/material.dart';

/// Preview section for attached images in a comment (single 16:10 or multi-image horizontal carousel)
class CommentImagesSection extends StatelessWidget {
  final List<String> images;
  final void Function(List<String> images, int index)? onImageClick;

  const CommentImagesSection({
    super.key,
    required this.images,
    this.onImageClick,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    if (images.length == 1) {
      return GestureDetector(
        onTap: () => onImageClick?.call(images, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.0),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 220.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: const Color(0x14000000), width: 1.0),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.network(
                images.first,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFFF1F5F9),
                  child: const Center(
                    child: Icon(Icons.image_outlined, color: Color(0xFF94A3B8), size: 32.0),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 140.0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(images.length, (idx) {
            final imgUrl = images[idx];
            final isLast = idx == images.length - 1;
            return Padding(
              padding: EdgeInsets.only(right: isLast ? 0.0 : 8.0),
              child: GestureDetector(
                onTap: () => onImageClick?.call(images, idx),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.0),
                  child: Container(
                    width: 180.0,
                    height: 140.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(color: const Color(0x14000000), width: 1.0),
                    ),
                    child: Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
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
