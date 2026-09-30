import 'package:flutter/material.dart';
import 'package:snapan-market/core/components/skeleton/snaps_shimmer.dart';

/// Sliced Conversation Tile Skeleton matching ConversationTile 1:1 (<100 lines)
class ConversationTileSkeleton extends StatelessWidget {
  const ConversationTileSkeleton({super.key});

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
        children: [
          SnapsSkeletonBox.circle(size: 48.0),
          SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SnapsSkeletonBox(width: 120.0, height: 14.0, borderRadius: 4.0),
                    SnapsSkeletonBox(width: 36.0, height: 10.0, borderRadius: 4.0),
                  ],
                ),
                SizedBox(height: 7.0),
                SnapsSkeletonBox(width: 200.0, height: 12.0, borderRadius: 4.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// List of Conversation Skeletons on a solid pure white canvas
class ConversationListSkeleton extends StatelessWidget {
  final int itemCount;

  const ConversationListSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SnapsShimmer(
        child: Column(
          children: List.generate(
            itemCount,
            (_) => const ConversationTileSkeleton(),
          ),
        ),
      ),
    );
  }
}
