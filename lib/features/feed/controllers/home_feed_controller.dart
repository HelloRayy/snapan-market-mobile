import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snapan_market/core/services/follow_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

class HomeFeedController extends ChangeNotifier {
  List<MarketPostModel> posts = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  Map<String, dynamic>? userProfile;
  StreamSubscription<AuthState>? _authSubscription;

  void init() {
    FollowService.instance.loadFollowings();
    fetchPosts();
    _authSubscription = SupabaseService.instance.client.auth.onAuthStateChange.listen((_) {
      FollowService.instance.loadFollowings();
      fetchPosts(isRefresh: true);
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchPosts({bool isRefresh = false}) async {
    if (!isRefresh) {
      isLoading = true;
      hasError = false;
      errorMessage = '';
      notifyListeners();
    }

    try {
      final livePosts = await SupabaseService.instance.fetchFeedPosts();
      final likedIds = await SupabaseService.instance.fetchLikedPostIds();
      final savedIds = await SupabaseService.instance.fetchBookmarkedPostIds();

      final currentUser = SupabaseService.instance.currentUser;
      if (currentUser != null) {
        SupabaseService.instance.getProfile(currentUser.id).then((p) {
          if (p != null) {
            userProfile = p;
            notifyListeners();
          }
        });
      }

      posts = livePosts.map((p) => p.copyWith(
        isLiked: likedIds.contains(p.id),
        isSaved: savedIds.contains(p.id),
      )).toList();
      isLoading = false;
      hasError = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Supabase fetch error: $e');
      posts = [];
      isLoading = false;
      hasError = false;
      notifyListeners();
    }
  }

  Future<void> createPost(Map<String, dynamic> data) async {
    try {
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
      );
      posts.insert(0, liveCreated);
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating post: $e');
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
