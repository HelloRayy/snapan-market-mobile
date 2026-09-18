import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/utils/formatters.dart';
import 'package:snapan_market/features/feed/components/comment/comment_replies_expand_row.dart';
import 'package:snapan_market/features/feed/components/comment/thread_branch_painter.dart';
import 'package:snapan_market/features/feed/components/market_feed_icons.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// PostCommentItem Widget
/// 100% Sliced 1:1 from Web React PostCommentItem.tsx and Threads conversation tree
///
/// Features:
/// - Author avatar (36x36px rounded circle with fallback)
/// - Header: Username, Verified Check, Crown Author Badge (`👑 Pembuat Utas`), Timestamp, 3-dots options
/// - Content text with thread continuation badge (e.g. `2/2`)
/// - Attached images preview (single / multi carousel)
/// - 4-Item Action Bar (Heart/Like, Comment/Reply, Repost, Share) matching Threads Web
/// - Continuous parent-to-child vertical threadline (#D1D5DB, 1.8px)
/// - Mathematical curved elbow branch line (`╰─`) touching child avatar with 0px gap
/// - Multi-reply trunk connection (intermediate and terminal replies)
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

class _PostCommentItemState extends State<PostCommentItem>
    with SingleTickerProviderStateMixin {
  late bool _isLiked;
  late int _likesCount;
  bool _isRepliesExpanded = true;
  late AnimationController _likeAnimController;
  late Animation<double> _likeScaleAnim;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.comment.isLiked;
    _likesCount = widget.comment.likesCount;

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
    // Automatically expand replies threadline when a new reply is added!
    if (widget.comment.replies.length > oldWidget.comment.replies.length) {
      _isRepliesExpanded = true;
    }
  }

  @override
  void dispose() {
    _likeAnimController.dispose();
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

    final updated = widget.comment.copyWith(
      isLiked: _isLiked,
      likesCount: _likesCount,
    );
    widget.onLikeToggle?.call(updated);
  }

  void _handleReplyLikeToggle(PostCommentModel reply) {
    HapticFeedback.lightImpact();
    final isLiked = !reply.isLiked;
    final count = isLiked ? reply.likesCount + 1 : (reply.likesCount - 1).clamp(0, 999999);
    final updatedReply = reply.copyWith(isLiked: isLiked, likesCount: count);

    final updatedReplies = widget.comment.replies.map((r) {
      return r.id == reply.id ? updatedReply : r;
    }).toList();

    widget.onLikeToggle?.call(widget.comment.copyWith(replies: updatedReplies));
  }

  void _showCommentOptionsMenu(BuildContext context, {PostCommentModel? comment}) {
    final target = comment ?? widget.comment;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.0,
                height: 4.0,
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.reply_rounded, color: Color(0xFF334155)),
                title: const Text('Balas Komentar', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                onTap: () {
                  Navigator.pop(ctx);
                  final targetUsername = target.user.username ?? target.user.name;
                  final targetId = widget.comment.id;
                  if (widget.onReplyToComment != null) {
                    widget.onReplyToComment!(targetUsername, targetId);
                  } else {
                    widget.onReplyClick?.call(targetUsername);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_rounded, color: Color(0xFF334155)),
                title: const Text('Salin Teks Komentar', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                onTap: () {
                  Navigator.pop(ctx);
                  Clipboard.setData(ClipboardData(text: target.content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Teks komentar disalin ke papan klip')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.report_outlined, color: Color(0xFFEF4444)),
                title: const Text('Laporkan Komentar', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Laporan terkirim, terima kasih atas masukan Anda')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasReplies = widget.comment.replies.isNotEmpty;

    // 1. NESTED CHILD REPLY VARIANT (Standalone invocation)
    if (widget.isNested) {
      return _buildChildReplyItem(
        context: context,
        reply: widget.comment,
        isFirst: true,
        isLast: widget.isLastNested,
        index: 0,
      );
    }

    // 2. MAIN TOP-LEVEL COMMENT VARIANT WITH THREADLINE TRUNK
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
                      _buildAvatar(
                        avatarUrl: widget.comment.user.avatar,
                        name: widget.comment.user.name,
                        username: widget.comment.user.username,
                        size: 36.0,
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
                        _buildImagesSection(context),
                      ],
                      const SizedBox(height: 4.0),
                      _buildActionBar(context),
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
                      _buildChildReplyItem(
                        context: context,
                        reply: reply,
                        isFirst: isFirst,
                        isLast: isLast,
                        index: idx,
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

  /// Child Reply Item with exact Threads L-branch curve entering child avatar
  Widget _buildChildReplyItem({
    required BuildContext context,
    required PostCommentModel reply,
    required bool isFirst,
    required bool isLast,
    required int index,
  }) {
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
                  child: _buildAvatar(
                    avatarUrl: reply.user.avatar,
                    name: reply.user.name,
                    username: reply.user.username,
                    size: 36.0,
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
                _buildHeaderRow(context, reply: reply),
                const SizedBox(height: 3.0),
                _buildContentText(reply: reply),
                if (reply.images.isNotEmpty) ...[
                  const SizedBox(height: 8.0),
                  _buildImagesSection(context, reply: reply),
                ],
                const SizedBox(height: 4.0),
                _buildActionBar(context, reply: reply),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar({
    required String avatarUrl,
    required String name,
    String? username,
    required double size,
  }) {
    return GestureDetector(
      onTap: () {
        widget.onUserClick?.call(username ?? name);
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 4.0,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.network(
            avatarUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: AppColors.primaryPastel,
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: TextStyle(
                    fontSize: size * 0.4,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(
    BuildContext context, {
    PostCommentModel? reply,
  }) {
    final targetComment = reply ?? widget.comment;
    final username = targetComment.user.username ?? targetComment.user.name;

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
              if (targetComment.user.isVerified) ...[
                const SizedBox(width: 4.0),
                const Icon(
                  Icons.verified_rounded,
                  size: 14.5,
                  color: AppColors.primary,
                ),
              ],
              if (targetComment.user.isAuthor) ...[
                const SizedBox(width: 6.0),
                _buildAuthorBadge(),
              ],
              const SizedBox(width: 6.0),
              Text(
                formatSmartTimestamp(targetComment.timestamp),
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
        GestureDetector(
          onTap: () => _showCommentOptionsMenu(context, comment: targetComment),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 28.0,
            height: 28.0,
            alignment: Alignment.center,
            child: const Icon(
              Icons.more_horiz_rounded,
              size: 16.0,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
      ],
    );
  }

  /// Crown Badge `👑 Pembuat Utas` for post author (1:1 Web React amber crown styling)
  Widget _buildAuthorBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFFFDE68A), width: 0.8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            size: 11.0,
            color: Color(0xFFD97706),
          ),
          SizedBox(width: 3.0),
          Text(
            'Pembuat Utas',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB45309),
              letterSpacing: -0.2,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentText({PostCommentModel? reply}) {
    final targetComment = reply ?? widget.comment;

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
          TextSpan(text: targetComment.content),
          if (targetComment.threadPart != null &&
              targetComment.totalParts != null)
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
                  '${targetComment.threadPart}/${targetComment.totalParts}',
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

  Widget _buildImagesSection(
    BuildContext context, {
    PostCommentModel? reply,
  }) {
    final targetComment = reply ?? widget.comment;

    if (targetComment.images.length == 1) {
      return GestureDetector(
        onTap: () => widget.onImageClick?.call(targetComment.images, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.0),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 220.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: const Color(0x14000000), width: 1.0),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.network(
                targetComment.images.first,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFFF1F5F9),
                  child: const Center(
                    child: Icon(Icons.image_outlined, color: Color(0xFF94A3B8), size: 32.0),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 140.0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(targetComment.images.length, (idx) {
            final imgUrl = targetComment.images[idx];
            final isLast = idx == targetComment.images.length - 1;
            return Padding(
              padding: EdgeInsets.only(right: isLast ? 0.0 : 8.0),
              child: GestureDetector(
                onTap: () => widget.onImageClick?.call(targetComment.images, idx),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.0),
                  child: Container(
                    width: 180.0,
                    height: 140.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(color: const Color(0x14000000), width: 1.0),
                    ),
                    child: Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// 4-Icon Action Bar: Heart, Comment, Repost, Share (1:1 with Threads Web)
  Widget _buildActionBar(
    BuildContext context, {
    PostCommentModel? reply,
  }) {
    final targetComment = reply ?? widget.comment;
    final isReplyItem = reply != null;
    final isLiked = isReplyItem ? targetComment.isLiked : _isLiked;
    final likesCount = isReplyItem ? targetComment.likesCount : _likesCount;

    return Row(
      children: [
        // 1. Heart (Like) Slot
        GestureDetector(
          onTap: () {
            if (isReplyItem) {
              _handleReplyLikeToggle(targetComment);
            } else {
              _handleLikeToggle();
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: isReplyItem ? const AlwaysStoppedAnimation(1.0) : _likeScaleAnim,
                  child: FeedHeartIcon(
                    isLiked: isLiked,
                    size: 17.5,
                    activeColor: const Color(0xFFF43F5E),
                    inactiveColor: const Color(0xFF334155),
                    strokeWidth: 1.8,
                  ),
                ),
                if (likesCount > 0) ...[
                  const SizedBox(width: 5.0),
                  Text(
                    '$likesCount',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: isLiked ? FontWeight.w700 : FontWeight.w500,
                      color: isLiked ? const Color(0xFFF43F5E) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(width: 14.0),

        // 2. Balas (Comment/Reply) Slot
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            final targetUsername = targetComment.user.username ?? targetComment.user.name;
            final targetId = widget.comment.id;
            if (widget.onReplyToComment != null) {
              widget.onReplyToComment!(targetUsername, targetId);
            } else {
              widget.onReplyClick?.call(targetUsername);
            }
          },
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
            child: FeedCommentIcon(
              size: 17.5,
              color: Color(0xFF334155),
              strokeWidth: 1.8,
            ),
          ),
        ),

        const SizedBox(width: 14.0),

        // 3. Posting Ulang (Repost) Slot
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Komentar dipost ulang'),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
            child: FeedRepostIcon(
              isReposted: false,
              size: 17.5,
              inactiveColor: Color(0xFF334155),
              strokeWidth: 1.8,
            ),
          ),
        ),

        const SizedBox(width: 14.0),

        // 4. Bagikan (Share) Slot
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Clipboard.setData(ClipboardData(text: targetComment.content));
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Teks komentar disalin ke papan klip'),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
            child: FeedShareIcon(
              size: 17.5,
              color: Color(0xFF334155),
              strokeWidth: 1.8,
            ),
          ),
        ),
      ],
    );
  }
}
