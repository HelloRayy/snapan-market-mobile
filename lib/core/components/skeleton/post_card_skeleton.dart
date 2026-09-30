import 'package:flutter/material.dart';
import 'package:snapan_market/core/components/skeleton/snaps_shimmer.dart';

/// Sliced Post Card Skeleton matching MarketPostCard 1:1 (<150 lines)
class PostCardSkeleton extends StatelessWidget {
  final bool hasImage;

  const PostCardSkeleton({super.key, this.hasImage = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF1F3F5),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Author Avatar Placeholder
          const SnapsSkeletonBox.circle(size: 40.0),
          const SizedBox(width: 12.0),

          // Right Content Placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Name, Badge, Time)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SnapsSkeletonBox(width: 100.0, height: 13.0, borderRadius: 4.0),
                        SizedBox(width: 6.0),
                        SnapsSkeletonBox(width: 50.0, height: 11.0, borderRadius: 4.0),
                      ],
                    ),
                    SnapsSkeletonBox(width: 32.0, height: 11.0, borderRadius: 4.0),
                  ],
                ),
                const SizedBox(height: 10.0),

                // Text Lines
                const SnapsSkeletonBox(width: double.infinity, height: 12.0, borderRadius: 4.0),
                const SizedBox(height: 6.0),
                const SnapsSkeletonBox(width: 240.0, height: 12.0, borderRadius: 4.0),
                const SizedBox(height: 6.0),
                const SnapsSkeletonBox(width: 160.0, height: 12.0, borderRadius: 4.0),

                if (hasImage) ...[
                  const SizedBox(height: 12.0),
                  // Image Media Card Placeholder (16:9 ratio matching MarketPostCard)
                  const AspectRatio(
                    aspectRatio: 16 / 9,
                    child: SnapsSkeletonBox(
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: 14.0,
                    ),
                  ),
                ],

                const SizedBox(height: 16.0),

                // Action Bar (Like, Comment, Repost, Bookmark)
                const Row(
                  children: [
                    SnapsSkeletonBox(width: 44.0, height: 16.0, borderRadius: 6.0),
                    SizedBox(width: 24.0),
                    SnapsSkeletonBox(width: 44.0, height: 16.0, borderRadius: 6.0),
                    SizedBox(width: 24.0),
                    SnapsSkeletonBox(width: 32.0, height: 16.0, borderRadius: 6.0),
                    Spacer(),
                    SnapsSkeletonBox(width: 20.0, height: 16.0, borderRadius: 4.0),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Feed Timeline Skeleton containing multiple PostCardSkeletons on a solid pure white canvas
class FeedTimelineSkeleton extends StatelessWidget {
  final int itemCount;

  const FeedTimelineSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SnapsShimmer(
        child: Column(
          children: List.generate(
            itemCount,
            (index) => PostCardSkeleton(
              // Alternate images on odd indices for realistic layout rhythm
              hasImage: index % 2 == 1,
            ),
          ),
        ),
      ),
    );
  }
}
