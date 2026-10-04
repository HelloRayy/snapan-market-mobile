import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/utils/formatters.dart';
import 'package:snapan_market/core/utils/mention_text_span_helper.dart';
import 'package:snapan_market/features/feed/components/comment/comment_action_bar.dart';
import 'package:snapan_market/features/feed/components/comment/comment_author_badge.dart';
import 'package:snapan_market/features/feed/components/comment/comment_avatar.dart';
import 'package:snapan_market/features/feed/components/comment/comment_images_section.dart';
import 'package:snapan_market/features/feed/components/comment/comment_options_sheet.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Single Child Reply Tile styled with clean minimalist Instagram / X indent
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
  final String? postAuthorId;
  final ValueChanged<String>? onDeleteComment;

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
    this.postAuthorId,
    this.onDeleteComment,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Compact Child Avatar (28x28)
        CommentAvatar(
          avatarUrl: reply.user.avatar,
          name: reply.user.name,
          username: reply.user.username,
          size: 28.0,
          onUserClick: onUserClick,
        ),

        const SizedBox(width: 10.0),

        // Right Column: Header, Content, Images, Action Bar
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderRow(context),
              const SizedBox(height: 2.5),
              _buildContentText(context),
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
                      fontSize: 13.5,
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
                  size: 14.0,
                  color: AppColors.verifiedBlue,
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
                  fontSize: 11.5,
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
            postAuthorId: postAuthorId,
            onReplyClick: onReplyClick,
            onReplyToComment: onReplyToComment,
            onDeleteComment: onDeleteComment,
          ),
          borderRadius: BorderRadius.circular(15.0),
          splashColor: const Color(0xFFF1F5F9),
          highlightColor: Colors.transparent,
          child: Container(
            width: 30.0,
            height: 30.0,
            alignment: Alignment.center,
            child: const Icon(
              Icons.more_horiz_rounded,
              size: 17.5,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentText(BuildContext context) {
    const baseStyle = TextStyle(
      fontFamily: 'SFPro',
      fontFamilyFallback: ['AppleColorEmoji'],
      fontSize: 14.5,
      fontWeight: FontWeight.normal,
      color: Color(0xFF0F172A),
      height: 1.35,
      letterSpacing: -0.1,
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          ...MentionTextSpanHelper.buildSpans(
            context: context,
            text: reply.content,
            defaultStyle: baseStyle,
            onUserClick: onUserClick,
          ),
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
