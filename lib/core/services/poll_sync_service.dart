import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Singleton service managing global poll voting cache and synchronization across screens (<200 lines).
class PollSyncService extends ChangeNotifier {
  static final PollSyncService instance = PollSyncService._internal();
  PollSyncService._internal();

  final Map<String, List<String>> _userVotes = {};
  final Map<String, PostPollModel> _pollCache = {};
  final Map<String, Timer> _debounceTimers = {};
  final Map<String, PostPollModel> _preVoteSnapshots = {};
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  Map<String, List<String>> get userVotes => Map.unmodifiable(_userVotes);

  /// Reset in-memory state on sign out
  void clear() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    _preVoteSnapshots.clear();
    _userVotes.clear();
    _pollCache.clear();
    _isInitialized = false;
    notifyListeners();
  }

  /// Get cached poll model if available
  PostPollModel? getCachedPoll(String postId) => _pollCache[postId];

  /// Cast or switch vote with instant optimistic UI update, debounce (450ms) to avoid
  /// spamming Supabase RPCs, and auto-rollback on network error.
  void castVote({
    required String postId,
    required List<String> optionIds,
    required PostPollModel currentPoll,
    required Future<PostPollModel> Function(String postId, List<String> optionIds) remoteCaller,
    void Function(PostPollModel updatedPoll)? onOptimisticUpdate,
    void Function(PostPollModel serverPoll)? onServerSuccess,
    void Function(Object error)? onError,
  }) {
    if (currentPoll.isExpired) return;
    if (currentPoll.hasVoted && !currentPoll.allowChangeVote) return;

    final prevVotes = _userVotes[postId] ?? currentPoll.userVotedOptionIds;
    if (setEquals(prevVotes.toSet(), optionIds.toSet())) return;

    // Preserve snapshot of clean state before this debounce burst
    _preVoteSnapshots.putIfAbsent(postId, () => _pollCache[postId] ?? currentPoll);

    // Apply optimistic update immediately
    final basePoll = _pollCache[postId] ?? currentPoll;
    final optimisticPoll = basePoll.applyOptimisticVotes(optionIds);

    _userVotes[postId] = List<String>.from(optionIds);
    _pollCache[postId] = optimisticPoll;
    onOptimisticUpdate?.call(optimisticPoll);
    notifyListeners();

    // Debounce the actual backend network RPC
    _debounceTimers[postId]?.cancel();
    _debounceTimers[postId] = Timer(const Duration(milliseconds: 450), () async {
      try {
        final serverPoll = await remoteCaller(postId, optionIds);
        _preVoteSnapshots.remove(postId);
        registerPollModel(postId, serverPoll);
        onServerSuccess?.call(serverPoll);
      } catch (e) {
        debugPrint('[PollSyncService] Error casting vote for post $postId: $e');
        // Rollback to clean pre-burst snapshot
        final rollbackPoll = _preVoteSnapshots.remove(postId);
        if (rollbackPoll != null) {
          _userVotes[postId] = List<String>.from(rollbackPoll.userVotedOptionIds);
          _pollCache[postId] = rollbackPoll;
          notifyListeners();
        }
        onError?.call(e);
      } finally {
        _debounceTimers.remove(postId);
      }
    });
  }

  /// Check if the user has voted in a specific poll
  bool hasUserVoted(String postId) {
    final votes = _userVotes[postId];
    return votes != null && votes.isNotEmpty;
  }

  /// Get the list of option IDs voted by current user for a post
  List<String> getUserVotesForPost(String postId) {
    return _userVotes[postId] ?? const [];
  }

  /// Seed initial vote records into cache
  void seedVotes(Map<String, List<String>> votes) {
    _userVotes.addAll(votes);
    _isInitialized = true;
    notifyListeners();
  }

  /// Cache or update a single poll vote action
  void registerUserVote(String postId, List<String> optionIds, [PostPollModel? updatedPoll]) {
    _userVotes[postId] = List<String>.from(optionIds);
    if (updatedPoll != null) {
      _pollCache[postId] = updatedPoll.copyWith(userVotedOptionIds: optionIds);
    } else if (_pollCache.containsKey(postId)) {
      _pollCache[postId] = _pollCache[postId]!.copyWith(userVotedOptionIds: optionIds);
    }
    notifyListeners();
  }

  /// Cache the latest server poll state
  void registerPollModel(String postId, PostPollModel poll) {
    final userVotes = _userVotes[postId] ?? poll.userVotedOptionIds;
    _pollCache[postId] = poll.copyWith(userVotedOptionIds: userVotes);
    notifyListeners();
  }

  /// Merge cached poll state and user votes into a single MarketPostModel
  MarketPostModel syncPost(MarketPostModel post) {
    if (post.poll == null) return post;

    final cachedPoll = _pollCache[post.id];
    final userVotes = _userVotes[post.id];

    if (cachedPoll != null) {
      final mergedPoll = userVotes != null
          ? cachedPoll.copyWith(userVotedOptionIds: userVotes)
          : cachedPoll;
      return post.copyWith(poll: mergedPoll);
    }

    if (userVotes != null && userVotes.isNotEmpty) {
      return post.copyWith(
        poll: post.poll!.copyWith(userVotedOptionIds: userVotes),
      );
    }

    return post;
  }

  /// Sync a list of posts with the in-memory poll cache
  List<MarketPostModel> syncPosts(List<MarketPostModel> posts) {
    return posts.map(syncPost).toList();
  }

  /// Warm up user votes cache from Supabase and sync posts
  Future<List<MarketPostModel>> hydrateAndSyncPosts({
    required SupabaseClient client,
    required List<MarketPostModel> posts,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) {
      return posts;
    }

    if (!_isInitialized) {
      try {
        final votesResponse = await client
            .from('post_poll_votes')
            .select('post_id, option_id')
            .eq('user_id', user.id);

        for (final row in votesResponse) {
          final pid = row['post_id']?.toString();
          final oid = row['option_id']?.toString();
          if (pid != null && oid != null) {
            _userVotes.putIfAbsent(pid, () => []).add(oid);
          }
        }
        _isInitialized = true;
      } catch (e) {
        debugPrint('Error hydrateAndSyncPosts user votes: $e');
      }
    }

    return syncPosts(posts);
  }
}
