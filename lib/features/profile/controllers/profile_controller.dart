import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snapan_market/core/services/follow_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';
import 'package:snapan_market/features/profile/models/profile_user_model.dart';

class ProfileController extends ChangeNotifier {
  ProfileUserModel user = ProfileUserModel(
    id: '',
    name: 'Siswa Snapan',
    username: 'siswa',
    classGroup: 'SMKN 8 Semarang',
    avatar: '',
    bio: '',
    followersCount: 0,
    followingCount: 0,
    itemsSold: 0,
    tags: const [],
    isVerified: false,
    rating: 5.0,
    salesCount: 0,
    showSalesStats: true,
  );

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
    if (isOwnProfile) {
      final currentUser = SupabaseService.instance.currentUser;
      if (currentUser == null) {
        isLoading = false;
        notifyListeners();
        return;
      }

      try {
        final profile = await SupabaseService.instance.getProfile(currentUser.id);
        final livePosts = await SupabaseService.instance.fetchUserPosts(currentUser.id);
        final ownFollowersCount = await FollowService.instance.loadFollowerCount(currentUser.id);
        final meta = currentUser.userMetadata ?? {};
        final metaTags = meta['tags'];
        List<String> userTags = user.tags;
        if (profile?['interests'] is String && (profile!['interests'] as String).isNotEmpty) {
          userTags = (profile['interests'] as String).split(',');
        } else if (metaTags is List) {
          userTags = metaTags.map((e) => e.toString()).toList();
        }

        if (profile != null) {
          user = user.copyWith(
            id: profile['id'] as String? ?? currentUser.id,
            name: profile['full_name'] as String? ?? user.name,
            username: profile['username'] as String? ?? user.username,
            classGroup: profile['class_group'] as String? ?? user.classGroup,
            avatar: (profile['avatar_url'] as String?)?.isNotEmpty == true
                ? profile['avatar_url'] as String
                : user.avatar,
            bio: profile['bio'] as String? ?? (meta['bio'] as String?) ?? user.bio,
            link: profile['link'] as String? ?? (meta['link'] as String?) ?? user.link,
            tags: userTags,
            followersCount: ownFollowersCount,
            isVerified: profile['is_verified'] as bool? ?? false,
          );
        } else {
          final fullName = (meta['full_name'] as String?)?.trim();
          final metaUsername = (meta['username'] as String?)?.trim();
          final classGroup = (meta['class_group'] as String?)?.trim();
          final avatar = (meta['avatar_url'] as String?)?.trim() ?? '';
          final bio = (meta['bio'] as String?)?.trim();
          final link = (meta['link'] as String?)?.trim();

          user = user.copyWith(
            name: (fullName != null && fullName.isNotEmpty) ? fullName : user.name,
            username: (metaUsername != null && metaUsername.isNotEmpty) ? metaUsername : user.username,
            classGroup: (classGroup != null && classGroup.isNotEmpty) ? classGroup : user.classGroup,
            avatar: avatar.isNotEmpty ? avatar : user.avatar,
            bio: (bio != null && bio.isNotEmpty) ? bio : user.bio,
            link: link ?? user.link,
            tags: userTags,
            followersCount: ownFollowersCount,
          );
        }
        allUserPosts = livePosts;
        isLoading = false;
        notifyListeners();
        _setupRealtime(currentUser.id, isOwn: true);
      } catch (e) {
        debugPrint('Error loadProfile: $e');
        isLoading = false;
        notifyListeners();
      }
    } else {
      final cleanUsername = username?.replaceAll('@', '').toLowerCase().trim();
      if (cleanUsername == null || cleanUsername.isEmpty) return;

      try {
        final matched = await SupabaseService.instance.searchProfiles(cleanUsername);
        if (matched.isNotEmpty) {
          final p = matched.first;
          final targetId = p['id'] as String? ?? '';
          final targetPosts = await SupabaseService.instance.fetchUserPosts(targetId);
          final otherFollowers = await FollowService.instance.loadFollowerCount(targetId);

          user = user.copyWith(
            id: targetId,
            name: p['full_name'] as String? ?? user.name,
            username: p['username'] as String? ?? cleanUsername,
            classGroup: p['class_group'] as String? ?? user.classGroup,
            avatar: (p['avatar_url'] as String?)?.isNotEmpty == true ? p['avatar_url'] as String : user.avatar,
            bio: p['bio'] as String? ?? user.bio,
            link: p['link'] as String? ?? user.link,
            followersCount: otherFollowers,
            isVerified: p['is_verified'] as bool? ?? false,
          );
          allUserPosts = targetPosts;
          isLoading = false;
          notifyListeners();
          _setupRealtime(targetId, isOwn: false);
        }
      } catch (e) {
        debugPrint('Error load other profile: $e');
        isLoading = false;
        notifyListeners();
      }
    }
  }

  void _setupRealtime(String userId, {required bool isOwn}) {
    disposeSubscriptions();
    if (isOwn) {
      _profileSubscription = SupabaseService.instance.subscribeToProfile(userId, (newRecord) {
        user = user.copyWith(
          name: newRecord['full_name'] as String? ?? user.name,
          username: newRecord['username'] as String? ?? user.username,
          classGroup: newRecord['class_group'] as String? ?? user.classGroup,
          avatar: (newRecord['avatar_url'] as String?)?.isNotEmpty == true ? newRecord['avatar_url'] as String : user.avatar,
          bio: newRecord['bio'] as String? ?? user.bio,
          isVerified: newRecord['is_verified'] as bool? ?? false,
        );
        notifyListeners();
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
