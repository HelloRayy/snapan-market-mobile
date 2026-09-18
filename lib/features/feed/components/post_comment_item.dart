import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/utils/formatters.dart';
import 'package:snapan_market/features/feed/components/comment/comment_action_bar.dart';
import 'package:snapan_market/features/feed/components/comment/comment_author_badge.dart';
import 'package:snapan_market/features/feed/components/comment/comment_avatar.dart';
import 'package:snapan_market/features/feed/components/comment/comment_images_section.dart';
import 'package:snapan_market/features/feed/components/comment/comment_options_sheet.dart';
import 'package:snapan_market/features/feed/components/comment/comment_replies_expand_row.dart';
import 'package:snapan_market/features/feed/components/comment/comment_reply_tile.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// PostCommentItem Widget
/// Modular Threads conversation card with continuous threadline tree
class PostCommentItem extends StatefulWidget {
  final PostCommentModel comment;
  final ValueChanged<String>? onReplyClick;
  final void Function(String username, String commentId)? onReplyToComment;
  final ValueChanged<PostCommentModel>? onLikeToggle;
  final ValueChanged<String>? onUserClick;
  final void Function(List<String> images, int index)? onImageClick;
  final bool isNested;
  final bool isLastNested;
  final String? parentCommentId;

  const PostCommentItem({
    super.key,
    required this.comment,
    this.onReplyClick,
    this.onReplyToComment,
    this.onLikeToggle,
    this.onUserClick,
    this.onImageClick,
    this.isNested = false,
    this.isLastNested = false,
    this.parentCommentId,
  });

  @override
  State<PostCommentItem> createState() => _PostCommentItemState();
}

