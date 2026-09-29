import 'package:flutter/material.dart';

/// Snaps Shimmer Gradient Controller & Provider
/// Creates an organic, unified left-to-right sweeping shimmer gradient across all child skeletons
class SnapsShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  const SnapsShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1400),
    this.baseColor = const Color(0xFFF1F5F9), // Slate 100
    this.highlightColor = const Color(0xFFE2E8F0), // Slate 200
  });

  @override
  State<SnapsShimmer> createState() => _SnapsShimmerState();
}

class _SnapsShimmerState extends State<SnapsShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final double progress = _controller.value;
            // Sweep gradient diagonally across the layout
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(slidePercent: progress),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    // Translate gradient from -1.0 to 2.0 width
    final double translationX = bounds.width * (slidePercent * 3.0 - 1.0);
    return Matrix4.translationValues(translationX, 0.0, 0.0);
  }
}

/// Atomic Base Skeleton Box
class SnapsSkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const SnapsSkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.margin,
  });

  const SnapsSkeletonBox.circle({
    super.key,
    required double size,
    this.margin,
  })  : width = size,
        height = size,
        borderRadius = size / 2.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Base slate tone
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Sliced Post Card Skeleton matching MarketPostCard 1:1
class PostCardSkeleton extends StatelessWidget {
  final bool hasImage;

  const PostCardSkeleton({super.key, this.hasImage = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF1F5F9),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Avatar Placeholder
          const SnapsSkeletonBox.circle(size: 40.0),
          const SizedBox(width: 12.0),

          // Right Content Placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Name, Badge, Time)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
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
                  // Image Media Card Placeholder
                  const SnapsSkeletonBox(
                    width: double.infinity,
                    height: 180.0,
                    borderRadius: 14.0,
                  ),
                ],

                const SizedBox(height: 16.0),

                // Action Bar (Like, Comment, Repost, Bookmark)
                Row(
                  children: const [
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

/// Feed Timeline Skeleton containing multiple PostCardSkeletons wrapped in SnapsShimmer
class FeedTimelineSkeleton extends StatelessWidget {
  final int itemCount;

  const FeedTimelineSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return SnapsShimmer(
      child: Column(
        children: List.generate(
          itemCount,
          (index) => PostCardSkeleton(
            // Alternate images on even items for realistic layout rhythm
            hasImage: index % 2 == 1,
          ),
        ),
      ),
    );
  }
}

/// Sliced Conversation Tile Skeleton matching ConversationTile 1:1
class ConversationTileSkeleton extends StatelessWidget {
  const ConversationTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF1F5F9),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          const SnapsSkeletonBox.circle(size: 48.0),
          const SizedBox(width: 12.0),

          // Message details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
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

/// List of Conversation Skeletons wrapped in SnapsShimmer
class ConversationListSkeleton extends StatelessWidget {
  final int itemCount;

  const ConversationListSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return SnapsShimmer(
      child: Column(
        children: List.generate(
          itemCount,
          (_) => const ConversationTileSkeleton(),
        ),
      ),
    );
  }
}

/// Sliced Activity Item Skeleton matching ActivityItemTile 1:1
class ActivityItemSkeleton extends StatelessWidget {
  const ActivityItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF1F5F9),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon / Avatar
          const SnapsSkeletonBox.circle(size: 42.0),
          const SizedBox(width: 12.0),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
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

/// List of Activity Skeletons wrapped in SnapsShimmer
class ActivityListSkeleton extends StatelessWidget {
  final int itemCount;

  const ActivityListSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return SnapsShimmer(
      child: Column(
        children: List.generate(
          itemCount,
          (_) => const ActivityItemSkeleton(),
        ),
      ),
    );
  }
}

/// Sliced Search Result Skeleton
class SearchResultSkeleton extends StatelessWidget {
  const SearchResultSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SnapsShimmer(
      child: Column(
        children: List.generate(
          5,
          (_) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFF1F5F9),
                  width: 0.8,
                ),
              ),
            ),
            child: Row(
              children: [
                const SnapsSkeletonBox.circle(size: 46.0),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SnapsSkeletonBox(width: 130.0, height: 14.0, borderRadius: 4.0),
                      SizedBox(height: 6.0),
                      SnapsSkeletonBox(width: 80.0, height: 11.0, borderRadius: 4.0),
                    ],
                  ),
                ),
                const SnapsSkeletonBox(width: 68.0, height: 30.0, borderRadius: 15.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sliced Comment Item Skeleton matching PostCommentItem 1:1
class CommentItemSkeleton extends StatelessWidget {
  const CommentItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF1F5F9),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SnapsSkeletonBox.circle(size: 34.0),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
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

/// Comment List Skeleton wrapped in SnapsShimmer
class CommentListSkeleton extends StatelessWidget {
  final int itemCount;

  const CommentListSkeleton({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return SnapsShimmer(
      child: Column(
        children: List.generate(
          itemCount,
          (_) => const CommentItemSkeleton(),
        ),
      ),
    );
  }
}
