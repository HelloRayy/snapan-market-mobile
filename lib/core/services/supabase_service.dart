import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snapan_market/core/constants/supabase_constants.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  // --- AUTHENTICATION ---

  User? get currentUser => client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  Stream<AuthState> get onAuthStateChange => client.auth.onAuthStateChange;

  /// Trigger Google OAuth flow via deep link
  Future<bool> signInWithGoogle() async {
    try {
      final success = await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: '${SupabaseConstants.authCallbackUrlScheme}://login-callback',
      );
      return success;
    } catch (e) {
      debugPrint('Error signInWithGoogle: $e');
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      debugPrint('Error signOut: $e');
      rethrow;
    }
  }

  /// Fetch user profile from public.profiles
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final data = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return data;
    } catch (e) {
      debugPrint('Error getProfile: $e');
      return null;
    }
  }

  /// Save or update profile completion
  Future<void> updateProfile({
    required String userId,
    required String fullName,
    required String username,
    required String classGroup,
    String? avatarUrl,
  }) async {
    try {
      await client.from('profiles').upsert({
        'id': userId,
        'full_name': fullName,
        'username': username,
        'class_group': classGroup,
        if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatar_url': avatarUrl,
      });
    } catch (e) {
      debugPrint('Error updateProfile: $e');
      rethrow;
    }
  }

  // --- FEED & POSTS ---

  /// Fetch live feed posts joined with profiles
  Future<List<MarketPostModel>> fetchFeedPosts({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('market_posts')
          .select('*, profiles(*)')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final list = (response as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((json) => MarketPostModel.fromJson(json))
          .toList();

      return list;
    } catch (e) {
      debugPrint('Error fetchFeedPosts: $e');
      rethrow;
    }
  }

  /// Toggle like on post in public.post_likes
  Future<bool> togglePostLike(String postId, bool isCurrentlyLiked) async {
    final user = currentUser;
    if (user == null) return !isCurrentlyLiked;

    try {
      if (isCurrentlyLiked) {
        await client
            .from('post_likes')
            .delete()
            .match({'post_id': postId, 'user_id': user.id});
        return false;
      } else {
        await client.from('post_likes').insert({
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
}
