import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/utils/formatters.dart';
import 'package:snapan_market/core/utils/mention_text_span_helper.dart';
import 'package:snapan_market/features/feed/components/comment/comment.dart';
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
  final String? postAuthorId;
  final ValueChanged<String>? onDeleteComment;

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
    this.postAuthorId,
    this.onDeleteComment,
  });

  @override
  State<PostCommentItem> createState() => _PostCommentItemState();
}

class _PostCommentItemState extends State<PostCommentItem> {
  late bool _isLiked;
  late int _likesCount;
  bool _isRepliesExpanded = false;
  int _visibleRepliesCount = 3;
  bool _isTextExpanded = false;

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
    // Auto-expand and include newest reply when user adds a new reply
    if (widget.comment.replies.length > oldWidget.comment.replies.length) {
      _isRepliesExpanded = true;
      _visibleRepliesCount = widget.comment.replies.length;
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
    widget.onLikeToggle?.call(updatedReply);
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
      return Padding(
        padding: const EdgeInsets.only(left: 48.0, top: 4.0, bottom: 4.0),
        child: CommentReplyTile(
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
          postAuthorId: widget.postAuthorId,
          onDeleteComment: widget.onDeleteComment,
        ),
      );
    }

    // 2. MAIN TOP-LEVEL COMMENT VARIANT (Instagram Style)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF8FAFC), width: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Parent Comment Row (Instagram Style: Avatar + Content + Inline Actions)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Parent Avatar (36x36)
              CommentAvatar(
                avatarUrl: widget.comment.user.avatar,
                name: widget.comment.user.name,
                username: widget.comment.user.username,
                size: 36.0,
                onUserClick: widget.onUserClick,
              ),

              const SizedBox(width: 10.0),

              // Center Column: Username, Content, Images, Sub-Action Row
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderRow(context),
                    const SizedBox(height: 2.5),
                    _buildContentText(),
                    if (widget.comment.images.isNotEmpty) ...[
                      const SizedBox(height: 8.0),
                      CommentImagesSection(
                        images: widget.comment.images,
                        onImageClick: widget.onImageClick,
                      ),
                    ],
                    const SizedBox(height: 6.0),
                    CommentSubActionRow(
                      timestamp: widget.comment.timestamp,
                      likesCount: _likesCount,
                      isLiked: _isLiked,
                      onLike: _handleLikeToggle,
                      onReply: () {
                        final rawUsername = (widget.comment.user.username != null && widget.comment.user.username!.isNotEmpty)
                            ? widget.comment.user.username!
                            : widget.comment.user.name;
                        final targetUsername = rawUsername.trim().replaceAll('@', '').replaceAll(' ', '_');
                        if (widget.onReplyToComment != null) {
                          widget.onReplyToComment!(targetUsername, widget.comment.id);
                        } else {
                          widget.onReplyClick?.call(targetUsername);
                        }
                      },
                      onOptions: () => CommentOptionsSheet.show(
                        context: context,
                        comment: widget.comment,
                        parentCommentId: widget.comment.id,
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
          ),

          // Replies (Clean Instagram / Threads Minimalist Indented Layout with Progressive Paging)
          if (hasReplies)
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topLeft,
              child: !_isRepliesExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(left: 46.0, top: 6.0),
                      child: CommentRepliesExpandRow(
                        replies: widget.comment.replies,
                        isExpanded: false,
                        onToggle: () {
                          setState(() {
                            _isRepliesExpanded = true;
                            _visibleRepliesCount = 3;
                          });
                        },
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(left: 46.0, top: 10.0),
                      child: Builder(
                        builder: (context) {
                          final totalReplies = widget.comment.replies.length;
                          final displayCount = _visibleRepliesCount.clamp(0, totalReplies);
                          final visibleReplies = widget.comment.replies.take(displayCount).toList();
                          final remainingCount = totalReplies - displayCount;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: visibleReplies.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12.0),
                                itemBuilder: (context, idx) {
                                  final reply = visibleReplies[idx];
                                  return CommentReplyTile(
                                    reply: reply,
                                    parentCommentId: widget.comment.id,
                                    isFirst: idx == 0,
                                    isLast: idx == visibleReplies.length - 1,
                                    onLikeToggle: _handleReplyLikeToggle,
                                    onReplyToComment: widget.onReplyToComment,
                                    onReplyClick: widget.onReplyClick,
                                    onUserClick: widget.onUserClick,
                                    onImageClick: widget.onImageClick,
                                    onShare: _copyToClipboard,
                                    postAuthorId: widget.postAuthorId,
                                    onDeleteComment: widget.onDeleteComment,
                                  );
                                },
                              ),
                              const SizedBox(height: 8.0),
                              // Load more chunk button (if there are remaining replies)
                              if (remainingCount > 0) ...[
                                CommentRepliesExpandRow(
                                  replies: widget.comment.replies,
                                  isExpanded: true,
                                  remainingCount: remainingCount,
                                  onToggle: () {
                                    setState(() {
                                      _visibleRepliesCount += 5;
                                    });
                                  },
                                ),
                                const SizedBox(height: 6.0),
                              ],
                              // Collapse button to hide all replies
                              CommentRepliesExpandRow(
                                replies: widget.comment.replies,
                                isExpanded: true,
                                remainingCount: 0,
                                onToggle: () {
                                  setState(() {
                                    _isRepliesExpanded = false;
                                    _visibleRepliesCount = 3;
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    final rawUsername = (widget.comment.user.username != null && widget.comment.user.username!.isNotEmpty)
        ? widget.comment.user.username!
        : widget.comment.user.name;
    final cleanUsername = rawUsername.trim().replaceAll('@', '');
    final displayAuthor = '@$cleanUsername';

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
                      fontSize: 13.5,
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
                  size: 13.5,
                  color: AppColors.verifiedBlue,
                ),
              ],
              if (widget.comment.user.isAuthor) ...[
                const SizedBox(width: 5.0),
                const CommentAuthorBadge(),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8.0),
        // Timestamp
        Text(
          formatSmartTimestamp(widget.comment.timestamp),
          style: const TextStyle(
            fontFamily: 'SFPro',
            fontSize: 12.0,
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
              comment: widget.comment,
              parentCommentId: widget.comment.id,
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
              size: 16.0,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentText() {
    const baseStyle = TextStyle(
      fontFamily: 'SFPro',
      fontFamilyFallback: ['AppleColorEmoji'],
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: Color(0xFF0F172A),
      height: 1.35,
      letterSpacing: -0.1,
    );

    final isLong = widget.comment.content.length > 90 || widget.comment.content.contains('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: baseStyle,
            children: MentionTextSpanHelper.buildSpans(
              context: context,
              text: widget.comment.content,
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
              HapticFeedback.selectionClick();
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
