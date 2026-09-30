import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snapan_market/core/services/follow_service.dart';
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
        final ownFollowersCount = await FollowService.instance.loadFollowerCount(currentUser.id);
        final meta = currentUser.userMetadata ?? {};
        final metaTags = meta['tags'];
        List<String> userTags = [];
        if (profile?['interests'] is String && (profile!['interests'] as String).isNotEmpty) {
          userTags = (profile['interests'] as String).split(',');
        } else if (metaTags is List) {
          userTags = metaTags.map((e) => e.toString()).toList();
        }

        final fullName = profile?['full_name'] as String? ?? (meta['full_name'] as String?)?.trim();
        final metaUsername = profile?['username'] as String? ?? (meta['username'] as String?)?.trim();
        final classGroup = profile?['class_group'] as String? ?? (meta['class_group'] as String?)?.trim() ?? 'SMKN 8 Semarang';
        final avatar = profile?['avatar_url'] as String? ?? (meta['avatar_url'] as String?)?.trim() ?? '';
        final bio = profile?['bio'] as String? ?? (meta['bio'] as String?)?.trim() ?? '';
        final link = profile?['link'] as String? ?? (meta['link'] as String?)?.trim() ?? '';
        final isVerified = profile?['is_verified'] as bool? ?? false;

        final displayName = (fullName != null && fullName.isNotEmpty)
            ? fullName
            : (metaUsername != null && metaUsername.isNotEmpty ? '@$metaUsername' : 'Pengguna');
        final displayUsername = (metaUsername != null && metaUsername.isNotEmpty)
            ? metaUsername
            : (currentUser.email?.split('@').first ?? 'siswa');

        user = ProfileUserModel(
          id: currentUser.id,
          name: displayName,
          username: displayUsername,
          classGroup: classGroup,
          avatar: avatar,
          bio: bio,
          link: link,
          tags: userTags,
          followersCount: ownFollowersCount,
          soldCount: 0,
          isVerified: isVerified,
          rating: 0.0,
          showSalesStats: false,
        );

        allUserPosts = livePosts;
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
          final otherFollowers = await FollowService.instance.loadFollowerCount(targetId);

          final fullName = p['full_name'] as String?;
          final uName = p['username'] as String? ?? cleanUsername;

          user = ProfileUserModel(
            id: targetId,
            name: (fullName != null && fullName.isNotEmpty) ? fullName : '@$uName',
            username: uName,
            classGroup: p['class_group'] as String? ?? 'SMKN 8 Semarang',
            avatar: (p['avatar_url'] as String?)?.isNotEmpty == true ? p['avatar_url'] as String : '',
            bio: p['bio'] as String? ?? '',
            link: p['link'] as String? ?? '',
            followersCount: otherFollowers,
            soldCount: 0,
            rating: 0.0,
            showSalesStats: false,
            isVerified: p['is_verified'] as bool? ?? false,
          );
          allUserPosts = targetPosts;
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
    final updated = item.copyWith(
      isLiked: !isLiked,
      likesCount: isLiked ? (item.likesCount - 1) : (item.likesCount + 1),
    );
    allUserPosts = allUserPosts.map((p) => p.id == item.id ? updated : p).toList();
    notifyListeners();
    SupabaseService.instance.togglePostLike(item.id, !item.isLiked);
  }

  void toggleRepost(MarketPostModel item) {
    final isReposted = item.isReposted;
    final updated = item.copyWith(
      isReposted: !isReposted,
      repostsCount: isReposted ? (item.repostsCount - 1) : (item.repostsCount + 1),
    );
    allUserPosts = allUserPosts.map((p) => p.id == item.id ? updated : p).toList();
    notifyListeners();
  }

  void removePost(String postId) {
    allUserPosts.removeWhere((p) => p.id == postId);
    notifyListeners();
  }

  void updateUser(ProfileUserModel updated) {
    user = updated;
    allUserPosts = allUserPosts.map((p) => p.copyWith(
      seller: p.seller.copyWith(
        name: updated.name,
        username: updated.username,
        avatar: updated.avatar,
        classGroup: updated.classGroup,
      ),
    )).toList();
    notifyListeners();
  }
}
