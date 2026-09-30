import 'package:flutter/material.dart';
import 'package:snapan_market/core/components/snaps_skeleton.dart';

/// Shimmer Skeleton matching ProfileInfoHeader and ProfileActionButtons 1:1
class ProfileHeaderSkeleton extends StatelessWidget {
  const ProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SnapsShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Name + Handle on Left vs Avatar on Right
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SnapsSkeletonBox(width: 150.0, height: 20.0, borderRadius: 4.0),
                      SizedBox(height: 8.0),
                      SnapsSkeletonBox(width: 190.0, height: 13.0, borderRadius: 4.0),
                    ],
                  ),
                ),
                const SizedBox(width: 14.0),
                const SnapsSkeletonBox.circle(size: 60.0),
              ],
            ),
            const SizedBox(height: 14.0),

            // Row 2: Bio description lines
            const SnapsSkeletonBox(width: double.infinity, height: 12.0, borderRadius: 4.0),
            const SizedBox(height: 6.0),
            const SnapsSkeletonBox(width: 220.0, height: 12.0, borderRadius: 4.0),
            const SizedBox(height: 12.0),

            // Row 3: Followers count
            const SnapsSkeletonBox(width: 100.0, height: 13.0, borderRadius: 4.0),
            const SizedBox(height: 14.0),

            // Row 4: Action button (Follow/Edit)
            const SnapsSkeletonBox(width: double.infinity, height: 38.0, borderRadius: 10.0),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}
