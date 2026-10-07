import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snapan_market/features/feed/components/post_card/market_post_card.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';
import 'package:snapan_market/features/search/components/suggested_account_tile.dart';
import 'package:snapan_market/features/search/models/search_models.dart';

/// Renders search results (typing suggestions, accounts list, posts feed, or empty state).
class SearchResultsView extends StatelessWidget {
  final bool isSubmitted;
  final String searchQuery;
  final SearchResultsTab activeTab;
  final List<MarketPost> matchingPosts;
  final List<SuggestedAccount> matchingAccounts;
  final VoidCallback onExecuteSearch;
  final void Function(String username, [SuggestedAccount? account]) onNavigateToProfile;
  final ValueChanged<MarketPost> onNavigateToPostDetail;
  final ValueChanged<String> onToggleFollow;
  final ValueChanged<MarketPost>? onLikeToggle;
  final ValueChanged<MarketPost>? onBookmarkToggle;
  final ValueChanged<MarketPost>? onRepostToggle;
  final void Function(MarketPost item, List<String> optionIds)? onVotePoll;

  const SearchResultsView({
    super.key,
    required this.isSubmitted,
    required this.searchQuery,
    required this.activeTab,
    required this.matchingPosts,
    required this.matchingAccounts,
    required this.onExecuteSearch,
    required this.onNavigateToProfile,
    required this.onNavigateToPostDetail,
    required this.onToggleFollow,
    this.onLikeToggle,
    this.onBookmarkToggle,
    this.onRepostToggle,
    this.onVotePoll,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSubmitted) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        children: [
          InkWell(
            onTap: onExecuteSearch,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.search, size: 18.0, color: Color(0xFF64748B)),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      searchQuery,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(CupertinoIcons.chevron_forward, size: 16.0, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 1.0, thickness: 0.8),
          if (matchingAccounts.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                "Profil Terkait",
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: matchingAccounts.take(3).length,
              separatorBuilder: (_, __) => const Divider(
                color: Color(0xFFF1F5F9),
                height: 1.0,
                thickness: 0.8,
              ),
              itemBuilder: (_, idx) {
                final acc = matchingAccounts[idx];
                return SuggestedAccountTile(
                  account: acc,
                  onTap: () => onNavigateToProfile(acc.username, acc),
                  onFollowTap: () => onToggleFollow(acc.id),
                );
              },
            ),
          ],
        ],
      );
    }

    if (activeTab == SearchResultsTab.profiles) {
      if (matchingAccounts.isEmpty) {
        return _buildEmptyState("Tidak ada profil ditemukan untuk \"$searchQuery\"");
      }
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: matchingAccounts.length,
        separatorBuilder: (_, __) => const Divider(color: Color(0xFFF1F5F9), height: 1.0, thickness: 0.5),
        itemBuilder: (_, idx) {
          final acc = matchingAccounts[idx];
          return SuggestedAccountTile(
            account: acc,
            onTap: () => onNavigateToProfile(acc.username, acc),
            onFollowTap: () => onToggleFollow(acc.id),
          );
        },
      );
    }

    if (matchingPosts.isEmpty) {
      return _buildEmptyState("Tidak ada postingan ditemukan untuk \"$searchQuery\"");
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: matchingPosts.length,
      itemBuilder: (_, idx) {
        final post = matchingPosts[idx];
        return MarketPostCard(
          item: post,
          onPostClick: (_) => onNavigateToPostDetail(post),
          onUserClick: (_) => onNavigateToProfile(post.sellerUsername),
          onLikeToggle: onLikeToggle != null ? (_) => onLikeToggle!(post) : null,
          onRepostToggle: onRepostToggle != null ? (_) => onRepostToggle!(post) : null,
          onVotePoll: onVotePoll,
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56.0,
              height: 56.0,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.search, size: 28.0, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 14.0),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
