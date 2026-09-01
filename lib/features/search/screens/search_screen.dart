import "package:flutter/material.dart";
import "package:snapan_market/core/theme/app_colors.dart";
import "package:snapan_market/features/feed/components/market_post_card.dart";
import "package:snapan_market/features/feed/models/market_post_model.dart";
import "package:snapan_market/features/feed/screens/post_detail_screen.dart";
import "package:snapan_market/features/profile/screens/profile_screen.dart";
import "package:snapan_market/features/search/components/search_bar_header.dart";
import "package:snapan_market/features/search/components/suggested_account_tile.dart";
import "package:snapan_market/features/search/models/search_models.dart";

class SearchScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const SearchScreen({super.key, this.onBack});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _isSubmitted = false;
  int _visibleSuggestedCount = 5;
  SearchResultsTab _activeTab = SearchResultsTab.top;

  late List<SuggestedAccount> _accounts;

  @override
  void initState() {
    super.initState();
    _accounts = List.from(kInitialSuggestedAccounts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleQueryChange(String val) {
    setState(() {
      _searchQuery = val;
      if (val.trim().isEmpty) {
        _isSubmitted = false;
      }
    });
  }

  void _handleExecuteSearch() {
    if (_searchQuery.trim().isNotEmpty) {
      setState(() {
        _isSubmitted = true;
      });
      FocusScope.of(context).unfocus();
    }
  }

  void _handleClearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = "";
      _isSubmitted = false;
    });
    FocusScope.of(context).unfocus();
  }

  void _toggleFollow(String id) {
    setState(() {
      _accounts = _accounts.map((acc) {
        if (acc.id == id) {
          return acc.copyWith(isFollowing: !acc.isFollowing);
        }
        return acc;
      }).toList();
    });
  }

  void _navigateToProfile(String username) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          username: username,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _navigateToPostDetail(MarketPost post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(
          post: post,
        ),
      ),
    );
  }

  // Filtered matching posts
  List<MarketPost> _getMatchingPosts() {
    if (_searchQuery.trim().isEmpty) return [];
    final q = _searchQuery.toLowerCase().trim();
    return mockMarketPosts.where((post) {
      final inTitle = post.title?.toLowerCase().contains(q) ?? false;
      final inDesc = post.description.toLowerCase().contains(q);
      final inSeller = post.sellerName.toLowerCase().contains(q);
      final inDept = post.department.toLowerCase().contains(q);
      final inCategory = post.category?.toLowerCase().contains(q) ?? false;
      return inTitle || inDesc || inSeller || inDept || inCategory;
    }).toList();
  }

  // Filtered matching accounts
  List<SuggestedAccount> _getMatchingAccounts() {
    if (_searchQuery.trim().isEmpty) return _accounts;
    final q = _searchQuery.toLowerCase().trim();
    return _accounts.where((acc) {
      return acc.username.toLowerCase().contains(q) ||
          acc.fullName.toLowerCase().contains(q) ||
          acc.bio.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _searchQuery.trim().isNotEmpty;
    final matchingPosts = _getMatchingPosts();
    final matchingAccounts = _getMatchingAccounts();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Sticky Top Search Header
          SearchBarHeader(
            controller: _searchController,
            onChanged: _handleQueryChange,
            onSubmitted: _handleExecuteSearch,
            onClear: _handleClearSearch,
            onBack: widget.onBack ?? () => Navigator.of(context).pop(),
            hasQuery: hasQuery,
            isSubmitted: _isSubmitted,
            activeTab: _activeTab,
            onTabChanged: (tab) => setState(() => _activeTab = tab),
          ),

          // Main Body
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.translucent,
              child: _buildBody(hasQuery, matchingPosts, matchingAccounts),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    bool hasQuery,
    List<MarketPost> matchingPosts,
    List<SuggestedAccount> matchingAccounts,
  ) {
    // 1. Idle State (No Query) -> Flat Suggested Accounts (No Tren Topik, No Container Card)
    if (!hasQuery) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        children: [
          // Section Heading: "Saran ikuti"
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Saran ikuti",
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  "Rekomendasi",
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          // Flat Suggested Accounts List
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _visibleSuggestedCount.clamp(0, _accounts.length),
            separatorBuilder: (_, __) => const Divider(
              color: Color(0xFFF1F5F9),
              height: 1.0,
              thickness: 1.0,
            ),
            itemBuilder: (_, idx) {
              final acc = _accounts[idx];
              return SuggestedAccountTile(
                account: acc,
                onTap: () => _navigateToProfile(acc.username),
                onFollowTap: () => _toggleFollow(acc.id),
              );
            },
          ),

          if (_visibleSuggestedCount < _accounts.length)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _visibleSuggestedCount = (_visibleSuggestedCount + 5).clamp(0, _accounts.length);
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: Text(
                      "Lihat saran lainnya (${_accounts.length - _visibleSuggestedCount})",
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D64EC),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    // 2. Typing State (Has Query but Not Submitted)
    if (!_isSubmitted) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        children: [
          // Instant search submit row
          InkWell(
            onTap: _handleExecuteSearch,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 18.0, color: Color(0xFF64748B)),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      _searchQuery,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 18.0, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 1.0, thickness: 0.8),

          // Matching Creators Preview
          if (matchingAccounts.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: const Text(
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
                  onTap: () => _navigateToProfile(acc.username),
                  onFollowTap: () => _toggleFollow(acc.id),
                );
              },
            ),
          ],
        ],
      );
    }

    // 3. Submitted Search Results (Tabs: Top, Latest, Profiles)
    if (_activeTab == SearchResultsTab.profiles) {
      if (matchingAccounts.isEmpty) {
        return _buildEmptyState("Tidak ada profil ditemukan untuk \"$_searchQuery\"");
      }
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: matchingAccounts.length,
        separatorBuilder: (_, __) => const Divider(color: Color(0xFFF1F5F9), height: 1.0, thickness: 0.5),
        itemBuilder: (_, idx) {
          final acc = matchingAccounts[idx];
          return SuggestedAccountTile(
            account: acc,
            onTap: () => _navigateToProfile(acc.username),
            onFollowTap: () => _toggleFollow(acc.id),
          );
        },
      );
    }

    // Posts Tabs (Top or Latest)
    if (matchingPosts.isEmpty) {
      return _buildEmptyState("Tidak ada postingan ditemukan untuk \"$_searchQuery\"");
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: matchingPosts.length,
      itemBuilder: (_, idx) {
        final post = matchingPosts[idx];
        return MarketPostCard(
          item: post,
          onPostClick: (_) => _navigateToPostDetail(post),
          onUserClick: (_) => _navigateToProfile(post.sellerUsername),
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
              child: const Icon(Icons.search_off_rounded, size: 28.0, color: Color(0xFF94A3B8)),
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
