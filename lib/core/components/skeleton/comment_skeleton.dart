import 'package:flutter/material.dart';
import 'package:snapan_market/core/components/skeleton/snaps_shimmer.dart';

/// Sliced Comment Item Skeleton matching PostCommentItem 1:1 (<150 lines)
class CommentItemSkeleton extends StatelessWidget {
  const CommentItemSkeleton({super.key});

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
          SnapsSkeletonBox.circle(size: 34.0),
          SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SnapsSkeletonBox(width: 110.0, height: 12.0, borderRadius: 4.0),
                    SnapsSkeletonBox(width: 30.0, height: 10.0, borderRadius: 4.0),
                  ],
                ),
                SizedBox(height: 6.0),
                SnapsSkeletonBox(width: double.infinity, height: 11.0, borderRadius: 4.0),
                SizedBox(height: 4.0),
                SnapsSkeletonBox(width: 180.0, height: 11.0, borderRadius: 4.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Comment List Skeleton on a solid pure white canvas
class CommentListSkeleton extends StatelessWidget {
  final int itemCount;

  const CommentListSkeleton({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SnapsShimmer(
        child: Column(
          children: List.generate(
            itemCount,
            (_) => const CommentItemSkeleton(),
          ),
        ),
      ),
    );
  }
}

/// Sliced Search Result Skeleton on a solid pure white canvas
class SearchResultSkeleton extends StatelessWidget {
  const SearchResultSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SnapsShimmer(
        child: Column(
          children: List.generate(
            5,
            (_) => Container(
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
                  SnapsSkeletonBox.circle(size: 46.0),
                  SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SnapsSkeletonBox(width: 130.0, height: 14.0, borderRadius: 4.0),
                        SizedBox(height: 6.0),
                        SnapsSkeletonBox(width: 80.0, height: 11.0, borderRadius: 4.0),
                      ],
                    ),
                  ),
                  SnapsSkeletonBox(width: 68.0, height: 30.0, borderRadius: 15.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
