import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snapan_market/core/models/mascot_flair_model.dart';
import 'package:snapan_market/core/services/follow_service.dart';
import 'package:snapan_market/core/services/poll_sync_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

class HomeFeedController extends ChangeNotifier {
  static const int _pageSize = 15;

  List<MarketPostModel> posts = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMorePosts = true;
  bool hasError = false;
  String errorMessage = '';
  Map<String, dynamic>? userProfile;
  StreamSubscription<AuthState>? _authSubscription;
  RealtimeChannel? _profileChannel;

  void init() {
    FollowService.instance.loadFollowings();
    PollSyncService.instance.addListener(_handlePollSyncUpdate);
    SupabaseService.instance.currentUserProfileNotifier.addListener(_handleProfileChange);
    _setupProfileSubscription();

    // 1. Stale-While-Revalidate: load in-memory cache instantly (0ms)
    if (SupabaseService.instance.hasCachedFeedPosts) {
      posts = List.from(SupabaseService.instance.cachedFeedPosts);
      isLoading = false;
      notifyListeners();
      // Silently revalidate in background
      fetchPosts(isSilent: true);
    } else {
      fetchPosts();
    }

    _authSubscription = SupabaseService.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut) {
        SupabaseService.instance.currentUserProfileNotifier.value = null;
        userProfile = null;
        notifyListeners();
      } else if (data.event == AuthChangeEvent.signedIn || data.event == AuthChangeEvent.tokenRefreshed) {
        _setupProfileSubscription();
      }
      FollowService.instance.loadFollowings();
      fetchPosts(isRefresh: true);
    });
  }

  void _setupProfileSubscription() {
    final user = SupabaseService.instance.currentUser;
    if (user != null) {
      _profileChannel?.unsubscribe();
      _profileChannel = SupabaseService.instance.subscribeToProfile(user.id, (record) {
        SupabaseService.instance.currentUserProfileNotifier.value = record;
        userProfile = record;
        notifyListeners();
      });
    }
  }

  void _handleProfileChange() {
    final p = SupabaseService.instance.currentUserProfileNotifier.value;
    if (p != null) {
      userProfile = p;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    SupabaseService.instance.currentUserProfileNotifier.removeListener(_handleProfileChange);
    _profileChannel?.unsubscribe();
    PollSyncService.instance.removeListener(_handlePollSyncUpdate);
    _authSubscription?.cancel();
    super.dispose();
  }

  void _handlePollSyncUpdate() {
    bool hasChanges = false;
    final updated = posts.map((p) {
      if (p.poll == null) return p;
      final synced = PollSyncService.instance.syncPost(p);
      if (synced != p) {
        hasChanges = true;
        return synced;
      }
      return p;
    }).toList();
    if (hasChanges) {
      posts = updated;
      notifyListeners();
    }
  }

  /// Fetch initial or refreshed posts with Future.wait parallelization & SWR support
  Future<void> fetchPosts({bool isRefresh = false, bool isSilent = false}) async {
    if (!isRefresh && !isSilent && posts.isEmpty) {
      isLoading = true;
      hasError = false;
      errorMessage = '';
      notifyListeners();
    }

    try {
      // Parallel execution: fetch feed posts, likes, and bookmarks simultaneously
      final results = await Future.wait([
        SupabaseService.instance.fetchFeedPosts(limit: _pageSize, offset: 0),
        SupabaseService.instance.fetchLikedPostIds(),
        SupabaseService.instance.fetchBookmarkedPostIds(),
      ]);

      final livePosts = results[0] as List<MarketPostModel>;
      final likedIds = results[1] as Set<String>;
      final savedIds = results[2] as Set<String>;

      final currentUser = SupabaseService.instance.currentUser;
      if (currentUser != null) {
        SupabaseService.instance.getProfile(currentUser.id).then((p) {
          if (p != null) {
            userProfile = p;
            SupabaseService.instance.currentUserProfileNotifier.value = p;
            notifyListeners();
          }
        });
      }

      posts = livePosts
          .where((p) => !p.isDeleted)
          .map((p) => p.copyWith(
            isLiked: likedIds.contains(p.id),
            isSaved: savedIds.contains(p.id),
          ))
          .toList();

      hasMorePosts = livePosts.length >= _pageSize;
      isLoading = false;
      hasError = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Supabase fetch error: $e');
      // If we already had cached posts, do not wipe them!
      if (posts.isEmpty) {
        posts = [];
        hasError = true;
        errorMessage = 'Gagal memuat feed. Periksa koneksi internet Anda.';
      }
      isLoading = false;
      notifyListeners();
    }
  }

  /// Infinite scroll pagination: fetch next batch of posts (15 items)
  Future<void> fetchMorePosts() async {
    if (isLoadingMore || !hasMorePosts || isLoading) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final currentOffset = posts.length;
      final results = await Future.wait([
        SupabaseService.instance.fetchFeedPosts(limit: _pageSize, offset: currentOffset),
        SupabaseService.instance.fetchLikedPostIds(),
        SupabaseService.instance.fetchBookmarkedPostIds(),
      ]);

      final nextPosts = results[0] as List<MarketPostModel>;
      final likedIds = results[1] as Set<String>;
      final savedIds = results[2] as Set<String>;

      if (nextPosts.isEmpty) {
        hasMorePosts = false;
      } else {
        if (nextPosts.length < _pageSize) {
          hasMorePosts = false;
        }

        final enriched = nextPosts
            .where((p) => !p.isDeleted)
            .map((p) => p.copyWith(
              isLiked: likedIds.contains(p.id),
              isSaved: savedIds.contains(p.id),
            ))
            .toList();

        // Deduplicate against existing post IDs
        final existingIds = posts.map((p) => p.id).toSet();
        final newUniquePosts = enriched.where((p) => !existingIds.contains(p.id)).toList();
        posts.addAll(newUniquePosts);
      }
    } catch (e) {
      debugPrint('Error fetchMorePosts: $e');
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> createPost(Map<String, dynamic> data) async {
    try {
      MascotFlairModel? postFlair;
      if (data['mascotFlair'] != null && data['mascotFlair'] is Map) {
        postFlair = MascotFlairModel.fromJson(Map<String, dynamic>.from(data['mascotFlair'] as Map));
      } else if (data['mascotFlair'] is MascotFlairModel) {
        postFlair = data['mascotFlair'] as MascotFlairModel;
      }

      final liveCreated = await SupabaseService.instance.createPost(
        postType: data['postType'] as String? ?? 'thread',
        caption: data['caption'] as String? ?? '',
        title: data['title'] as String?,
        description: data['description'] as String?,
        price: data['price'] as int?,
        stock: data['stock'] as int?,
        locationTag: data['locationTag'] as String?,
        topicTag: data['topicTag'] as String?,
        images: (data['images'] as List<dynamic>?)?.cast<String>() ?? [],
        poll: data['poll'] as Map<String, dynamic>?,
        mascotFlair: postFlair,
      );
      posts.insert(0, liveCreated);
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating post: $e');
    }
  }

  /// Vote in a poll with instantaneous optimistic UI update & debounced network call
  void votePoll(String postId, List<String> optionIds) {
    final idx = posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final currentPost = posts[idx];
    if (currentPost.poll == null) return;

    PollSyncService.instance.castVote(
      postId: postId,
      optionIds: optionIds,
      currentPoll: currentPost.poll!,
      remoteCaller: (pId, oIds) => SupabaseService.instance.votePoll(
        postId: pId,
        optionIds: oIds,
      ),
      onError: (e) {
        debugPrint('[HomeFeedController] Error during poll vote: $e');
      },
    );
  }

  /// Close poll prematurely
  Future<void> closePoll(String postId) async {
    final idx = posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final currentPost = posts[idx];
    if (currentPost.poll == null) return;

    final optimisticPoll = currentPost.poll!.copyWith(isClosed: true);
    posts[idx] = currentPost.copyWith(poll: optimisticPoll);
    notifyListeners();

    try {
      final serverPoll = await SupabaseService.instance.closePoll(postId);
      final currentIdx = posts.indexWhere((p) => p.id == postId);
      if (currentIdx != -1) {
        posts[currentIdx] = posts[currentIdx].copyWith(poll: serverPoll);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error closePoll: $e');
      final currentIdx = posts.indexWhere((p) => p.id == postId);
      if (currentIdx != -1) {
        posts[currentIdx] = currentPost;
        notifyListeners();
      }
      rethrow;
    }
  }

  Future<void> deletePost(MarketPostModel post) async {
    final idx = posts.indexWhere((p) => p.id == post.id);
    if (idx == -1) return;
    posts.removeAt(idx);
    notifyListeners();

    try {
      final isAdmin = await SupabaseService.instance.isCurrentUserAdmin();
      final isOwner = SupabaseService.instance.currentUser?.id == post.seller.id;
      await SupabaseService.instance.deletePost(post.id, asAdmin: isAdmin && !isOwner);
    } catch (e) {
      debugPrint('Error deleting post: $e');
      posts.insert(idx.clamp(0, posts.length), post);
      notifyListeners();
    }
  }

  void toggleLike(MarketPostModel updatedItem) {
    final index = posts.indexWhere((p) => p.id == updatedItem.id);
    if (index != -1) {
      posts[index] = updatedItem;
      notifyListeners();
      SupabaseService.instance.togglePostLike(updatedItem.id, !updatedItem.isLiked);
    }
  }

  void toggleRepost(MarketPostModel updatedItem) {
    final index = posts.indexWhere((p) => p.id == updatedItem.id);
    if (index != -1) {
      posts[index] = updatedItem;
      notifyListeners();
    }
  }

  void updatePost(MarketPostModel updated) {
    final index = posts.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      posts[index] = updated;
      notifyListeners();
    }
  }

  void removePostById(String postId) {
    posts.removeWhere((p) => p.id == postId);
    notifyListeners();
  }
}
