import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/utils/formatters.dart';
import 'package:snapan_market/features/feed/components/comment/comment_action_bar.dart';
import 'package:snapan_market/features/feed/components/comment/comment_author_badge.dart';
import 'package:snapan_market/features/feed/components/comment/comment_avatar.dart';
import 'package:snapan_market/features/feed/components/comment/comment_images_section.dart';
import 'package:snapan_market/features/feed/components/comment/comment_options_sheet.dart';
import 'package:snapan_market/features/feed/components/comment/thread_branch_painter.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Single Child Reply Tile connected to the parent thread via Threads curved branch
class CommentReplyTile extends StatelessWidget {
  final PostCommentModel reply;
  final String parentCommentId;
  final bool isFirst;
  final bool isLast;
  final ValueChanged<PostCommentModel> onLikeToggle;
  final void Function(String username, String commentId)? onReplyToComment;
  final ValueChanged<String>? onReplyClick;
  final ValueChanged<String>? onUserClick;
  final void Function(List<String> images, int index)? onImageClick;
  final ValueChanged<String> onShare;

  const CommentReplyTile({
    super.key,
    required this.reply,
    required this.parentCommentId,
    required this.isFirst,
    required this.isLast,
    required this.onLikeToggle,
    this.onReplyToComment,
    this.onReplyClick,
    this.onUserClick,
    this.onImageClick,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Branch Column: L-curve or vertical connector + Child Avatar (36x36)
          SizedBox(
            width: 64.0, // 28.0 indent/curve + 36.0 avatar
            child: Stack(
              children: [
                // 1. Initial L-Branch curve connecting from Parent's vertical line at x = 18.0
                if (isFirst)
                  const Positioned.fill(
                    child: CustomPaint(
                      painter: ReplyLBranchPainter(
                        color: Color(0xFFD1D5DB),
                        strokeWidth: 1.8,
                        startX: 18.0,
                        targetX: 28.0,
                        targetY: 18.0,
                        radius: 10.0,
                      ),
                    ),
                  ),

                // 2. Straight line entering top of avatar for subsequent replies (index > 0)
                if (!isFirst)
                  Positioned(
                    left: 45.1,
                    top: 0,
                    child: Container(
                      width: 1.8,
                      height: 18.0,
                      color: const Color(0xFFD1D5DB),
                    ),
                  ),

                // 3. Straight vertical line continuing below avatar to subsequent replies
                if (!isLast)
                  Positioned(
                    left: 45.1,
                    top: 36.0,
                    bottom: 0,
                    child: Container(
                      width: 1.8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                    ),
                  ),

                // 4. Avatar (36x36) at left: 28.0, top: 0
                Positioned(
                  left: 28.0,
                  top: 0,
                  child: CommentAvatar(
                    avatarUrl: reply.user.avatar,
                    name: reply.user.name,
                    username: reply.user.username,
                    size: 36.0,
                    onUserClick: onUserClick,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12.0),

          // Right Column: Header, Content, Images, Action Bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderRow(context),
                const SizedBox(height: 3.0),
                _buildContentText(),
                if (reply.images.isNotEmpty) ...[
                  const SizedBox(height: 8.0),
                  CommentImagesSection(
                    images: reply.images,
                    onImageClick: onImageClick,
                  ),
                ],
                const SizedBox(height: 4.0),
                CommentActionBar(
                  isLiked: reply.isLiked,
                  likesCount: reply.likesCount,
                  onLikeToggle: () {
                    final isLiked = !reply.isLiked;
                    final count = isLiked
                        ? reply.likesCount + 1
                        : (reply.likesCount - 1).clamp(0, 999999);
                    onLikeToggle(reply.copyWith(isLiked: isLiked, likesCount: count));
                  },
                  onReply: () {
                    final targetUsername = reply.user.username ?? reply.user.name;
                    if (onReplyToComment != null) {
                      onReplyToComment!(targetUsername, parentCommentId);
                    } else {
                      onReplyClick?.call(targetUsername);
                    }
                  },
                  onShare: () => onShare(reply.content),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    final username = reply.user.username ?? reply.user.name;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: Username + Verified + Author Badge + Timestamp
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    onUserClick?.call(username);
                  },
                  child: Text(
                    username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),
              if (reply.user.isVerified) ...[
                const SizedBox(width: 4.0),
                const Icon(
                  Icons.verified_rounded,
                  size: 14.5,
                  color: AppColors.primary,
                ),
              ],
              if (reply.user.isAuthor) ...[
                const SizedBox(width: 6.0),
                const CommentAuthorBadge(),
              ],
              const SizedBox(width: 6.0),
              Text(
                formatSmartTimestamp(reply.timestamp),
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),

        // Right: 3-dots Menu Button
        InkWell(
          onTap: () => CommentOptionsSheet.show(
            context: context,
            comment: reply,
            parentCommentId: parentCommentId,
            onReplyClick: onReplyClick,
            onReplyToComment: onReplyToComment,
          ),
          borderRadius: BorderRadius.circular(19.0),
          splashColor: const Color(0xFFF1F5F9),
          highlightColor: Colors.transparent,
          child: Container(
            width: 38.0,
            height: 38.0,
            alignment: Alignment.center,
            child: const Icon(
              Icons.more_horiz_rounded,
              size: 19.0,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentText() {
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.normal,
          color: Color(0xFF0F172A),
          height: 1.35,
          letterSpacing: -0.1,
        ),
        children: [
          TextSpan(text: reply.content),
          if (reply.threadPart != null && reply.totalParts != null)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                margin: const EdgeInsets.only(left: 6.0),
                padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  '${reply.threadPart}/${reply.totalParts}',
                  style: const TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
