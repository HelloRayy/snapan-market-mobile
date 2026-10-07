import 'package:flutter/material.dart';
import 'package:snapan_market/core/components/snaps_skeleton.dart';
import 'package:snapan_market/core/navigation/app_slide_page_route.dart';
import 'package:snapan_market/core/utils/snaps_toast.dart';
import 'package:snapan_market/features/feed/components/navigation/home_menu_popover.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';
import 'package:snapan_market/features/feed/screens/post_detail_screen.dart';
import 'package:snapan_market/features/profile/models/profile_user_model.dart';
import 'package:snapan_market/features/profile/screens/profile_screen.dart';
import 'package:snapan_market/features/search/components/search_bar_header.dart';
import 'package:snapan_market/features/search/components/search_results_view.dart';
import 'package:snapan_market/features/search/components/search_suggested_accounts_view.dart';
import 'package:snapan_market/features/search/controllers/search_controller.dart';
import 'package:snapan_market/features/search/models/search_models.dart';

/// Halaman Pencarian & Saran Akun Siswa SMKN 8 Semarang (<200 lines).
class SearchScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const SearchScreen({super.key, this.onBack});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _textController = TextEditingController();
  final AppSearchController _controller = AppSearchController();

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  @override
  void dispose() {
    HomeMenuPopover.dismiss();
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleClearSearch() {
    _textController.clear();
    _controller.handleClearSearch();
    FocusScope.of(context).unfocus();
  }

  void _navigateToProfile(String username, [SuggestedAccount? account]) {
    ProfileUserModel? initialUser;
    if (account != null) {
      initialUser = ProfileUserModel(
        id: account.id,
        name: account.fullName.isNotEmpty ? account.fullName : account.username,
        username: account.username,
        avatar: account.avatar,
        bio: account.bio,
        classGroup: 'Siswa SMKN 8 Semarang',
        tags: const [],
        followersCount: 0,
        soldCount: 0,
        rating: 0.0,
        isVerified: account.isVerified,
      );
    }

    Navigator.of(context).push(
      AppSlidePageRoute(
        builder: (_) => ProfileScreen(
          username: username,
          initialUser: initialUser,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _navigateToPostDetail(MarketPost post) async {
    final result = await Navigator.of(context).push(
      AppSlidePageRoute(
        builder: (_) => PostDetailScreen(
          post: post,
          onLikeToggle: _controller.toggleLike,
          onBookmarkToggle: _controller.toggleBookmark,
          onDeletePost: (del) => _controller.removePost(del.id),
        ),
      ),
    );
    if (result is Map && result['updatedPost'] is MarketPostModel && mounted) {
      _controller.updatePost(result['updatedPost'] as MarketPostModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final hasQuery = _controller.searchQuery.trim().isNotEmpty;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              SearchBarHeader(
                controller: _textController,
                onChanged: _controller.handleQueryChange,
                onSubmitted: () {
                  FocusScope.of(context).unfocus();
                  _controller.handleExecuteSearch();
                },
                onClear: _handleClearSearch,
                onBack: widget.onBack ?? () => Navigator.of(context).pop(),
                onMenuTap: () => HomeMenuPopover.toggle(context: context),
                onOpenAppTap: () {
                  SnapsToast.show(
                    context,
                    'Snapan Market v0.1.0',
                    hasBottomNav: false,
                    duration: const Duration(seconds: 1),
                  );
                },
                hasQuery: hasQuery,
                isSubmitted: _controller.isSubmitted,
                activeTab: _controller.activeTab,
                onTabChanged: _controller.setActiveTab,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  behavior: HitTestBehavior.translucent,
                  child: hasQuery && _controller.isSearching
                      ? const SingleChildScrollView(child: SearchResultSkeleton())
                      : !hasQuery
                          ? SearchSuggestedAccountsView(
                              accounts: _controller.accounts,
                              isLoadingInitial: _controller.isLoadingInitial,
                              onNavigateToProfile: (username, acc) => _navigateToProfile(username, acc),
                              onToggleFollow: _controller.toggleFollow,
                            )
                          : SearchResultsView(
                              isSubmitted: _controller.isSubmitted,
                              searchQuery: _controller.searchQuery,
                              activeTab: _controller.activeTab,
                              matchingPosts: _controller.liveMatchingPosts,
                              matchingAccounts: _controller.liveMatchingAccounts,
                              onExecuteSearch: _controller.handleExecuteSearch,
                              onNavigateToProfile: _navigateToProfile,
                              onNavigateToPostDetail: _navigateToPostDetail,
                              onToggleFollow: _controller.toggleFollow,
                              onLikeToggle: _controller.toggleLike,
                              onBookmarkToggle: _controller.toggleBookmark,
                              onVotePoll: _controller.votePoll,
                            ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
