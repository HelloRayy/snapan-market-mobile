import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snapan_market/core/services/follow_service.dart';
import 'package:snapan_market/core/services/poll_sync_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';
import 'package:snapan_market/features/profile/models/profile_user_model.dart';

class ProfileController extends ChangeNotifier {
  ProfileUserModel? user;
  bool isNotFound = false;
  List<MarketPostModel> allUserPosts = [];
  List<ProfileReplyThreadModel> allUserReplies = [];
  bool isLoading = true;

  RealtimeChannel? _profileSubscription;
  RealtimeChannel? _followRealtimeSubscription;

  ProfileController() {
    PollSyncService.instance.addListener(_handlePollSyncUpdate);
  }

  @override
  void dispose() {
    PollSyncService.instance.removeListener(_handlePollSyncUpdate);
    disposeSubscriptions();
    super.dispose();
  }

  void _handlePollSyncUpdate() {
    bool hasChanges = false;
    final updated = allUserPosts.map((p) {
      if (p.poll == null) return p;
      final synced = PollSyncService.instance.syncPost(p);
      if (synced != p) {
        hasChanges = true;
        return synced;
      }
      return p;
    }).toList();
    if (hasChanges) {
      allUserPosts = updated;
      notifyListeners();
    }
  }

  void disposeSubscriptions() {
    _profileSubscription?.unsubscribe();
    _followRealtimeSubscription?.unsubscribe();
  }

