import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/services/follow_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/feed/components/post_card/post_author_avatar.dart';
import 'package:snapan_market/features/feed/components/post_card/post_card_content_column.dart';
import 'package:snapan_market/features/feed/components/post_card/post_thread_chain_section.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Interactive Feed & Detail Card Component for Threads and Product Posts (<250 lines).
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
  final void Function(MarketPostModel item, List<String> optionIds)? onVotePoll;
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
    this.onVotePoll,
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

    widget.onLikeToggle?.call(widget.item.copyWith(
      isLiked: _isLiked,
      likesCount: _likesCount,
    ));
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

    widget.onRepostToggle?.call(widget.item.copyWith(
      isReposted: _isReposted,
      repostsCount: _repostsCount,
    ));
  }

  void _handleFollowToggle() {
    HapticFeedback.mediumImpact();
    setState(() => _isFollowed = !_isFollowed);
    final sellerId = widget.item.seller.id;
    if (sellerId.isNotEmpty) {
      FollowService.instance.toggleFollow(
        targetUserId: sellerId,
        targetUsername: widget.item.seller.username,
      );
    }
    widget.onFollowToggle?.call(widget.item);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.variant == 'detail') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: AppColors.cloudGray, width: 1.0)),
        ),
        child: PostCardContentColumn(
          item: widget.item,
          isDetail: true,
          isFollowed: _isFollowed,
          onFollowToggle: _handleFollowToggle,
          onUserClick: widget.onUserClick,
          onTopicClick: widget.onTopicClick,
          onMoreOptionsClick: widget.onMoreOptionsClick,
          onPostClick: widget.onPostClick,
          onDeletePost: widget.onDeletePost,
          onImageClick: widget.onImageClick,
          onVotePoll: widget.onVotePoll,
          isLiked: _isLiked,
          likesCount: _likesCount,
          isReposted: _isReposted,
          repostsCount: _repostsCount,
          likeScaleAnim: _likeScaleAnim,
          repostRotateAnim: _repostRotateAnim,
          onLikeToggle: _handleLikeToggle,
          onRepostToggle: _handleRepostToggle,
          onShareClick: widget.onShareClick,
        ),
      );
    }

    // FEED VARIANT
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
                  _buildRowWithAvatar(showConnector: true),
                  ...widget.item.threadChain.asMap().entries.map((entry) {
                    final isLast = entry.key == widget.item.threadChain.length - 1;
                    return PostThreadChainItem(
                      post: widget.item,
                      chain: entry.value,
                      isLast: isLast,
                    );
                  }),
                ],
              )
            : _buildRowWithAvatar(showConnector: false),
      ),
    );
  }

  Widget _buildRowWithAvatar({required bool showConnector}) {
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
                if (showConnector) ...[
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
            child: PostCardContentColumn(
              item: widget.item,
              isDetail: false,
              isFollowed: _isFollowed,
              onFollowToggle: _handleFollowToggle,
              onUserClick: widget.onUserClick,
              onTopicClick: widget.onTopicClick,
              onMoreOptionsClick: widget.onMoreOptionsClick,
              onPostClick: widget.onPostClick,
              onDeletePost: widget.onDeletePost,
              onImageClick: widget.onImageClick,
              onVotePoll: widget.onVotePoll,
              isLiked: _isLiked,
              likesCount: _likesCount,
              isReposted: _isReposted,
              repostsCount: _repostsCount,
              likeScaleAnim: _likeScaleAnim,
              repostRotateAnim: _repostRotateAnim,
              onLikeToggle: _handleLikeToggle,
              onRepostToggle: _handleRepostToggle,
              onShareClick: widget.onShareClick,
            ),
          ),
        ],
      ),
    );
  }
}