class _PostCommentItemState extends State<PostCommentItem> {
  late bool _isLiked;
  late int _likesCount;
  bool _isRepliesExpanded = true;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.comment.isLiked;
    _likesCount = widget.comment.likesCount;
  }

  @override
  void didUpdateWidget(covariant PostCommentItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.comment.id != widget.comment.id ||
        oldWidget.comment.isLiked != widget.comment.isLiked ||
        oldWidget.comment.likesCount != widget.comment.likesCount) {
      _isLiked = widget.comment.isLiked;
      _likesCount = widget.comment.likesCount;
    }
    // Auto-expand replies threadline when a new reply is added
    if (widget.comment.replies.length > oldWidget.comment.replies.length) {
      _isRepliesExpanded = true;
    }
  }

  void _handleLikeToggle() {
    setState(() {
      _isLiked = !_isLiked;
      _likesCount = _isLiked ? _likesCount + 1 : (_likesCount - 1).clamp(0, 999999);
    });

    final updated = widget.comment.copyWith(
      isLiked: _isLiked,
      likesCount: _likesCount,
    );
    widget.onLikeToggle?.call(updated);
  }

  void _handleReplyLikeToggle(PostCommentModel updatedReply) {
    final updatedReplies = widget.comment.replies.map((r) {
      return r.id == updatedReply.id ? updatedReply : r;
    }).toList();

    widget.onLikeToggle?.call(widget.comment.copyWith(replies: updatedReplies));
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Teks komentar disalin ke papan klip'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasReplies = widget.comment.replies.isNotEmpty;

    // 1. NESTED CHILD REPLY VARIANT (Standalone)
    if (widget.isNested) {
      return CommentReplyTile(
        reply: widget.comment,
        parentCommentId: widget.parentCommentId ?? widget.comment.id,
        isFirst: true,
        isLast: widget.isLastNested,
        onLikeToggle: (updated) => widget.onLikeToggle?.call(updated),
        onReplyToComment: widget.onReplyToComment,
        onReplyClick: widget.onReplyClick,
        onUserClick: widget.onUserClick,
        onImageClick: widget.onImageClick,
        onShare: _copyToClipboard,
      );
    }

    // 2. MAIN TOP-LEVEL COMMENT VARIANT
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Parent Comment Row (Dynamic height continuous threadline)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Avatar (36x36) + Continuous Vertical Line
                SizedBox(
                  width: 36.0,
                  child: Column(
                    children: [
                      CommentAvatar(
                        avatarUrl: widget.comment.user.avatar,
                        name: widget.comment.user.name,
                        username: widget.comment.user.username,
                        size: 36.0,
                        onUserClick: widget.onUserClick,
                      ),
                      if (hasReplies && _isRepliesExpanded) ...[
                        const SizedBox(height: 4.0),
                        Expanded(
                          child: Center(
                            child: Container(
                              width: 1.8,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1D5DB),
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

                // Right Column: Header, Content, Images, Action Bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderRow(context),
                      const SizedBox(height: 3.0),
                      _buildContentText(),
                      if (widget.comment.images.isNotEmpty) ...[
                        const SizedBox(height: 8.0),
                        CommentImagesSection(
                          images: widget.comment.images,
                          onImageClick: widget.onImageClick,
                        ),
                      ],
                      const SizedBox(height: 4.0),
                      CommentActionBar(
                        isLiked: _isLiked,
                        likesCount: _likesCount,
                        onLikeToggle: _handleLikeToggle,
                        onReply: () {
                          final targetUsername = widget.comment.user.username ?? widget.comment.user.name;
                          if (widget.onReplyToComment != null) {
                            widget.onReplyToComment!(targetUsername, widget.comment.id);
                          } else {
                            widget.onReplyClick?.call(targetUsername);
                          }
                        },
                        onShare: () => _copyToClipboard(widget.comment.content),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Replies Tree connected with Threads Curved Line
          if (hasReplies) ...[
            if (!_isRepliesExpanded)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: CommentRepliesExpandRow(
                  replies: widget.comment.replies,
                  isExpanded: false,
                  onToggle: () => setState(() => _isRepliesExpanded = true),
                ),
              )
            else ...[
              // Connector line bridging parent row to child reply
              Container(
                margin: const EdgeInsets.only(left: 17.1),
                width: 1.8,
                height: 10.0,
                color: const Color(0xFFD1D5DB),
              ),

              // Child Replies
              ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.comment.replies.length,
                itemBuilder: (context, idx) {
                  final reply = widget.comment.replies[idx];
                  final isFirst = idx == 0;
                  final isLast = idx == widget.comment.replies.length - 1;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isFirst)
                        Container(
                          margin: const EdgeInsets.only(left: 45.1),
                          width: 1.8,
                          height: 10.0,
                          color: const Color(0xFFD1D5DB),
                        ),
                      CommentReplyTile(
                        reply: reply,
                        parentCommentId: widget.comment.id,
                        isFirst: isFirst,
                        isLast: isLast,
                        onLikeToggle: _handleReplyLikeToggle,
                        onReplyToComment: widget.onReplyToComment,
                        onReplyClick: widget.onReplyClick,
                        onUserClick: widget.onUserClick,
                        onImageClick: widget.onImageClick,
                        onShare: _copyToClipboard,
                      ),
                    ],
                  );
                },
              ),

              if (widget.comment.replies.length > 2)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: CommentRepliesExpandRow(
                    replies: widget.comment.replies,
                    isExpanded: true,
                    onToggle: () => setState(() => _isRepliesExpanded = false),
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    final username = widget.comment.user.username ?? widget.comment.user.name;

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
                    widget.onUserClick?.call(username);
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
              if (widget.comment.user.isVerified) ...[
                const SizedBox(width: 4.0),
                const Icon(
                  Icons.verified_rounded,
                  size: 14.5,
                  color: AppColors.primary,
                ),
              ],
              if (widget.comment.user.isAuthor) ...[
                const SizedBox(width: 6.0),
                const CommentAuthorBadge(),
              ],
              const SizedBox(width: 6.0),
              Text(
                formatSmartTimestamp(widget.comment.timestamp),
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
            comment: widget.comment,
            parentCommentId: widget.comment.id,
            onReplyClick: widget.onReplyClick,
            onReplyToComment: widget.onReplyToComment,
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
          TextSpan(text: widget.comment.content),
          if (widget.comment.threadPart != null &&
              widget.comment.totalParts != null)
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
                  '${widget.comment.threadPart}/${widget.comment.totalParts}',
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
