import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/features/feed/components/market_feed_icons.dart';

/// 4-Icon Action Bar: Heart (Like), Comment (Reply), Repost, Share
/// Sliced 1:1 with Threads Web interaction flow
class CommentActionBar extends StatefulWidget {
  final bool isLiked;
  final int likesCount;
  final VoidCallback onLikeToggle;
  final VoidCallback onReply;
  final VoidCallback? onRepost;
  final VoidCallback? onShare;

  const CommentActionBar({
    super.key,
    required this.isLiked,
    required this.likesCount,
    required this.onLikeToggle,
    required this.onReply,
    this.onRepost,
    this.onShare,
  });

  @override
  State<CommentActionBar> createState() => _CommentActionBarState();
}

class _CommentActionBarState extends State<CommentActionBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimController;
  late Animation<double> _likeScaleAnim;

  @override
  void initState() {
    super.initState();
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
  void didUpdateWidget(covariant CommentActionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isLiked && widget.isLiked) {
      _likeAnimController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _likeAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. Heart (Like) Slot
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _likeAnimController.forward(from: 0.0);
            widget.onLikeToggle();
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _likeScaleAnim,
                  child: FeedHeartIcon(
                    isLiked: widget.isLiked,
                    size: 17.5,
                    activeColor: const Color(0xFFF43F5E),
                    inactiveColor: const Color(0xFF334155),
                    strokeWidth: 1.8,
                  ),
                ),
                if (widget.likesCount > 0) ...[
                  const SizedBox(width: 5.0),
                  Text(
                    '${widget.likesCount}',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: widget.isLiked ? FontWeight.w700 : FontWeight.w500,
                      color: widget.isLiked
                          ? const Color(0xFFF43F5E)
                          : const Color(0xFF64748B),
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
            widget.onReply();
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
            if (widget.onRepost != null) {
              widget.onRepost!();
            } else {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Komentar dipost ulang'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
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
            widget.onShare?.call();
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
