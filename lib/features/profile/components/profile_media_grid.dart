import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

class ProfileMediaItem {
  final String imageUrl;
  final MarketPostModel post;

  const ProfileMediaItem({
    required this.imageUrl,
    required this.post,
  });
}

/// 3-Column Vertical 3:4 Aspect Ratio Grid for "Media" Tab matching ProfilePage.tsx
class ProfileMediaGrid extends StatelessWidget {
  final List<ProfileMediaItem> mediaItems;
  final ValueChanged<MarketPostModel>? onMediaTap;

  const ProfileMediaGrid({
    super.key,
    required this.mediaItems,
    this.onMediaTap,
  });

  @override
  Widget build(BuildContext context) {
    if (mediaItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 64.0, horizontal: 24.0),
        alignment: Alignment.center,
        child: const Column(
          children: [
            Icon(
              Icons.grid_view_rounded,
              size: 36.0,
              color: Color(0xFFCBD5E1),
            ),
            SizedBox(height: 10.0),
            Text(
              'Belum ada media',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              'Foto dan media yang diunggah akan muncul di sini.',
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF94A3B8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: mediaItems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 3.0,
          mainAxisSpacing: 3.0,
          childAspectRatio: 1.0,
        ),

        itemBuilder: (context, index) {
          final item = mediaItems[index];
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onMediaTap?.call(item.post);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: Container(
                color: const Color(0xFFF1F5F9),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.image_not_supported_rounded,
                      size: 24.0,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
