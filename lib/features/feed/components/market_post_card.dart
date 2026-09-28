import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/feed/components/market_feed_icons.dart';
import 'package:snapan_market/features/feed/components/post_card/post_card.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Interactive Feed & Detail Card Component for Threads and Product Posts
///
/// Decomposed into clean, modular subcomponents (/tnr):
/// - [PostAuthorAvatar]: 42x42 circular avatar with thumb-friendly '+' follow badge
/// - [PostCardHeader]: Author name, verified badge, topic/class, timestamp, 3-dots
/// - [PostCaptionText]: Caption text with multi-thread indicator badge (e.g. `1/2`)
/// - [PostMediaSection]: Single image 4:5 or horizontal multi-image carousel
/// - [PostActionBar]: Interactive Like, Comment, Repost, Share, and Stock pill
class MarketPostCard extends StatefulWidget {
  final MarketPostModel item;
  final ValueChanged<MarketPostModel>? onPostClick;
  final ValueChanged<MarketPostModel>? onLikeToggle;
  final ValueChanged<MarketPostModel>? onRepostToggle;
  final ValueChanged<MarketPostModel>? onFollowToggle;
  final ValueChanged<MarketPostModel>? onShareClick;
  final ValueChanged<String>? onTopicClick;
  final ValueChanged<String>? onUserClick;
  final void Function(MarketPostModel item, int imageIndex)? onImageClick;
  final ValueChanged<MarketPostModel>? onDeletePost;
  final VoidCallback? onMoreOptionsClick;
  final String variant; // 'feed' | 'detail'

  const MarketPostCard({
    super.key,
    required this.item,
    this.onPostClick,
    this.onLikeToggle,
    this.onRepostToggle,
    this.onFollowToggle,
    this.onShareClick,
    this.onTopicClick,
    this.onUserClick,
    this.onImageClick,
    this.onMoreOptionsClick,
    this.onDeletePost,
    this.variant = 'feed',
  });

  @override
  State<MarketPostCard> createState() => _MarketPostCardState();
}

