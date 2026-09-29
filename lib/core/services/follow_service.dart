import 'package:flutter/foundation.dart';
import 'package:snapan_market/core/services/supabase_service.dart';

/// Singleton service managing global follow state across Feed, Profile, and Search
class FollowService extends ChangeNotifier {
  static final FollowService instance = FollowService._internal();
  FollowService._internal();

  final Set<String> _followingIds = {};
  final Set<String> _followingUsernames = {};
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  Set<String> get followingIds => Set.unmodifiable(_followingIds);

  /// Checks if the target is the currently authenticated user
  bool isCurrentUser(String? userId, String? username) {
    final current = SupabaseService.instance.currentUser;
    if (current == null) return false;
    if (userId != null && userId.isNotEmpty && userId == current.id) return true;
    final currentUsername = current.userMetadata?['username'] as String?;
    if (username != null && currentUsername != null &&
        username.toLowerCase().replaceAll('@', '').trim() ==
            currentUsername.toLowerCase().replaceAll('@', '').trim()) {
      return true;
    }
    return false;
  }

  /// Checks if the current user is following the given user ID or username
  bool isFollowing(String? userId, String? username) {
    if (userId != null && userId.isNotEmpty && _followingIds.contains(userId)) {
      return true;
    }
    if (username != null && username.isNotEmpty) {
      final clean = username.toLowerCase().replaceAll('@', '').trim();
      if (_followingUsernames.contains(clean)) return true;
    }
    return false;
  }

  /// Load following list from Supabase
  Future<void> loadFollowings() async {
    final user = SupabaseService.instance.currentUser;
    if (user == null) {
      _followingIds.clear();
      _followingUsernames.clear();
      _isLoaded = false;
      notifyListeners();
      return;
    }

    try {
      final list = await SupabaseService.instance.fetchFollowings();
      _followingIds.clear();
      _followingUsernames.clear();

      for (final item in list) {
        final fid = item['following_id'] as String?;
        if (fid != null && fid.isNotEmpty) {
          _followingIds.add(fid);
        }

        final followingProfile = item['following'] as Map<String, dynamic>?;
        if (followingProfile != null) {
          final u = followingProfile['username'] as String?;
          if (u != null && u.isNotEmpty) {
            _followingUsernames.add(u.toLowerCase().replaceAll('@', '').trim());
          }
        }
      }
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loadFollowings: $e');
    }
  }

  /// Toggle follow state optimistically and persist to Supabase
  Future<bool> toggleFollow({
    required String? targetUserId,
    required String? targetUsername,
  }) async {
    final user = SupabaseService.instance.currentUser;
    if (user == null) return false;

    // Resolve targetUserId if null or not UUID
    String? resolvedId = targetUserId;
    final isUuid = resolvedId != null &&
        RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
                caseSensitive: false)
            .hasMatch(resolvedId);

    if (!isUuid && targetUsername != null && targetUsername.isNotEmpty) {
      final clean = targetUsername.toLowerCase().replaceAll('@', '').trim();
      final profile = await SupabaseService.instance.getProfileByUsername(clean);
      if (profile != null && profile['id'] != null) {
        resolvedId = profile['id'] as String;
      }
    }

    final cleanUsername = targetUsername?.toLowerCase().replaceAll('@', '').trim();
    final bool currentlyFollowing = isFollowing(resolvedId, targetUsername);

    if (currentlyFollowing) {
      // Optimistic Unfollow
      if (resolvedId != null) _followingIds.remove(resolvedId);
      if (cleanUsername != null) _followingUsernames.remove(cleanUsername);
      notifyListeners();

      if (resolvedId != null) {
        await SupabaseService.instance.unfollowUser(resolvedId);
      }
      return false;
    } else {
      // Optimistic Follow
      if (resolvedId != null) _followingIds.add(resolvedId);
      if (cleanUsername != null) _followingUsernames.add(cleanUsername);
      notifyListeners();

      if (resolvedId != null) {
        await SupabaseService.instance.followUser(resolvedId);
      }
      return true;
    }
  }
}