  Future<void> loadProfile({required bool isOwnProfile, String? username}) async {
    isLoading = true;
    isNotFound = false;
    user = null;
    notifyListeners();

    if (isOwnProfile) {
      final currentUser = SupabaseService.instance.currentUser;
      if (currentUser == null) {
        isLoading = false;
        user = null;
        notifyListeners();
        return;
      }

      try {
        final profile = await SupabaseService.instance.getProfile(currentUser.id);
        final livePosts = await SupabaseService.instance.fetchUserPosts(currentUser.id);
        final ownFollowers = await FollowService.instance.loadFollowerCount(currentUser.id);

        user = _buildUserModel(
          id: currentUser.id,
          profile: profile,
          meta: currentUser.userMetadata ?? {},
          followersCount: ownFollowers,
          fallbackUsername: currentUser.email?.split('@').first,
        );

        allUserPosts = await _enrichPosts(livePosts);
        isLoading = false;
        isNotFound = false;
        notifyListeners();
        _setupRealtime(currentUser.id, isOwn: true);
      } catch (e) {
        debugPrint('Error loadProfile own: $e');
        isLoading = false;
        notifyListeners();
      }
    } else {
      final cleanUsername = username?.replaceAll('@', '').toLowerCase().trim();
      if (cleanUsername == null || cleanUsername.isEmpty) {
        isLoading = false;
        isNotFound = true;
        notifyListeners();
        return;
      }

      try {
        Map<String, dynamic>? p = await SupabaseService.instance.getProfileByUsername(cleanUsername);
        p ??= await SupabaseService.instance.getProfile(cleanUsername);
        if (p == null) {
          final matched = await SupabaseService.instance.searchProfiles(cleanUsername);
          if (matched.isNotEmpty) p = matched.first;
        }

        if (p != null) {
          final targetId = p['id'] as String? ?? '';
          final targetPosts = await SupabaseService.instance.fetchUserPosts(targetId);
          final followers = await FollowService.instance.loadFollowerCount(targetId);

          user = _buildUserModel(
            id: targetId,
            profile: p,
            followersCount: followers,
            fallbackUsername: cleanUsername,
          );
          allUserPosts = await _enrichPosts(targetPosts);
          isLoading = false;
          isNotFound = false;
          notifyListeners();
          _setupRealtime(targetId, isOwn: false);
        } else {
          user = null;
          allUserPosts = [];
          isLoading = false;
          isNotFound = true;
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error load other profile: $e');
        isLoading = false;
        isNotFound = true;
        notifyListeners();
      }
    }
  }

  void _setupRealtime(String userId, {required bool isOwn}) {
    disposeSubscriptions();
    if (isOwn) {
      _profileSubscription = SupabaseService.instance.subscribeToProfile(userId, (newRecord) {
        if (user != null) {
          user = user!.copyWith(
            name: newRecord['full_name'] as String? ?? user!.name,
            username: newRecord['username'] as String? ?? user!.username,
            classGroup: newRecord['class_group'] as String? ?? user!.classGroup,
            avatar: (newRecord['avatar_url'] as String?)?.isNotEmpty == true ? newRecord['avatar_url'] as String : user!.avatar,
            bio: newRecord['bio'] as String? ?? user!.bio,
            isVerified: newRecord['is_verified'] as bool? ?? false,
          );
          notifyListeners();
        }
      });
    }
    _followRealtimeSubscription = SupabaseService.instance.subscribeToFollowers(userId, () {
      FollowService.instance.loadFollowerCount(userId);
    });
  }

  void toggleLike(MarketPostModel item) {
    final isLiked = item.isLiked;
    final updated = item.copyWith(isLiked: !isLiked, likesCount: isLiked ? (item.likesCount - 1) : (item.likesCount + 1));
    allUserPosts = allUserPosts.map((p) => p.id == item.id ? updated : p).toList();
    notifyListeners();
    SupabaseService.instance.togglePostLike(item.id, !item.isLiked);
  }

  void toggleBookmark(MarketPostModel item) {
    final isSaved = item.isSaved;
    final updated = item.copyWith(isSaved: !isSaved);
    allUserPosts = allUserPosts.map((p) => p.id == item.id ? updated : p).toList();
    notifyListeners();
    SupabaseService.instance.togglePostBookmark(item.id, !isSaved);
  }

  void toggleRepost(MarketPostModel item) {
    final isReposted = item.isReposted;
    final updated = item.copyWith(isReposted: !isReposted, repostsCount: isReposted ? (item.repostsCount - 1) : (item.repostsCount + 1));
    allUserPosts = allUserPosts.map((p) => p.id == item.id ? updated : p).toList();
    notifyListeners();
  }

  void updatePost(MarketPostModel updated) {
    final idx = allUserPosts.indexWhere((p) => p.id == updated.id);
    if (idx != -1) {
      allUserPosts[idx] = updated;
      notifyListeners();
    }
  }

  void votePoll(String postId, List<String> optionIds) {
    final idx = allUserPosts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final currentPost = allUserPosts[idx];
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
        debugPrint('[ProfileController] Error votePoll profile: $e');
      },
    );
  }

  void removePost(String postId) {
    allUserPosts.removeWhere((p) => p.id == postId);
    notifyListeners();
  }

  void updateUser(ProfileUserModel updated) {
    user = updated;
    if (SupabaseService.instance.currentUser?.id == updated.id) {
      final existing = SupabaseService.instance.currentUserProfileNotifier.value ?? {};
      SupabaseService.instance.currentUserProfileNotifier.value = {
        ...existing,
        'id': updated.id,
        'full_name': updated.name,
        'username': updated.username,
        'avatar_url': updated.avatar,
        'class_group': updated.classGroup,
        'bio': updated.bio,
        'link': updated.link,
      };
    }
    allUserPosts = allUserPosts.map((p) => p.copyWith(
      seller: p.seller.copyWith(name: updated.name, username: updated.username, avatar: updated.avatar, classGroup: updated.classGroup),
    )).toList();
    notifyListeners();
  }

  Future<List<MarketPostModel>> _enrichPosts(List<MarketPostModel> posts) async {
    final likedIds = await SupabaseService.instance.fetchLikedPostIds();
    final savedIds = await SupabaseService.instance.fetchBookmarkedPostIds();
    return posts.map((p) => p.copyWith(
      isLiked: likedIds.contains(p.id),
      isSaved: savedIds.contains(p.id),
    )).toList();
  }

  ProfileUserModel _buildUserModel({
    required String id,
    required Map<String, dynamic>? profile,
    Map<String, dynamic> meta = const {},
    required int followersCount,
    String? fallbackUsername,
  }) {
    final rawInterests = profile?['interests'];
    final metaTags = meta['tags'];
    List<String> tags = [];
    if (rawInterests is String && rawInterests.isNotEmpty) {
      tags = rawInterests.split(',');
    } else if (metaTags is List) {
      tags = metaTags.map((e) => e.toString()).toList();
    }

    final fullName = profile?['full_name'] as String? ?? (meta['full_name'] as String?)?.trim();
    final uName = profile?['username'] as String? ?? (meta['username'] as String?)?.trim() ?? fallbackUsername ?? 'siswa';

    final rawClass = (profile?['class_group'] as String?)?.trim();
    final metaClass = (meta['class_group'] as String?)?.trim();
    final effectiveClass = (rawClass != null && rawClass.isNotEmpty)
        ? rawClass
        : ((metaClass != null && metaClass.isNotEmpty) ? metaClass : 'SMKN 8 Semarang');

    return ProfileUserModel(
      id: id,
      name: (fullName != null && fullName.isNotEmpty) ? fullName : '@$uName',
      username: uName,
      classGroup: effectiveClass,
      avatar: (profile?['avatar_url'] as String?)?.isNotEmpty == true
          ? profile!['avatar_url'] as String
          : ((meta['avatar_url'] as String?)?.trim() ?? ''),
      bio: profile?['bio'] as String? ?? (meta['bio'] as String?)?.trim() ?? '',
      link: profile?['link'] as String? ?? (meta['link'] as String?)?.trim() ?? '',
      tags: tags,
      followersCount: followersCount,
      isVerified: profile?['is_verified'] as bool? ?? false,
    );
  }
}


