import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/utils/formatters.dart';
import 'package:snapan_market/core/utils/mention_text_span_helper.dart';
import 'package:snapan_market/features/feed/components/comment/comment_author_badge.dart';
import 'package:snapan_market/features/feed/components/comment/comment_avatar.dart';
import 'package:snapan_market/features/feed/components/comment/comment_images_section.dart';
import 'package:snapan_market/features/feed/components/comment/comment_options_sheet.dart';
import 'package:snapan_market/features/feed/components/comment/comment_sub_action_row.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Single Child Reply Tile styled with clean minimalist Instagram / X indent
class CommentReplyTile extends StatefulWidget {
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
  State<CommentReplyTile> createState() => _CommentReplyTileState();
}

class _CommentReplyTileState extends State<CommentReplyTile> {
  bool _isTextExpanded = false;

  void _handleLikeToggle() {
    final isLiked = !widget.reply.isLiked;
    final count = isLiked
        ? widget.reply.likesCount + 1
        : (widget.reply.likesCount - 1).clamp(0, 999999);
    widget.onLikeToggle(widget.reply.copyWith(isLiked: isLiked, likesCount: count));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Compact Child Avatar (28x28)
        CommentAvatar(
          avatarUrl: widget.reply.user.avatar,
          name: widget.reply.user.name,
          username: widget.reply.user.username,
          size: 28.0,
          onUserClick: widget.onUserClick,
        ),

        const SizedBox(width: 10.0),

        // Center Column: Header, Content, Images, Sub-Action Row
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderRow(context),
              const SizedBox(height: 2.5),
              _buildContentText(context),
              if (widget.reply.images.isNotEmpty) ...[
                const SizedBox(height: 8.0),
                CommentImagesSection(
                  images: widget.reply.images,
                  onImageClick: widget.onImageClick,
                ),
              ],
              const SizedBox(height: 6.0),
              CommentSubActionRow(
                timestamp: widget.reply.timestamp,
                likesCount: widget.reply.likesCount,
                isLiked: widget.reply.isLiked,
                onLike: _handleLikeToggle,
                onReply: () {
                  final rawUsername = (widget.reply.user.username != null && widget.reply.user.username!.isNotEmpty)
                      ? widget.reply.user.username!
                      : widget.reply.user.name;
                  final targetUsername = rawUsername.trim().replaceAll('@', '').replaceAll(' ', '_');
                  if (widget.onReplyToComment != null) {
                    widget.onReplyToComment!(targetUsername, widget.parentCommentId);
                  } else {
                    widget.onReplyClick?.call(targetUsername);
                  }
                },
                onOptions: () => CommentOptionsSheet.show(
                  context: context,
                  comment: widget.reply,
                  parentCommentId: widget.parentCommentId,
                  postAuthorId: widget.postAuthorId,
                  onReplyClick: widget.onReplyClick,
                  onReplyToComment: widget.onReplyToComment,
                  onDeleteComment: widget.onDeleteComment,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    final hasDisplayName = widget.reply.user.displayName != null && widget.reply.user.displayName!.trim().isNotEmpty;
    final rawUsername = (widget.reply.user.username != null && widget.reply.user.username!.isNotEmpty)
        ? widget.reply.user.username!
        : widget.reply.user.name;
    final cleanUsername = rawUsername.trim().replaceAll('@', '');
    final displayAuthor = hasDisplayName
        ? widget.reply.user.displayName!.trim()
        : '@$cleanUsername';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    widget.onUserClick?.call(cleanUsername);
                  },
                  child: Text(
                    displayAuthor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'SFPro',
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),
              if (widget.reply.user.isVerified) ...[
                const SizedBox(width: 4.0),
                const Icon(
                  Icons.verified_rounded,
                  size: 13.0,
                  color: AppColors.verifiedBlue,
                ),
              ],
              if (widget.reply.user.isAuthor) ...[
                const SizedBox(width: 5.0),
                const CommentAuthorBadge(),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8.0),
        // Timestamp
        Text(
          formatSmartTimestamp(widget.reply.timestamp),
          style: const TextStyle(
            fontFamily: 'SFPro',
            fontSize: 11.5,
            fontWeight: FontWeight.normal,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(width: 8.0),
        // Three-dots menu
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            CommentOptionsSheet.show(
              context: context,
              comment: widget.reply,
              parentCommentId: widget.parentCommentId,
              postAuthorId: widget.postAuthorId,
              onReplyClick: widget.onReplyClick,
              onReplyToComment: widget.onReplyToComment,
              onDeleteComment: widget.onDeleteComment,
            );
          },
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
            child: Icon(
              Icons.more_horiz_rounded,
              size: 15.0,
              color: Color(0xFF94A3B8),
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
      fontSize: 13.5,
      fontWeight: FontWeight.normal,
      color: Color(0xFF0F172A),
      height: 1.35,
      letterSpacing: -0.1,
    );

    final isLong = widget.reply.content.length > 90 || widget.reply.content.contains('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: baseStyle,
            children: MentionTextSpanHelper.buildSpans(
              context: context,
              text: widget.reply.content,
              defaultStyle: baseStyle,
              onUserClick: widget.onUserClick,
            ),
          ),
          maxLines: _isTextExpanded ? null : 3,
          overflow: _isTextExpanded ? TextOverflow.clip : TextOverflow.ellipsis,
        ),
        if (isLong)
          GestureDetector(
            onTap: () {
              setState(() => _isTextExpanded = !_isTextExpanded);
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(top: 2.5),
              child: Text(
                _isTextExpanded ? 'Sembunyikan' : 'Lihat selengkapnya',
                style: const TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
