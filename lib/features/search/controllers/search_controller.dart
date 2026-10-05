import 'package:flutter/material.dart';
import 'package:snapan_market/core/services/follow_service.dart';
import 'package:snapan_market/core/services/poll_sync_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';
import 'package:snapan_market/features/search/models/search_models.dart';

/// Controller managing search state, queries, and optimistic interactions (<200 lines).
class AppSearchController extends ChangeNotifier {
  String searchQuery = "";
  bool isSubmitted = false;
  bool isSearching = false;
  bool isLoadingInitial = true;
  SearchResultsTab activeTab = SearchResultsTab.top;

  List<SuggestedAccount> accounts = [];
  List<MarketPost> liveMatchingPosts = [];
  List<SuggestedAccount> liveMatchingAccounts = [];

  void init() {
    PollSyncService.instance.addListener(_handlePollSync);
    loadLiveSuggestedAccounts();
  }

  @override
  void dispose() {
    PollSyncService.instance.removeListener(_handlePollSync);
    super.dispose();
  }

  void _handlePollSync() {
    if (liveMatchingPosts.isEmpty) return;
    bool hasChanges = false;
    final updated = liveMatchingPosts.map((p) {
      if (p.poll == null) return p;
      final synced = PollSyncService.instance.syncPost(p);
      if (synced != p) {
        hasChanges = true;
        return synced;
      }
      return p;
    }).toList();
    if (hasChanges) {
      liveMatchingPosts = updated;
      notifyListeners();
    }
  }

  SuggestedAccount _mapAccount(Map<String, dynamic> p) {
    final uName = p['username'] as String? ?? '';
    final fName = p['full_name'] as String?;
    return SuggestedAccount(
      id: p['id'] as String? ?? '',
      fullName: (fName != null && fName.isNotEmpty) ? fName : (uName.isNotEmpty ? '@$uName' : 'Pengguna'),
      username: uName,
      avatar: (p['avatar_url'] as String?)?.isNotEmpty == true ? p['avatar_url'] as String : '',
      bio: p['bio'] as String? ?? '',
      followersCount: '',
      isVerified: p['is_verified'] == true,
    );
  }

  Future<void> loadLiveSuggestedAccounts() async {
    try {
      final records = await SupabaseService.instance.fetchSuggestedProfiles(limit: 15);
      if (records.isNotEmpty) {
        accounts = records.map(_mapAccount).toList();
        isLoadingInitial = false;
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('Error loadLiveSuggestedAccounts: $e');
    }
    isLoadingInitial = false;
    notifyListeners();
  }

  Future<void> performSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) {
      liveMatchingPosts = [];
      liveMatchingAccounts = [];
      notifyListeners();
      return;
    }

    isSearching = true;
    notifyListeners();

    try {
      final rawPosts = await SupabaseService.instance.searchPosts(clean);
      final profiles = await SupabaseService.instance.searchProfiles(clean);
      final likedIds = await SupabaseService.instance.fetchLikedPostIds();
      final savedIds = await SupabaseService.instance.fetchBookmarkedPostIds();

      liveMatchingPosts = rawPosts.map((p) => p.copyWith(
        isLiked: likedIds.contains(p.id),
        isSaved: savedIds.contains(p.id),
      )).toList();

      liveMatchingAccounts = profiles.map(_mapAccount).toList();
      isSearching = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error performSearch: $e');
      isSearching = false;
      notifyListeners();
    }
  }

  void handleQueryChange(String val) {
    searchQuery = val;
    if (val.trim().isEmpty) {
      isSubmitted = false;
      liveMatchingPosts = [];
      liveMatchingAccounts = [];
    }
    notifyListeners();
    if (val.trim().isNotEmpty) {
      performSearch(val);
    }
  }

  void handleExecuteSearch() {
    if (searchQuery.trim().isNotEmpty) {
      isSubmitted = true;
      notifyListeners();
      performSearch(searchQuery);
    }
  }

  void handleClearSearch() {
    searchQuery = "";
    isSubmitted = false;
    liveMatchingPosts = [];
    liveMatchingAccounts = [];
    notifyListeners();
  }

  void setActiveTab(SearchResultsTab tab) {
    activeTab = tab;
    notifyListeners();
  }

  void toggleFollow(String id) {
    String? username;
    for (final a in accounts) {
      if (a.id == id) { username = a.username; break; }
    }
    if (username == null) {
      for (final a in liveMatchingAccounts) {
        if (a.id == id) { username = a.username; break; }
      }
    }
    FollowService.instance.toggleFollow(targetUserId: id, targetUsername: username);
  }

  void toggleLike(MarketPost post) {
    final isLiked = post.isLiked;
    final updated = post.copyWith(isLiked: !isLiked, likesCount: isLiked ? (post.likesCount - 1) : (post.likesCount + 1));
    liveMatchingPosts = liveMatchingPosts.map((p) => p.id == post.id ? updated : p).toList();
    notifyListeners();
    SupabaseService.instance.togglePostLike(post.id, !isLiked);
  }

  void toggleBookmark(MarketPost post) {
    final isSaved = post.isSaved;
    final updated = post.copyWith(isSaved: !isSaved);
    liveMatchingPosts = liveMatchingPosts.map((p) => p.id == post.id ? updated : p).toList();
    notifyListeners();
    SupabaseService.instance.togglePostBookmark(post.id, !isSaved);
  }

  void updatePost(MarketPost updated) {
    liveMatchingPosts = liveMatchingPosts.map((p) => p.id == updated.id ? updated : p).toList();
    notifyListeners();
  }

  void removePost(String postId) {
    liveMatchingPosts.removeWhere((p) => p.id == postId);
    notifyListeners();
  }

  void votePoll(MarketPost post, List<String> optionIds) {
    if (post.poll == null) return;

    PollSyncService.instance.castVote(
      postId: post.id,
      optionIds: optionIds,
      currentPoll: post.poll!,
      remoteCaller: (pId, oIds) => SupabaseService.instance.votePoll(
        postId: pId,
        optionIds: oIds,
      ),
      onError: (e) {
        debugPrint('[AppSearchController] Error votePoll search: $e');
      },
    );
  }
}
