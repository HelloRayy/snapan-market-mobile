import 'package:flutter/material.dart';
import 'package:snapan_market/features/feed/components/post_card/post_card_header.dart';
import 'package:snapan_market/features/feed/components/post_card/post_caption_text.dart';
import 'package:snapan_market/features/feed/components/post_card/post_media_section.dart';
import 'package:snapan_market/features/feed/components/post_card/post_poll_section.dart';
import 'package:snapan_market/features/feed/components/post_card/post_action_bar.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

class PostCardContentColumn extends StatelessWidget {
  final MarketPostModel item;
  final bool isDetail;
  final bool isFollowed;
  final VoidCallback onFollowToggle;
  final ValueChanged<String>? onUserClick;
  final ValueChanged<String>? onTopicClick;
  final VoidCallback? onMoreOptionsClick;
  final ValueChanged<MarketPostModel>? onPostClick;
  final ValueChanged<MarketPostModel>? onDeletePost;
  final void Function(MarketPostModel item, int imageIndex)? onImageClick;
  final void Function(MarketPostModel item, List<String> optionIds)? onVotePoll;
  final bool isLiked;
  final int likesCount;
  final bool isReposted;
  final int repostsCount;
  final Animation<double> likeScaleAnim;
  final Animation<double> repostRotateAnim;
  final VoidCallback onLikeToggle;
  final VoidCallback onRepostToggle;
  final ValueChanged<MarketPostModel>? onShareClick;

  const PostCardContentColumn({
    super.key,
    required this.item,
    required this.isDetail,
    required this.isFollowed,
    required this.onFollowToggle,
    this.onUserClick,
    this.onTopicClick,
    this.onMoreOptionsClick,
    this.onPostClick,
    this.onDeletePost,
    this.onImageClick,
    this.onVotePoll,
    required this.isLiked,
    required this.likesCount,
    required this.isReposted,
    required this.repostsCount,
    required this.likeScaleAnim,
    required this.repostRotateAnim,
    required this.onLikeToggle,
    required this.onRepostToggle,
    this.onShareClick,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasCaption = item.caption.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasCaption || isDetail) ...[
          PostCardHeader(
            item: item,
            isDetail: isDetail,
            isFollowed: isFollowed,
            onFollowToggle: onFollowToggle,
            onUserClick: onUserClick,
            onTopicClick: onTopicClick,
            onMoreOptionsClick: onMoreOptionsClick,
            onPostClick: onPostClick,
            onDeletePost: onDeletePost,
          ),
          const SizedBox(height: 2.0),
          PostCaptionText(item: item),
        ] else ...[
          SizedBox(
            height: 42.0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: PostCardHeader(
                item: item,
                isDetail: false,
                isFollowed: isFollowed,
                onFollowToggle: onFollowToggle,
                onUserClick: onUserClick,
                onTopicClick: onTopicClick,
                onMoreOptionsClick: onMoreOptionsClick,
                onPostClick: onPostClick,
                onDeletePost: onDeletePost,
              ),
            ),
          ),
        ],
        if (item.poll != null) ...[
          const SizedBox(height: 8.0),
          PostPollSection(
            post: item,
            onVote: onVotePoll,
          ),
        ],
        if (item.images.isNotEmpty) ...[
          SizedBox(height: hasCaption ? 10.0 : 8.0),
          PostMediaSection(
            item: item,
            isDetail: isDetail,
            onImageClick: onImageClick,
          ),
        ],
        if (item.locationTag != null && item.locationTag!.isNotEmpty) ...[
          const SizedBox(height: 6.0),
          Text(
            item.locationTag!,
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
          item: item,
          isLiked: isLiked,
          likesCount: likesCount,
          isReposted: isReposted,
          repostsCount: repostsCount,
          likeScaleAnim: likeScaleAnim,
          repostRotateAnim: repostRotateAnim,
          onLikeToggle: onLikeToggle,
          onRepostToggle: onRepostToggle,
          onPostClick: onPostClick,
          onShareClick: onShareClick,
        ),
      ],
    );
  }
}
