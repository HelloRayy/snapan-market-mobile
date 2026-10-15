import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/ui/default_profile_avatar.dart';
import 'package:snapan_market/features/feed/components/post_card/market_feed_icons.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

class PostThreadChainItem extends StatelessWidget {
  final MarketPostModel post;
  final ThreadChainItemModel chain;
  final bool isLast;

  const PostThreadChainItem({
    super.key,
    required this.post,
    required this.chain,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spineColor = isDark ? const Color(0x26FFFFFF) : AppColors.cloudGray;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final badgeBgColor = isDark ? const Color(0xFF242626) : const Color(0xFFF1F5F9);
    final badgeTextColor = isDark ? AppColors.darkTextSecondary : AppColors.graphite;
    final iconColor = isDark ? AppColors.darkTextSecondary : AppColors.ashGray;
    final counterColor = isDark ? AppColors.darkTextSecondary : AppColors.graphite;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44.0,
            child: Column(
              children: [
                Container(
                  width: 2.0,
                  height: 10.0,
                  decoration: BoxDecoration(
                    color: spineColor,
                    borderRadius: BorderRadius.circular(1.0),
                  ),
                ),
                SizedBox(
                  width: 36.0,
                  height: 36.0,
                  child: AppAvatar(
                    avatarUrl: post.seller.avatar,
                    size: 36.0,
                  ),
                ),
                if (!isLast) ...[
                  const SizedBox(height: 6.0),
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 2.0,
                        decoration: BoxDecoration(
                          color: spineColor,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          post.seller.name,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: primaryTextColor,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (post.seller.isVerified) ...[
                          const SizedBox(width: 4.0),
                          const Icon(
                            Icons.verified_rounded,
                            size: 15.0,
                            color: AppColors.verifiedBlue,
                          ),
                        ],
                        const SizedBox(width: 6.0),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: badgeBgColor,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            '${chain.partNumber}/${chain.totalParts}',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: badgeTextColor,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      chain.timestamp,
                      style: TextStyle(
                        fontSize: 13.0,
                        color: secondaryTextColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  chain.caption,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.35,
                    color: primaryTextColor,
                  ),
                ),
                if (chain.images.isNotEmpty) ...[
                  const SizedBox(height: 8.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: chain.images.first.startsWith('assets/')
                        ? Image.asset(
                            chain.images.first,
                            height: 180.0,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            chain.images.first,
                            height: 180.0,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                ],
                const SizedBox(height: 6.0),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      FeedHeartIcon(
                        isLiked: chain.isLiked,
                        size: 17.0,
                        activeColor: const Color(0xFFF43F5E),
                        inactiveColor: iconColor,
                      ),
                      if (chain.likesCount > 0) ...[
                        const SizedBox(width: 4.0),
                        Text(
                          '${chain.likesCount}',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: counterColor,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                      const SizedBox(width: 14.0),
                      FeedCommentIcon(
                        size: 16.0,
                        color: iconColor,
                      ),
                      if (chain.commentsCount > 0) ...[
                        const SizedBox(width: 4.0),
                        Text(
                          '${chain.commentsCount}',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: counterColor,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                      const SizedBox(width: 14.0),
                      FeedRepostIcon(
                        isReposted: false,
                        size: 17.0,
                        inactiveColor: iconColor,
                      ),
                      const SizedBox(width: 14.0),
                      FeedShareIcon(
                        size: 16.0,
                        color: iconColor,
                      ),
                    ],
                  ),
                ),
                if (!isLast) const SizedBox(height: 8.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
