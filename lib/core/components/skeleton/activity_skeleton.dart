import 'package:flutter/material.dart';
import 'package:snapan-market/core/components/skeleton/snaps_shimmer.dart';

/// Sliced Activity Item Skeleton matching ActivityItemTile 1:1 (<100 lines)
class ActivityItemSkeleton extends StatelessWidget {
  const ActivityItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF1F3F5),
            width: 0.8,
          ),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SnapsSkeletonBox.circle(size: 42.0),
          SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SnapsSkeletonBox(width: 160.0, height: 13.0, borderRadius: 4.0),
                SizedBox(height: 6.0),
                SnapsSkeletonBox(width: double.infinity, height: 11.0, borderRadius: 4.0),
                SizedBox(height: 6.0),
                SnapsSkeletonBox(width: 60.0, height: 9.0, borderRadius: 3.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// List of Activity Skeletons on a solid pure white canvas
class ActivityListSkeleton extends StatelessWidget {
  final int itemCount;

  const ActivityListSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SnapsShimmer(
        child: Column(
          children: List.generate(
            itemCount,
            (_) => const ActivityItemSkeleton(),
          ),
        ),
      ),
    );
  }
}
