import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.0)),
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
            const SizedBox(height: 10.0),
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

  /// FEED VARIANT: Two-column layout (Left Avatar, Right Content)
  Widget _buildFeedCard(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onPostClick?.call(widget.item),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.0)),
        ),
        child: Row(
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
        ),
      ),
    );
  }
}
