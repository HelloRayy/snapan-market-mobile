import 'package:flutter/material.dart';
import 'package:snapan_market/core/components/snaps_skeleton.dart';
import 'package:snapan_market/features/feed/components/market_post_card.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';
import 'package:snapan_market/features/profile/components/profile_media_grid.dart';
import 'package:snapan_market/features/profile/components/profile_reply_thread_card.dart';
import 'package:snapan_market/features/profile/components/profile_tab_bar.dart';
import 'package:snapan_market/features/profile/models/profile_user_model.dart';

class ProfileContentTabs extends StatelessWidget {
  final ProfileTab activeTab;
  final bool isLoading;
  final List<MarketPostModel> displayPosts;
  final List<ProfileReplyThreadModel> displayReplies;
  final List<ProfileMediaItem> mediaItems;
  final String username;
  final ValueChanged<MarketPostModel> onPostClick;
  final ValueChanged<MarketPostModel> onLikeToggle;
  final ValueChanged<MarketPostModel>? onBookmarkToggle;
  final ValueChanged<MarketPostModel> onRepostToggle;
  final void Function(MarketPostModel, int) onImageClick;
  final void Function(MarketPostModel, List<String>)? onVotePoll;
  final ValueChanged<MarketPostModel> onDeletePost;
  final void Function(List<String>, int) onReplyImageClick;

  const ProfileContentTabs({
    super.key,
    required this.activeTab,
    required this.isLoading,
    required this.displayPosts,
    required this.displayReplies,
    required this.mediaItems,
    required this.username,
    required this.onPostClick,
    required this.onLikeToggle,
    this.onBookmarkToggle,
    required this.onRepostToggle,
    required this.onImageClick,
    this.onVotePoll,
    required this.onDeletePost,
    required this.onReplyImageClick,
  });

  @override
  Widget build(BuildContext context) {
    if (activeTab == ProfileTab.threads) {
      if (isLoading && displayPosts.isEmpty) {
        return const SliverToBoxAdapter(child: FeedTimelineSkeleton(itemCount: 3));
      }
      if (displayPosts.isNotEmpty) {
        return SliverList.builder(
          itemCount: displayPosts.length,
          itemBuilder: (context, index) {
            final post = displayPosts[index];
            return MarketPostCard(
              key: ValueKey(post.id),
              item: post,
              onPostClick: onPostClick,
              onLikeToggle: onLikeToggle,
              onRepostToggle: onRepostToggle,
              onImageClick: onImageClick,
              onVotePoll: onVotePoll,
              onDeletePost: onDeletePost,
            );
          },
        );
      }
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 64.0, horizontal: 24.0),
          alignment: Alignment.center,
          child: const Column(
            children: [
              Icon(Icons.inventory_2_outlined, size: 36.0, color: Color(0xFFCBD5E1)),
              SizedBox(height: 10.0),
              Text('Belum ada postingan', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              SizedBox(height: 4.0),
              Text('Postingan dan produk jualan akan muncul di sini.', style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    } else if (activeTab == ProfileTab.replies) {
      if (isLoading && displayReplies.isEmpty) {
        return const SliverToBoxAdapter(child: FeedTimelineSkeleton(itemCount: 2));
      }
      if (displayReplies.isNotEmpty) {
        return SliverList.builder(
          itemCount: displayReplies.length,
          itemBuilder: (context, index) {
            final replyThread = displayReplies[index];
            return ProfileReplyThreadCard(
              key: ValueKey(replyThread.id),
              thread: replyThread,
              onPostClick: onPostClick,
              onImageClick: onReplyImageClick,
            );
          },
        );
      }
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 64.0, horizontal: 24.0),
          alignment: Alignment.center,
          child: Column(
            children: [
              const Icon(Icons.chat_bubble_outline_rounded, size: 36.0, color: Color(0xFFCBD5E1)),
              const SizedBox(height: 10.0),
              const Text('Belum ada balasan', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              const SizedBox(height: 4.0),
              Text('@$username belum membalas utas apa pun.', style: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    } else {
      return SliverToBoxAdapter(
        child: ProfileMediaGrid(
          mediaItems: mediaItems,
          onMediaTap: onPostClick,
        ),
      );
    }
  }
}
