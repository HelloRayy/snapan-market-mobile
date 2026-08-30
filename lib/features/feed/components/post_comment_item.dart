import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/utils/formatters.dart';
import 'package:snapan_market/features/feed/components/market_feed_icons.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// PostCommentItem Widget
/// 100% Sliced 1:1 from Web React PostCommentItem.tsx
///
/// Features:
/// - Author avatar (36x36px rounded circle with fallback)
/// - Header: Username, Verified Check, Crown Author Badge (`👑 Pembuat Utas`), Timestamp, 3-dots options
/// - Content text with thread continuation badge (e.g. `2/2`)
/// - Attached images preview (single / multi carousel)
/// - Action Bar (Like with tactile bounce & counter, Reply button, Share)
/// - Vertical Thread Branch Line connecting parent comment to child replies
/// - Nested replies list rendering
class PostCommentItem extends StatefulWidget {
  final PostCommentModel comment;
  final ValueChanged<String>? onReplyClick;
  final ValueChanged<PostCommentModel>? onLikeToggle;
  final ValueChanged<String>? onUserClick;
  final void Function(List<String> images, int index)? onImageClick;
  final bool isNested;

  const PostCommentItem({
    super.key,
    required this.comment,
    this.onReplyClick,
    this.onLikeToggle,
    this.onUserClick,
    this.onImageClick,
    this.isNested = false,
  });

  @override
  State<PostCommentItem> createState() => _PostCommentItemState();
}

class _PostCommentItemState extends State<PostCommentItem>
    with SingleTickerProviderStateMixin {
  late bool _isLiked;
  late int _likesCount;
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

  void _showCommentOptionsMenu(BuildContext context) {
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
                  widget.onReplyClick?.call(widget.comment.user.username ?? widget.comment.user.name);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_rounded, color: Color(0xFF334155)),
                title: const Text('Salin Teks Komentar', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                onTap: () {
                  Navigator.pop(ctx);
                  Clipboard.setData(ClipboardData(text: widget.comment.content));
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

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isNested ? 0.0 : 14.0,
        vertical: widget.isNested ? 6.0 : 12.0,
      ),
      decoration: BoxDecoration(
        border: widget.isNested
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9), width: 0.5),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Avatar + Continuous Branch Line if replies exist
          Column(
            children: [
              _buildAvatar(
                avatarUrl: widget.comment.user.avatar,
                name: widget.comment.user.name,
                username: widget.comment.user.username,
                size: widget.isNested ? 30.0 : 36.0,
              ),
              if (hasReplies && !widget.isNested)
                Container(
                  width: 1.5,
                  height: 40.0,
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(1.0),
                  ),
                ),
            ],
          ),


          SizedBox(width: widget.isNested ? 10.0 : 12.0),

          // Right Column: Header, Content, Images, Action Bar, and Nested Replies
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Line
                _buildHeaderRow(context),

                const SizedBox(height: 3.0),

                // Comment Content Text
                _buildContentText(),

                // Attached Images (if any)
                if (widget.comment.images.isNotEmpty) ...[
                  const SizedBox(height: 8.0),
                  _buildImagesSection(context),
                ],

                const SizedBox(height: 4.0),

                // Action Bar (Like + Reply + Share)
                _buildActionBar(context),

                // Nested Replies (if any)
                if (hasReplies) ...[
                  const SizedBox(height: 4.0),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.comment.replies.length,
                    itemBuilder: (context, idx) {
                      final reply = widget.comment.replies[idx];
                      return PostCommentItem(
                        key: ValueKey(reply.id),
                        comment: reply,
                        isNested: true,
                        onReplyClick: widget.onReplyClick,
                        onUserClick: widget.onUserClick,
                        onImageClick: widget.onImageClick,
                      );
                    },
                  ),
                ],
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

  Widget _buildHeaderRow(BuildContext context) {
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
                    widget.onUserClick?.call(
                      widget.comment.user.username ?? widget.comment.user.name,
                    );
                  },
                  child: Text(
                    widget.comment.user.username ?? widget.comment.user.name,
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
                  size: 14.0,
                  color: AppColors.primary,
                ),
              ],
              if (widget.comment.user.isAuthor) ...[
                const SizedBox(width: 6.0),
                _buildAuthorBadge(),
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
        GestureDetector(
          onTap: () => _showCommentOptionsMenu(context),
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


  Widget _buildImagesSection(BuildContext context) {
    if (widget.comment.images.length == 1) {
      return GestureDetector(
        onTap: () => widget.onImageClick?.call(widget.comment.images, 0),
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
                widget.comment.images.first,
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
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.comment.images.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8.0),
        itemBuilder: (context, idx) {
          final imgUrl = widget.comment.images[idx];
          return GestureDetector(
            onTap: () => widget.onImageClick?.call(widget.comment.images, idx),
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
          );
        },
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Row(
      children: [
        // Like Button with custom FeedHeartIcon
        GestureDetector(
          onTap: _handleLikeToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _likeScaleAnim,
                  child: FeedHeartIcon(
                    isLiked: _isLiked,
                    size: 16.5,
                    activeColor: const Color(0xFFF43F5E),
                    inactiveColor: const Color(0xFF64748B),
                    strokeWidth: 1.8,
                  ),
                ),
                if (_likesCount > 0) ...[
                  const SizedBox(width: 4.5),
                  Text(
                    '$_likesCount',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: _isLiked ? FontWeight.w700 : FontWeight.w500,
                      color: _isLiked ? const Color(0xFFF43F5E) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(width: 16.0),

        // Reply Button with custom FeedCommentIcon
        GestureDetector(
          onTap: () {
            widget.onReplyClick?.call(
              widget.comment.user.username ?? widget.comment.user.name,
            );
          },
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FeedCommentIcon(
                  size: 15.5,
                  color: Color(0xFF64748B),
                  strokeWidth: 1.8,
                ),
                SizedBox(width: 4.5),
                Text(
                  'Balas',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 16.0),

        // Share Button with custom FeedShareIcon
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Clipboard.setData(ClipboardData(text: widget.comment.content));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Teks komentar disalin'),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: FeedShareIcon(
              size: 15.5,
              color: Color(0xFF64748B),
              strokeWidth: 1.8,
            ),
          ),
        ),
      ],
    );
  }
}
