import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';
import 'package:snapan_market/features/profile/models/profile_user_model.dart';

/// Reply Thread Card for "Balasan" Tab matching ReplyThreadCard.tsx 1:1
/// Shows parent post connected to user's reply with a vertical branch spine line
class ProfileReplyThreadCard extends StatefulWidget {
  final ProfileReplyThreadModel thread;
  final ValueChanged<MarketPostModel>? onPostClick;
  final Function(List<String> images, int index)? onImageClick;

  const ProfileReplyThreadCard({
    super.key,
    required this.thread,
    this.onPostClick,
    this.onImageClick,
  });

  @override
  State<ProfileReplyThreadCard> createState() => _ProfileReplyThreadCardState();
}

class _ProfileReplyThreadCardState extends State<ProfileReplyThreadCard> {
  late bool _parentLiked;
  late int _parentLikesCount;
  late bool _replyLiked;
  late int _replyLikesCount;

  @override
  void initState() {
    super.initState();
    _parentLiked = widget.thread.parentPost.isLiked;
    _parentLikesCount = widget.thread.parentPost.likesCount;
    _replyLiked = widget.thread.reply.isLiked;
    _replyLikesCount = widget.thread.reply.likesCount;
  }

  void _toggleParentLike() {
    HapticFeedback.lightImpact();
    setState(() {
      _parentLiked = !_parentLiked;
      _parentLikesCount += _parentLiked ? 1 : -1;
    });
  }

  void _toggleReplyLike() {
    HapticFeedback.lightImpact();
    setState(() {
      _replyLiked = !_replyLiked;
      _replyLikesCount += _replyLiked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final parent = widget.thread.parentPost;
    final reply = widget.thread.reply;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Parent Post
          GestureDetector(
            onTap: () => widget.onPostClick?.call(parent),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Avatar + Vertical Thread Spine Line
                  Column(
                    children: [
                      _buildAvatar(parent.seller.avatar, parent.seller.name),
                      Container(
                        width: 2.0,
                        height: 36.0,
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        color: const Color(0xFFE2E8F0),
                      ),
                    ],
                  ),

                  const SizedBox(width: 10.0),

                  // Right: Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Header
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                parent.seller.name,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (parent.seller.isVerified) ...[
                              const SizedBox(width: 3.0),
                              const Icon(Icons.verified_rounded, size: 14.0, color: Color(0xFF1D64EC)),
                            ],
                            const SizedBox(width: 4.0),
                            Text(
                              '· ${parent.timestamp}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 3.0),

                        // Caption
                        Text(
                          parent.caption,
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Color(0xFF334155),
                            height: 1.35,
                            letterSpacing: -0.1,
                          ),
                        ),

                        // Parent Images if any
                        if (parent.images.isNotEmpty) ...[
                          const SizedBox(height: 8.0),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: GestureDetector(
                              onTap: () => widget.onImageClick?.call(parent.images, 0),
                              child: Image.network(
                                parent.images.first,
                                height: 140.0,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],

                        // Parent Actions
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: _toggleParentLike,
                                behavior: HitTestBehavior.opaque,
                                child: Row(
                                  children: [
                                    Icon(
                                      _parentLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                                      size: 16.0,
                                      color: _parentLiked ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      '$_parentLikesCount',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w600,
                                        color: _parentLiked ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Row(
                                children: [
                                  const Icon(Icons.chat_bubble_outline_rounded, size: 15.0, color: Color(0xFF94A3B8)),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    '${parent.commentsCount}',
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. User's Reply Item
          Padding(
            padding: const EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(reply.user.avatar, reply.user.name),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reply User Header
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              reply.user.name,
                              style: const TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (reply.user.isVerified) ...[
                            const SizedBox(width: 3.0),
                            const Icon(Icons.verified_rounded, size: 14.0, color: Color(0xFF1D64EC)),
                          ],
                          const SizedBox(width: 4.0),
                          Text(
                            '· ${reply.timestamp}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 3.0),

                      // Reply Content
                      Text(
                        reply.content,
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Color(0xFF0F172A),
                          height: 1.35,
                          letterSpacing: -0.1,
                        ),
                      ),

                      // Reply Actions
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _toggleReplyLike,
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                children: [
                                  Icon(
                                    _replyLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                                    size: 16.0,
                                    color: _replyLiked ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    '$_replyLikesCount',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w600,
                                      color: _replyLiked ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String avatarUrl, String name) {
    return Container(
      width: 36.0,
      height: 36.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: ClipOval(
        child: Image.network(
          avatarUrl,
          width: 36.0,
          height: 36.0,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: const Color(0xFFEEF0FF),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3D38F5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
