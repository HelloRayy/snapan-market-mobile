import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snapan_market/core/services/poll_sync_service.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

class SupabaseFeedService {
  SupabaseFeedService(this._client);
  final SupabaseClient _client;

  User? get _currentUser => _client.auth.currentUser;

  /// Fetch live feed posts joined with profiles
  Future<List<MarketPostModel>> fetchFeedPosts({
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('market_posts')
          .select('*, seller:profiles!market_posts_seller_id_fkey(*)')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final rawList = (response as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((json) => MarketPostModel.fromJson(json))
          .toList();

      return await PollSyncService.instance.hydrateAndSyncPosts(
        client: _client,
        posts: rawList,
      );
    } catch (e) {
      debugPrint('Error fetchFeedPosts: $e');
      rethrow;
    }
  }

  /// Create a new thread or product post in public.market_posts
  Future<MarketPostModel> createPost({
    required String postType,
    required String caption,
    String? title,
    String? description,
    int? price,
    int? originalPrice,
    int? stock,
    String? category,
    String? locationTag,
    String? topicTag,
    List<String> images = const [],
    Map<String, dynamic>? poll,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('Anda harus masuk untuk membuat postingan.');
    }

    final postData = {
      'seller_id': user.id,
      'post_type': postType,
      'caption': caption,
      if (title != null && title.isNotEmpty) 'title': title,
      if (description != null && description.isNotEmpty) 'description': description,
      'price': price ?? 0,
      if (originalPrice != null) 'original_price': originalPrice,
      'stock': stock ?? 1,
      'category': category ?? (postType == 'product' ? 'Produk Siswa' : 'Umum'),
      'location_tag': MarketPostModel.normalizeLocationTag(locationTag),
      if (topicTag != null && topicTag.isNotEmpty) 'topic_tag': topicTag,
      'images': images,
      if (poll != null) 'poll': poll,
    };

    try {
      final inserted = await _client
          .from('market_posts')
          .insert(postData)
          .select('*, seller:profiles!market_posts_seller_id_fkey(*)')
          .single();

      return MarketPostModel.fromJson(inserted);
    } catch (e) {
      debugPrint('Error createPost: $e');
      rethrow;
    }
  }

  /// Delete a post created by current user, or any post if caller is admin
  Future<void> deletePost(String postId, {bool asAdmin = false}) async {
    final user = _currentUser;
    if (user == null) return;

    try {
      if (asAdmin) {
        await _client.from('market_posts').delete().eq('id', postId);
      } else {
        await _client
            .from('market_posts')
            .delete()
            .match({'id': postId, 'seller_id': user.id});
      }
    } catch (e) {
      debugPrint('Error deletePost: $e');
      rethrow;
    }
  }

  /// Fetch posts created by a specific user/seller
  Future<List<MarketPostModel>> fetchUserPosts(String userId) async {
    try {
      final response = await _client
          .from('market_posts')
          .select('*, seller:profiles!market_posts_seller_id_fkey(*)')
          .eq('seller_id', userId)
          .order('created_at', ascending: false);

      final rawList = (response as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((json) => MarketPostModel.fromJson(json))
          .toList();

      return await PollSyncService.instance.hydrateAndSyncPosts(
        client: _client,
        posts: rawList,
      );
    } catch (e) {
      debugPrint('Error fetchUserPosts: $e');
      return [];
    }
  }

  /// Toggle like on post in public.post_likes
  Future<bool> togglePostLike(String postId, bool isCurrentlyLiked) async {
    final user = _currentUser;
    if (user == null) return !isCurrentlyLiked;

    try {
      if (isCurrentlyLiked) {
        await _client
            .from('post_likes')
            .delete()
            .match({'post_id': postId, 'user_id': user.id});
        return false;
      } else {
        await _client.from('post_likes').insert({
          'post_id': postId,
          'user_id': user.id,
        });
        return true;
      }
    } catch (e) {
      debugPrint('Error togglePostLike: $e');
      return isCurrentlyLiked;
    }
  }

  /// Fetch set of post IDs liked by current user
  Future<Set<String>> fetchLikedPostIds() async {
    final user = _currentUser;
    if (user == null) return {};

    try {
      final response = await _client
          .from('post_likes')
          .select('post_id')
          .eq('user_id', user.id);

      final set = (response as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((e) => e['post_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      return set;
    } catch (e) {
      debugPrint('Error fetchLikedPostIds: $e');
      return {};
    }
  }

  /// Toggle bookmark / save on post in public.post_bookmarks
  Future<bool> togglePostBookmark(String postId, bool isCurrentlySaved) async {
    final user = _currentUser;
    if (user == null) return !isCurrentlySaved;

    try {
      if (isCurrentlySaved) {
        await _client
            .from('post_bookmarks')
            .delete()
            .match({'post_id': postId, 'user_id': user.id});
        return false;
      } else {
        await _client.from('post_bookmarks').insert({
          'post_id': postId,
          'user_id': user.id,
        });
        return true;
      }
    } catch (e) {
      debugPrint('Error togglePostBookmark: $e');
      return isCurrentlySaved;
    }
  }

  /// Fetch set of post IDs bookmarked by current user
  Future<Set<String>> fetchBookmarkedPostIds() async {
    final user = _currentUser;
    if (user == null) return {};

    try {
      final response = await _client
          .from('post_bookmarks')
          .select('post_id')
          .eq('user_id', user.id);

      final set = (response as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((e) => e['post_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      return set;
    } catch (e) {
      debugPrint('Error fetchBookmarkedPostIds: $e');
      return {};
    }
  }

  /// Fetch comments for a post joined with user profiles
  Future<List<PostCommentModel>> fetchPostComments(String postId) async {
    try {
      final response = await _client
          .from('post_comments')
          .select('*, user:profiles!post_comments_user_id_fkey(*)')
          .eq('post_id', postId)
          .order('created_at', ascending: true);

      return (response as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((json) => PostCommentModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetchPostComments: $e');
      return [];
    }
  }

  /// Add a comment to a post
  Future<PostCommentModel> addComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('Anda harus masuk untuk menambahkan komentar.');
    }

    try {
      final inserted = await _client
          .from('post_comments')
          .insert({
            'post_id': postId,
            'user_id': user.id,
            'content': content,
            if (parentCommentId != null) 'parent_comment_id': parentCommentId,
          })
          .select('*, user:profiles!post_comments_user_id_fkey(*)')
          .single();

      return PostCommentModel.fromJson(inserted);
    } catch (e) {
      debugPrint('Error addComment: $e');
      rethrow;
    }
  }

  /// Search posts by keyword in caption or title
  Future<List<MarketPostModel>> searchPosts(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final clean = query.trim();
      final response = await _client
          .from('market_posts')
          .select('*, seller:profiles!market_posts_seller_id_fkey(*)')
          .or('caption.ilike.%$clean%,title.ilike.%$clean%,location_tag.ilike.%$clean%')
          .order('created_at', ascending: false)
          .limit(30);

      final rawList = (response as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((json) => MarketPostModel.fromJson(json))
          .toList();

      return await PollSyncService.instance.hydrateAndSyncPosts(
        client: _client,
        posts: rawList,
      );
    } catch (e) {
      debugPrint('Error searchPosts: $e');
      return [];
    }
  }
}