class _MarketPostCardState extends State<MarketPostCard>
    with TickerProviderStateMixin {
  late bool _isLiked;
  late int _likesCount;
  late bool _isReposted;
  late int _repostsCount;
  bool _isFollowed = false;

  late AnimationController _likeAnimController;
  late Animation<double> _likeScaleAnim;

  late AnimationController _repostAnimController;
  late Animation<double> _repostRotateAnim;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.item.isLiked;
    _likesCount = widget.item.likesCount;
    _isReposted = widget.item.isReposted;
    _repostsCount = widget.item.repostsCount;

    _likeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _likeScaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _likeAnimController,
      curve: Curves.easeInOut,
    ));

    _repostAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _repostRotateAnim = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _repostAnimController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(covariant MarketPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id ||
        oldWidget.item.likesCount != widget.item.likesCount ||
        oldWidget.item.isLiked != widget.item.isLiked ||
        oldWidget.item.isReposted != widget.item.isReposted ||
        oldWidget.item.repostsCount != widget.item.repostsCount) {
      _isLiked = widget.item.isLiked;
      _likesCount = widget.item.likesCount;
      _isReposted = widget.item.isReposted;
      _repostsCount = widget.item.repostsCount;
    }
  }

  @override
  void dispose() {
    _likeAnimController.dispose();
    _repostAnimController.dispose();
    super.dispose();
  }

  void _handleLikeToggle() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_isLiked) {
        _isLiked = false;
        _likesCount = (_likesCount - 1).clamp(0, 999999);
      } else {
        _isLiked = true;
        _likesCount += 1;
        _likeAnimController.forward(from: 0.0);
      }
    });

    final updated = widget.item.copyWith(
      isLiked: _isLiked,
      likesCount: _likesCount,
    );
    widget.onLikeToggle?.call(updated);
  }

  void _handleRepostToggle() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_isReposted) {
        _isReposted = false;
        _repostsCount = (_repostsCount - 1).clamp(0, 999999);
      } else {
        _isReposted = true;
        _repostsCount += 1;
        _repostAnimController.forward(from: 0.0);
      }
    });

    final updated = widget.item.copyWith(
      isReposted: _isReposted,
      repostsCount: _repostsCount,
    );
    widget.onRepostToggle?.call(updated);
  }

  void _handleFollowToggle() {
    HapticFeedback.lightImpact();
    setState(() => _isFollowed = !_isFollowed);

    if (widget.onFollowToggle != null) {
      widget.onFollowToggle!(widget.item);
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFollowed
                ? 'Mengikuti ${widget.item.seller.name}'
                : 'Batal mengikuti ${widget.item.seller.name}',
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.variant == 'detail') {
      return _buildDetailCard(context);
    }
    return _buildFeedCard(context);
  }

  /// DETAIL VARIANT: Full width column layout
  Widget _buildDetailCard(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.only(left: 14.0, right: 14.0, top: 12.0, bottom: 14.0),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.cloudGray, width: 1.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostCardHeader(
              item: widget.item,
              isDetail: true,
              isFollowed: _isFollowed,
              onFollowToggle: _handleFollowToggle,
              onUserClick: widget.onUserClick,
              onTopicClick: widget.onTopicClick,
              onMoreOptionsClick: widget.onMoreOptionsClick,
              onPostClick: widget.onPostClick,
              onDeletePost: widget.onDeletePost,
            ),
            const SizedBox(height: 6.0),
            PostCaptionText(item: widget.item),
            if (widget.item.images.isNotEmpty) ...[
              const SizedBox(height: 10.0),
              PostMediaSection(item: widget.item, isDetail: true, onImageClick: widget.onImageClick),
            ],
            if (widget.item.locationTag != null && widget.item.locationTag!.isNotEmpty) ...[
              const SizedBox(height: 6.0),
              Text(
                widget.item.locationTag!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                  letterSpacing: -0.1,
                  height: 1.25,
                ),
              ),
            ],
            const SizedBox(height: 8.0),
            PostActionBar(
              item: widget.item,
              isLiked: _isLiked,
              likesCount: _likesCount,
              isReposted: _isReposted,
              repostsCount: _repostsCount,
              likeScaleAnim: _likeScaleAnim,
              repostRotateAnim: _repostRotateAnim,
              onLikeToggle: _handleLikeToggle,
              onRepostToggle: _handleRepostToggle,
              onPostClick: widget.onPostClick,
              onShareClick: widget.onShareClick,
            ),
          ],
        ),
      ),
    );
  }

  /// FEED VARIANT: Two-column layout with Multi-part Thread Vertical Connector Line
  Widget _buildFeedCard(BuildContext context) {
    final hasChain = widget.item.threadChain.isNotEmpty;

    return GestureDetector(
      onTap: () => widget.onPostClick?.call(widget.item),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: AppColors.cloudGray, width: 1.0)),
        ),
        child: hasChain
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPartOneWithConnector(context),
                  ...widget.item.threadChain.asMap().entries.map((entry) {
                    final int idx = entry.key;
                    final ThreadChainItemModel chain = entry.value;
                    final bool isLast = idx == widget.item.threadChain.length - 1;
                    return _buildChainItemWithConnector(context, chain, isLast: isLast);
                  }),
                ],
              )
            : _buildSinglePostRow(context),
      ),
    );
  }

  /// Standard Single Post Row (Left Avatar, Right Content)
  Widget _buildSinglePostRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostAuthorAvatar(
          seller: widget.item.seller,
          isFollowed: _isFollowed,
          onFollowToggle: _handleFollowToggle,
          onUserClick: () => widget.onUserClick?.call(widget.item.seller.username ?? widget.item.seller.name),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PostCardHeader(
                item: widget.item,
                isDetail: false,
                isFollowed: _isFollowed,
                onFollowToggle: _handleFollowToggle,
                onUserClick: widget.onUserClick,
                onTopicClick: widget.onTopicClick,
                onMoreOptionsClick: widget.onMoreOptionsClick,
                onPostClick: widget.onPostClick,
                onDeletePost: widget.onDeletePost,
              ),
              const SizedBox(height: 2.0),
              PostCaptionText(item: widget.item),
              if (widget.item.images.isNotEmpty) ...[
                const SizedBox(height: 10.0),
                PostMediaSection(item: widget.item, isDetail: false, onImageClick: widget.onImageClick),
              ],
              if (widget.item.locationTag != null && widget.item.locationTag!.isNotEmpty) ...[
                const SizedBox(height: 6.0),
                Text(
                  widget.item.locationTag!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
                    letterSpacing: -0.1,
                    height: 1.25,
                  ),
                ),
              ],
              const SizedBox(height: 8.0),
              PostActionBar(
                item: widget.item,
                isLiked: _isLiked,
                likesCount: _likesCount,
                isReposted: _isReposted,
                repostsCount: _repostsCount,
                likeScaleAnim: _likeScaleAnim,
                repostRotateAnim: _repostRotateAnim,
                onLikeToggle: _handleLikeToggle,
                onRepostToggle: _handleRepostToggle,
                onPostClick: widget.onPostClick,
                onShareClick: widget.onShareClick,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Part 1 of Multi-part Thread with Vertical Line Connector extending downward
  Widget _buildPartOneWithConnector(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44.0,
            child: Column(
              children: [
                PostAuthorAvatar(
                  seller: widget.item.seller,
                  isFollowed: _isFollowed,
                  onFollowToggle: _handleFollowToggle,
                  onUserClick: () => widget.onUserClick?.call(widget.item.seller.username ?? widget.item.seller.name),
                ),
                const SizedBox(height: 6.0),
                Expanded(
                  child: Center(
                    child: Container(
                      width: 2.0,
                      decoration: BoxDecoration(
                        color: AppColors.cloudGray,
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PostCardHeader(
                  item: widget.item,
                  isDetail: false,
                  isFollowed: _isFollowed,
                  onFollowToggle: _handleFollowToggle,
                  onUserClick: widget.onUserClick,
                  onTopicClick: widget.onTopicClick,
                  onMoreOptionsClick: widget.onMoreOptionsClick,
                  onPostClick: widget.onPostClick,
                  onDeletePost: widget.onDeletePost,
                ),
                const SizedBox(height: 2.0),
                PostCaptionText(item: widget.item),
                if (widget.item.images.isNotEmpty) ...[
                  const SizedBox(height: 10.0),
                  PostMediaSection(item: widget.item, isDetail: false, onImageClick: widget.onImageClick),
                ],
                if (widget.item.locationTag != null && widget.item.locationTag!.isNotEmpty) ...[
                  const SizedBox(height: 6.0),
                  Text(
                    widget.item.locationTag!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF64748B),
                      letterSpacing: -0.1,
                      height: 1.25,
                    ),
                  ),
                ],
                const SizedBox(height: 8.0),
                PostActionBar(
                  item: widget.item,
                  isLiked: _isLiked,
                  likesCount: _likesCount,
                  isReposted: _isReposted,
                  repostsCount: _repostsCount,
                  likeScaleAnim: _likeScaleAnim,
                  repostRotateAnim: _repostRotateAnim,
                  onLikeToggle: _handleLikeToggle,
                  onRepostToggle: _handleRepostToggle,
                  onPostClick: widget.onPostClick,
                  onShareClick: widget.onShareClick,
                ),
                const SizedBox(height: 8.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Chained Continuation Item connected via Continuous Vertical Thread Line
  Widget _buildChainItemWithConnector(
    BuildContext context,
    ThreadChainItemModel chain, {
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44.0,
            child: Column(
              children: [
                // Top connecting line from previous part into this avatar
                Container(
                  width: 2.0,
                  height: 10.0,
                  decoration: BoxDecoration(
                    color: AppColors.cloudGray,
                    borderRadius: BorderRadius.circular(1.0),
                  ),
                ),
                // Chained Part Avatar (36x36 circular, matching continuation in Threads)
                Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 1.0),
                  ),
                  child: ClipOval(
                    child: widget.item.seller.avatar.startsWith('assets/')
                        ? Image.asset(
                            widget.item.seller.avatar,
                            width: 36.0,
                            height: 36.0,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            widget.item.seller.avatar,
                            width: 36.0,
                            height: 36.0,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.primaryPastel,
                              child: Center(
                                child: Text(
                                  widget.item.seller.name.isNotEmpty
                                      ? widget.item.seller.name[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                if (!isLast) ...[
                  const SizedBox(height: 6.0),
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 2.0,
                        decoration: BoxDecoration(
                          color: AppColors.cloudGray,
                          borderRadius: BorderRadius.circular(1.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4.0),
                // Header for chained part
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.item.seller.name,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (widget.item.seller.isVerified) ...[
                          const SizedBox(width: 4.0),
                          const Icon(
                            Icons.verified_rounded,
                            size: 15.0,
                            color: AppColors.verifiedBlue,
                          ),
                        ],
                        const SizedBox(width: 6.0),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            '${chain.partNumber}/${chain.totalParts}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.graphite,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      chain.timestamp,
                      style: const TextStyle(
                        fontSize: 13.0,
                        color: AppColors.graphite,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  chain.caption,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.35,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (chain.images.isNotEmpty) ...[
                  const SizedBox(height: 8.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: chain.images.first.startsWith('assets/')
                        ? Image.asset(
                            chain.images.first,
                            height: 180.0,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            chain.images.first,
                            height: 180.0,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                ],
                const SizedBox(height: 6.0),
                // Minimalist engagement bar for chained continuation
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      FeedHeartIcon(
                        isLiked: chain.isLiked,
                        size: 17.0,
                        activeColor: const Color(0xFFF43F5E),
                        inactiveColor: AppColors.ashGray,
                      ),
                      if (chain.likesCount > 0) ...[
                        const SizedBox(width: 4.0),
                        Text(
                          '${chain.likesCount}',
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: AppColors.graphite,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                      const SizedBox(width: 14.0),
                      const FeedCommentIcon(
                        size: 16.0,
                        color: AppColors.ashGray,
                      ),
                      if (chain.commentsCount > 0) ...[
                        const SizedBox(width: 4.0),
                        Text(
                          '${chain.commentsCount}',
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: AppColors.graphite,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                      const SizedBox(width: 14.0),
                      const FeedRepostIcon(
                        isReposted: false,
                        size: 17.0,
                        inactiveColor: AppColors.ashGray,
                      ),
                      const SizedBox(width: 14.0),
                      const FeedShareIcon(
                        size: 16.0,
                        color: AppColors.ashGray,
                      ),
                    ],
                  ),
                ),
                if (!isLast) const SizedBox(height: 8.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
