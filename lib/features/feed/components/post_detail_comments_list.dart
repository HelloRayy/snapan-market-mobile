import 'package:flutter/material.dart';
import 'package:snapan-market/core/components/snaps_skeleton.dart';
import 'package:snapan-market/features/feed/components/post_comment_item.dart';
import 'package:snapan-market/features/feed/components/post_detail_empty_comments.dart';
import 'package:snapan-market/features/feed/models/market_post_model.dart';

/// Renders author thread continuations, general comments, loading skeleton, or empty state.
class PostDetailCommentsList extends StatelessWidget {
  final MarketPostModel post;
  final List<PostCommentModel> comments;
  final bool isLoadingComments;
  final bool isProductMode;
  final void Function(String username, [String? commentId]) onReplyClick;
  final void Function(List<String> images, int index) onImageClick;

  const PostDetailCommentsList({
    super.key,
    required this.post,
    required this.comments,
    required this.isLoadingComments,
    required this.isProductMode,
    required this.onReplyClick,
    required this.onImageClick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (post.threadChain.isNotEmpty)
          ...post.threadChain.map((chain) {
            final chainComment = PostCommentModel(
              id: chain.id,
              postId: post.id,
              user: CommentUserModel(
                id: post.seller.id,
                name: post.seller.name,
                username: post.seller.username ?? post.seller.name,
                avatar: post.seller.avatar,
                classGroup: post.seller.classGroup,
                isVerified: post.seller.isVerified,
                isAuthor: true,
              ),
              content: chain.caption,
              images: chain.images,
              threadPart: chain.partNumber,
              totalParts: chain.totalParts,
              timestamp: chain.timestamp,
              likesCount: chain.likesCount,
              isLiked: chain.isLiked,
            );
            return PostCommentItem(
              key: ValueKey(chain.id),
              comment: chainComment,
              onReplyClick: (u) => onReplyClick(u, chain.id),
              onReplyToComment: (u, cId) => onReplyClick(u, cId),
              onImageClick: onImageClick,
            );
          }),
        if (comments.isNotEmpty)
          ...comments.map((comment) => PostCommentItem(
                key: ValueKey(comment.id),
                comment: comment,
                onReplyClick: (u) => onReplyClick(u, comment.id),
                onReplyToComment: (u, cId) => onReplyClick(u, cId),
                onImageClick: onImageClick,
              )),
        if (post.threadChain.isEmpty && comments.isEmpty && isLoadingComments)
          const CommentListSkeleton(itemCount: 3),
        if (post.threadChain.isEmpty && comments.isEmpty && !isLoadingComments)
          PostDetailEmptyComments(isProductMode: isProductMode),
      ],
    );
  }
}
