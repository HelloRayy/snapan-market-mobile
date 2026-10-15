import 'package:flutter/material.dart';
import 'package:snapan_market/core/components/skeleton/snaps_shimmer.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Sliced Conversation Tile Skeleton matching ConversationTile 1:1 (<100 lines)
class ConversationTileSkeleton extends StatelessWidget {
  const ConversationTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: AppColors.adaptiveDivider(context),
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

/// List of Conversation Skeletons on an adaptive canvas
class ConversationListSkeleton extends StatelessWidget {
  final int itemCount;

  const ConversationListSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.adaptiveCanvas(context),
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
