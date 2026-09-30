import 'package:flutter/material.dart';
import 'package:snapan_market/core/components/snaps_skeleton.dart';
import 'package:snapan_market/core/navigation/app_slide_page_route.dart';
import 'package:snapan_market/core/services/follow_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/features/feed/components/home_menu_popover.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';
import 'package:snapan_market/features/feed/screens/post_detail_screen.dart';
import 'package:snapan_market/features/profile/models/profile_user_model.dart';
import 'package:snapan_market/features/profile/screens/profile_screen.dart';
import 'package:snapan_market/features/search/components/search_bar_header.dart';
import 'package:snapan_market/features/search/components/search_results_view.dart';
import 'package:snapan_market/features/search/components/search_suggested_accounts_view.dart';
import 'package:snapan_market/features/search/models/search_models.dart';

/// Halaman Pencarian & Saran Akun Siswa SMKN 8 Semarang
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
  bool _isSearching = false;
  bool _isLoadingInitial = true;
  SearchResultsTab _activeTab = SearchResultsTab.top;

  late List<SuggestedAccount> _accounts;
  List<MarketPost> _liveMatchingPosts = [];
  List<SuggestedAccount> _liveMatchingAccounts = [];

  @override
  void initState() {
    super.initState();
    _accounts = [];
    _loadLiveSuggestedAccounts();
  }

  Future<void> _loadLiveSuggestedAccounts() async {
    try {
      final records = await SupabaseService.instance.fetchSuggestedProfiles(limit: 15);
      if (records.isNotEmpty && mounted) {
        setState(() {
          _accounts = records.map<SuggestedAccount>((p) {
            final classGroup = p['class_group'] as String? ?? 'Siswa SMKN 8 Semarang';
            return SuggestedAccount(
              id: p['id'] as String? ?? '',
              fullName: p['full_name'] as String? ?? 'Siswa Snapan',
              username: p['username'] as String? ?? 'siswa',
              avatar: (p['avatar_url'] as String?)?.isNotEmpty == true
                  ? p['avatar_url'] as String
                  : '',
              bio: classGroup,
              followersCount: classGroup,
              isVerified: p['is_verified'] == true,
            );
          }).toList();
          _isLoadingInitial = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('Error _loadLiveSuggestedAccounts: $e');
    }
    if (mounted) setState(() => _isLoadingInitial = false);
  }

  @override
  void dispose() {
    HomeMenuPopover.dismiss();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) {
      if (mounted) {
        setState(() {
          _liveMatchingPosts = [];
          _liveMatchingAccounts = [];
        });
      }
      return;
    }

    setState(() => _isSearching = true);
    try {
      final posts = await SupabaseService.instance.searchPosts(clean);
      final profiles = await SupabaseService.instance.searchProfiles(clean);

      final accounts = profiles.map<SuggestedAccount>((p) {
        final classGroup = p['class_group'] as String? ?? 'Siswa SMKN 8 Semarang';
        return SuggestedAccount(
          id: p['id'] as String? ?? '',
          fullName: p['full_name'] as String? ?? 'Siswa Snapan',
          username: p['username'] as String? ?? 'siswa',
          avatar: (p['avatar_url'] as String?)?.isNotEmpty == true
              ? p['avatar_url'] as String
              : '',
          bio: classGroup,
          followersCount: classGroup,
          isVerified: p['is_verified'] == true,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _liveMatchingPosts = posts;
          _liveMatchingAccounts = accounts;
          _isSearching = false;
        });
      }
    } catch (e) {
      debugPrint('Error _performSearch: $e');
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _handleQueryChange(String val) {
    setState(() {
      _searchQuery = val;
      if (val.trim().isEmpty) {
        _isSubmitted = false;
        _liveMatchingPosts = [];
        _liveMatchingAccounts = [];
      }
    });
    if (val.trim().isNotEmpty) {
      _performSearch(val);
    }
  }

  void _handleExecuteSearch() {
    if (_searchQuery.trim().isNotEmpty) {
      setState(() => _isSubmitted = true);
      FocusScope.of(context).unfocus();
      _performSearch(_searchQuery);
    }
  }

  void _handleClearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = "";
      _isSubmitted = false;
      _liveMatchingPosts = [];
      _liveMatchingAccounts = [];
    });
    FocusScope.of(context).unfocus();
  }

  void _toggleFollow(String id) {
    String? username;
    for (final a in _accounts) {
      if (a.id == id) {
        username = a.username;
        break;
      }
    }
    if (username == null) {
      for (final a in _liveMatchingAccounts) {
        if (a.id == id) {
          username = a.username;
          break;
        }
      }
    }
    FollowService.instance.toggleFollow(
      targetUserId: id,
      targetUsername: username,
    );
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
        classGroup: account.bio.isNotEmpty ? account.bio : 'Siswa SMKN 8 Semarang',
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

  void _navigateToPostDetail(MarketPost post) {
    Navigator.of(context).push(
      AppSlidePageRoute(
        builder: (_) => PostDetailScreen(post: post),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _searchQuery.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SearchBarHeader(
            controller: _searchController,
            onChanged: _handleQueryChange,
            onSubmitted: _handleExecuteSearch,
            onClear: _handleClearSearch,
            onBack: widget.onBack ?? () => Navigator.of(context).pop(),
            onMenuTap: () => HomeMenuPopover.toggle(context: context),
            onOpenAppTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Snapan Market v0.1.0'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            hasQuery: hasQuery,
            isSubmitted: _isSubmitted,
            activeTab: _activeTab,
            onTabChanged: (tab) => setState(() => _activeTab = tab),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.translucent,
              child: hasQuery && _isSearching
                  ? const SingleChildScrollView(child: SearchResultSkeleton())
                  : !hasQuery
                      ? SearchSuggestedAccountsView(
                          accounts: _accounts,
                          isLoadingInitial: _isLoadingInitial,
                          onNavigateToProfile: (username, acc) => _navigateToProfile(username, acc),
                          onToggleFollow: _toggleFollow,
                        )
                      : SearchResultsView(
                          isSubmitted: _isSubmitted,
                          searchQuery: _searchQuery,
                          activeTab: _activeTab,
                          matchingPosts: _liveMatchingPosts,
                          matchingAccounts: _liveMatchingAccounts,
                          onExecuteSearch: _handleExecuteSearch,
                          onNavigateToProfile: _navigateToProfile,
                          onNavigateToPostDetail: _navigateToPostDetail,
                          onToggleFollow: _toggleFollow,
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
