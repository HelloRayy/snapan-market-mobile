import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/utils/formatters.dart';
import 'package:snapan_market/features/feed/components/delete_post_bottom_sheet.dart';
import 'package:snapan_market/features/feed/components/market_feed_icons.dart';
import 'package:snapan_market/features/feed/components/post_card/post_author_avatar.dart';
import 'package:snapan_market/features/feed/components/post_submenu_popover.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Header row for Feed and Detail Card variants
class PostCardHeader extends StatelessWidget {
  final MarketPostModel item;
  final bool isDetail;
  final bool isFollowed;
  final VoidCallback onFollowToggle;
  final ValueChanged<String>? onUserClick;
  final ValueChanged<String>? onTopicClick;
  final VoidCallback? onMoreOptionsClick;
  final ValueChanged<MarketPostModel>? onPostClick;
  final ValueChanged<MarketPostModel>? onDeletePost;

  const PostCardHeader({
    super.key,
    required this.item,
    this.isDetail = false,
    required this.isFollowed,
    required this.onFollowToggle,
    this.onUserClick,
    this.onTopicClick,
    this.onMoreOptionsClick,
    this.onPostClick,
    this.onDeletePost,
  });

  void _showOptionsMenu(BuildContext context, [Offset? tapPosition]) async {
    if (onMoreOptionsClick != null) {
      onMoreOptionsClick!();
      return;
    }

    final currentUser = SupabaseService.instance.currentUser;
    final bool isOwner = currentUser != null && (currentUser.id == item.seller.id);
    final bool isAdmin = await SupabaseService.instance.isCurrentUserAdmin();

    if (!context.mounted) return;

    PostSubmenuPopover.show(
      context: context,
      post: item,
      isSaved: item.isSaved,
      isOwner: isOwner,
      isAdmin: isAdmin,
      position: tapPosition,
      onToggleSave: () {
        final updated = item.copyWith(isSaved: !item.isSaved);
        onPostClick?.call(updated);
      },
      onDeletePost: () async {
        final confirmed = await DeletePostBottomSheet.show(
          context,
          post: item,
          isAdmin: isAdmin && !isOwner,
        );
        if (confirmed == true && context.mounted) {
          onDeletePost?.call(item);
        }
      },
      onClosePoll: () {
        SupabaseService.instance.closePoll(item.id);
        if (item.poll != null) {
          final updated = item.copyWith(poll: item.poll!.copyWith(isClosed: true));
          onPostClick?.call(updated);
        }
      },
      onHidePost: () {},
      onMuteAuthor: () {},
      onReport: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Side: Author metadata
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isDetail) ...[
                PostAuthorAvatar(
                  seller: item.seller,
                  isFollowed: isFollowed,
                  onFollowToggle: onFollowToggle,
                  onUserClick: () => onUserClick?.call(item.seller.username ?? item.seller.name),
                ),
                const SizedBox(width: 10.0),
              ],

              // 1. Author Name
              GestureDetector(
                onTap: () => onUserClick?.call(item.seller.username ?? item.seller.name),
                child: Text(
                  item.seller.name,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
              ),

              // Verified Checkmark Badge
              if (item.seller.isVerified) ...[
                const SizedBox(width: 4.0),
                const Icon(
                  Icons.verified_rounded,
                  size: 15.0,
                  color: AppColors.verifiedBlue,
                ),
              ],

              // 2. Topic Tag or Class Group
              if (item.topicTag != null) ...[
                const SizedBox(width: 4.0),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 14.0,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 4.0),
                if (item.isOfficialTopic) ...[
                  if (item.topicIcon == 'presentation')
                    const PresentationTopicGlyph(size: 14.0)
                  else
                    const ThreadsTopicGlyph(size: 14.0),
                  const SizedBox(width: 4.0),
                ],
                Flexible(
                  child: GestureDetector(
                    onTap: () => onTopicClick?.call(item.topicTag!),
                    child: Text(
                      item.topicTag!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: item.isOfficialTopic
                            ? AppColors.primary
                            : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
              ] else if (item.seller.name.length <= 14 && item.seller.classGroup.isNotEmpty) ...[
                const SizedBox(width: 4.0),
                Flexible(
                  child: Text(
                    item.seller.classGroup,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: 6.0),

        // Right Side: Timestamp + 3-dots menu button (Perfect vertical center alignment)
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              formatSmartTimestamp(item.timestamp),
              style: const TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.normal,
                color: Color(0xFF64748B),
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 2.0),
            InkWell(
              onTapDown: (details) => _showOptionsMenu(context, details.globalPosition),
              borderRadius: BorderRadius.circular(16.0),
              splashColor: AppColors.mistGray,
              highlightColor: Colors.transparent,
              child: const SizedBox(
                width: 32.0,
                height: 28.0,
                child: Center(
                  child: Icon(
                    CupertinoIcons.ellipsis,
                    size: 19.0,
                    color: AppColors.ashGray,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
