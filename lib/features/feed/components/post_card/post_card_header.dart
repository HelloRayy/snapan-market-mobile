import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snapan_market/core/components/mascot_flair_badge.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/utils/formatters.dart';
import 'package:snapan_market/features/feed/components/sheets/delete_post_bottom_sheet.dart';
import 'package:snapan_market/features/feed/components/post_card/market_feed_icons.dart';
import 'package:snapan_market/features/feed/components/post_card/post_author_avatar.dart';
import 'package:snapan_market/features/feed/components/post_card/post_submenu_popover.dart';
import 'package:snapan_market/features/feed/components/sheets/report_content_bottom_sheet.dart';
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
      onReport: () {
        ReportContentBottomSheet.show(context, post: item);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasDisplayName = item.seller.displayName != null && item.seller.displayName!.trim().isNotEmpty;
    final rawUsername = (item.seller.username != null && item.seller.username!.isNotEmpty)
        ? item.seller.username!
        : '';
    final cleanUsername = rawUsername.trim().replaceAll('@', '');
    final displayAuthor = hasDisplayName
        ? item.seller.displayName!.trim()
        : (cleanUsername.isNotEmpty ? '@$cleanUsername' : 'Pengguna');

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final mutedTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8);

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
                  onUserClick: () => onUserClick?.call(cleanUsername),
                ),
                const SizedBox(width: 10.0),
              ],

              // 1. Author Name (Standardized to @{username})
              Flexible(
                child: GestureDetector(
                  onTap: () => onUserClick?.call(cleanUsername),
                  child: Text(
                    displayAuthor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'SFPro',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: primaryTextColor,
                      letterSpacing: -0.2,
                    ),
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

              // Mascot Flair Badge (SNAPS-13)
              if (item.seller.mascotFlair != null) ...[
                const SizedBox(width: 4.0),
                MascotFlairBadge(
                  flair: item.seller.mascotFlair!,
                  size: 26.0,
                ),
              ],

              // 2. Topic Tag or Class Group
              if (item.topicTag != null) ...[
                const SizedBox(width: 4.0),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 14.0,
                  color: mutedTextColor,
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
                            : primaryTextColor,
                      ),
                    ),
                  ),
                ),
              ] else if (displayAuthor.length <= 16 && item.seller.classGroup.isNotEmpty) ...[
                const SizedBox(width: 4.0),
                Flexible(
                  child: Text(
                    item.seller.classGroup,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.normal,
                      color: mutedTextColor,
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
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.normal,
                color: secondaryTextColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 2.0),
            InkWell(
              onTapDown: (details) => _showOptionsMenu(context, details.globalPosition),
              borderRadius: BorderRadius.circular(16.0),
              splashColor: isDark ? const Color(0xFF242626) : AppColors.mistGray,
              highlightColor: Colors.transparent,
              child: SizedBox(
                width: 32.0,
                height: 28.0,
                child: Center(
                  child: Icon(
                    CupertinoIcons.ellipsis,
                    size: 19.0,
                    color: secondaryTextColor,
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
