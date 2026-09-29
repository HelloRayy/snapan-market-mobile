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
  }  /// Fetch user profile by username from public.profiles
  Future<Map<String, dynamic>?> getProfileByUsername(String username) async {
    try {
      final data = await client
          .from('profiles')
          .select()
          .ilike('username', username)
          .maybeSingle();
      return data;
    } catch (e) {
      debugPrint('Error getProfileByUsername: $e');
      return null;
    }
  }


  /// Subscribe to live realtime changes for a specific user profile
  RealtimeChannel subscribeToProfile(
    String userId,
    void Function(Map<String, dynamic> newRecord) onUpdate,
  ) {
    return client
        .channel('public:profiles:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'profiles',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: userId,
          ),
          callback: (PostgresChangePayload payload) {
            if (payload.newRecord.isNotEmpty) {
              onUpdate(payload.newRecord);
            }
          },
        )
        .subscribe();
  }

  /// Save or update profile completion and synchronize auth user metadata
  Future<void> updateProfile({
    required String userId,
    required String fullName,
    required String username,
    required String classGroup,
    String? avatarUrl,
    String? bio,
    List<String>? tags,
    String? link,
  }) async {
    // 1. Update Supabase Auth user metadata so session & currentUser stay in sync
    try {
      await client.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': fullName,
            'username': username,
            'class_group': classGroup,
            if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatar_url': avatarUrl,
            if (bio != null) 'bio': bio,
            if (tags != null) 'tags': tags,
            if (link != null) 'link': link,
          },
        ),
      );
    } catch (authErr) {
      debugPrint('Warning: updateUser metadata failed: $authErr');
    }

    // 2. Prepare payload for public.profiles table
    final fullPayload = <String, dynamic>{
      'full_name': fullName,
      'username': username,
      'class_group': classGroup,
      if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatar_url': avatarUrl,
      if (bio != null) 'bio': bio,
      if (link != null) 'link': link,
      if (tags != null) 'interests': tags.join(','),
    };

    final corePayload = <String, dynamic>{
      'full_name': fullName,
      'username': username,
      'class_group': classGroup,
      if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatar_url': avatarUrl,
    };

    // 3. Update public.profiles table (try full payload first, fallback to core payload if columns don't exist)
    try {
      await client.from('profiles').update(fullPayload).eq('id', userId);
    } catch (e) {
      debugPrint('updateProfile full payload update failed, retrying core payload: $e');
      try {
        await client.from('profiles').update(corePayload).eq('id', userId);
      } catch (coreErr) {
        debugPrint('Warning updateProfile core update failed: $coreErr');
        final fallbackPayload = {
          'id': userId,
          ...corePayload,
        };
        await client.from('profiles').upsert(fallbackPayload).catchError((err) {
          debugPrint('Warning updateProfile upsert fallback failed: $err');
        });
      }
    }
  }

  /// Check if a username is already taken by another account
  Future<bool> isUsernameTaken(String username) async {
    try {
      final clean = username.toLowerCase().replaceAll('@', '').trim();
      final res = await client
          .from('profiles')
          .select('id')
          .eq('username', clean)
          .maybeSingle();
      return res != null;
    } catch (e) {
      debugPrint('Error isUsernameTaken: $e');
      return false;
    }
  }

  /// Upload an image to Supabase Storage and return its public URL.
  /// [bytes] binary data of the image.
  /// [fileName] original filename (used to extract extension or generate unique name).
  /// [bucket] default is 'market-media', or 'avatars'.
  Future<String?> uploadImage({
    required Uint8List bytes,
    required String fileName,
    String bucket = 'market-media',
  }) async {
    try {
      final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
      final mimeType = ext == 'png'
          ? 'image/png'
          : ext == 'webp'
              ? 'image/webp'
              : 'image/jpeg';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = (1000 + (DateTime.now().microsecond % 9000)).toString();
      final path = '$timestamp-$random.$ext';

      await client.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: mimeType,
              upsert: true,
            ),
          );

      final publicUrl = client.storage.from(bucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploadImage to Supabase Storage: $e');
      return null;
    }
  }

  // --- FEED & POSTS ---

  /// Fetch live feed posts joined with profiles
  Future<List<MarketPostModel>> fetchFeedPosts({
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('market_posts')
          .select('*, seller:profiles!market_posts_seller_id_fkey(*)')
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
  }) async {
    final user = currentUser;
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
      'location_tag': (locationTag != null && locationTag.trim().isNotEmpty) ? locationTag.trim() : 'SMKN8 Semarang - Snapan',
      if (topicTag != null && topicTag.isNotEmpty) 'topic_tag': topicTag,
      'images': images,
    };

    try {
      final inserted = await client
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

  bool? _isAdminCache;
  String? _isAdminCachedUserId;

  /// Check if the currently logged-in user has an admin role
  Future<bool> isCurrentUserAdmin() async {
    final user = currentUser;
    if (user == null) return false;
    if (_isAdminCachedUserId == user.id && _isAdminCache != null) {
      return _isAdminCache!;
    }

    try {
      final res = await client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      final role = res?['role'] as String?;
      _isAdminCache = role == 'admin';
      _isAdminCachedUserId = user.id;
      return _isAdminCache!;
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      return false;
    }
  }

  /// Delete a post created by current user, or any post if caller is admin
  Future<void> deletePost(String postId, {bool asAdmin = false}) async {
    final user = currentUser;
    if (user == null) return;

    try {
      if (asAdmin) {
        await client.from('market_posts').delete().eq('id', postId);
      } else {
        await client
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
      final response = await client
          .from('market_posts')
          .select('*, seller:profiles!market_posts_seller_id_fkey(*)')
          .eq('seller_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((json) => MarketPostModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetchUserPosts: $e');
      return [];
    }
  }

  // --- LIKES & BOOKMARKS ---

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

  /// Fetch set of post IDs liked by current user
  Future<Set<String>> fetchLikedPostIds() async {
    final user = currentUser;
    if (user == null) return {};

    try {
      final response = await client
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
    final user = currentUser;
    if (user == null) return !isCurrentlySaved;

    try {
      if (isCurrentlySaved) {
        await client
            .from('post_bookmarks')
            .delete()
            .match({'post_id': postId, 'user_id': user.id});
        return false;
      } else {
        await client.from('post_bookmarks').insert({
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
    final user = currentUser;
    if (user == null) return {};

    try {
      final response = await client
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

  // --- COMMENTS ---

  /// Fetch comments for a post joined with user profiles
  Future<List<PostCommentModel>> fetchPostComments(String postId) async {
    try {
      final response = await client
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
    final user = currentUser;
    if (user == null) {
      throw Exception('Anda harus masuk untuk menambahkan komentar.');
    }

    try {
      final inserted = await client
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

  // --- SEARCH ---

  /// Search posts by keyword in caption or title
  Future<List<MarketPostModel>> searchPosts(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final clean = query.trim();
      final response = await client
          .from('market_posts')
          .select('*, seller:profiles!market_posts_seller_id_fkey(*)')
          .or('caption.ilike.%$clean%,title.ilike.%$clean%,location_tag.ilike.%$clean%')
          .order('created_at', ascending: false)
          .limit(30);

      return (response as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((json) => MarketPostModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error searchPosts: $e');
      return [];
    }
  }

  /// Search user profiles by name or username
  Future<List<Map<String, dynamic>>> searchProfiles(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final clean = query.trim();
      final response = await client
          .from('profiles')
          .select()
          .or('full_name.ilike.%$clean%,username.ilike.%$clean%')
          .limit(20);

      return (response as List<dynamic>).whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      debugPrint('Error searchProfiles: $e');
      return [];
    }
  }

  // --- NOTIFICATIONS ---

  /// Fetch notifications for current user
  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final response = await client
          .from('notifications')
          .select('*, actor:profiles!notifications_actor_id_fkey(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(40);

      return (response as List<dynamic>).whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      debugPrint('Error fetchNotifications: $e');
      return [];
    }
  }

  /// Mark all notifications as read for current user
  Future<void> markNotificationsAsRead() async {
    final user = currentUser;
    if (user == null) return;

    try {
      await client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id);
    } catch (e) {
      debugPrint('Error markNotificationsAsRead: $e');
    }
  }

  // --- DIRECT MESSAGES (REALTIME CHAT) ---

  /// Fetch all active conversations for the authenticated user
  Future<List<Map<String, dynamic>>> fetchConversations() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final response = await client
          .from('conversations')
          .select('*, participant_one_profile:profiles!conversations_participant_one_fkey(*), participant_two_profile:profiles!conversations_participant_two_fkey(*), product:market_posts(*)')
          .or('participant_one.eq.${user.id},participant_two.eq.${user.id}')
          .order('last_message_at', ascending: false);

      return (response as List<dynamic>).whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      debugPrint('Error fetchConversations: $e');
      return [];
    }
  }

  /// Get existing conversation or create a new one between two users
  Future<String?> getOrCreateConversation({
    required String otherUserId,
    String? productId,
  }) async {
    final user = currentUser;
    if (user == null || user.id == otherUserId) return null;

    try {
      final existing = await client
          .from('conversations')
          .select('id')
          .or('and(participant_one.eq.${user.id},participant_two.eq.$otherUserId),and(participant_one.eq.$otherUserId,participant_two.eq.${user.id})')
          .maybeSingle();

      if (existing != null && existing['id'] != null) {
        return existing['id'] as String;
      }

      final inserted = await client.from('conversations').insert({
        'participant_one': user.id,
        'participant_two': otherUserId,
        if (productId != null) 'product_id': productId,
        'last_message': '',
        'last_message_at': DateTime.now().toUtc().toIso8601String(),
      }).select('id').single();

      return inserted['id'] as String;
    } catch (e) {
      debugPrint('Error getOrCreateConversation: $e');
      return null;
    }
  }

  /// Fetch all messages for a specific conversation
  Future<List<Map<String, dynamic>>> fetchMessages(String conversationId) async {
    try {
      final response = await client
          .from('direct_messages')
          .select('*, sender:profiles!direct_messages_sender_id_fkey(*)')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      return (response as List<dynamic>).whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      debugPrint('Error fetchMessages: $e');
      return [];
    }
  }

  /// Send a direct message in a conversation and update last_message timestamp
  Future<Map<String, dynamic>?> sendDirectMessage({
    required String conversationId,
    required String text,
  }) async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final inserted = await client.from('direct_messages').insert({
        'conversation_id': conversationId,
        'sender_id': user.id,
        'message_text': text,
        'is_read': false,
      }).select('*, sender:profiles!direct_messages_sender_id_fkey(*)').single();

      // Update conversation last_message & timestamp
      await client.from('conversations').update({
        'last_message': text,
        'last_message_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', conversationId);

      return inserted;
    } catch (e) {
      debugPrint('Error sendDirectMessage: $e');
      return null;
    }
  }

  /// Subscribe to live realtime messages for a specific conversation
  RealtimeChannel subscribeToMessages(
    String conversationId,
    void Function(Map<String, dynamic> msg) onNewMessage,
  ) {
    return client
        .channel('dm_$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'direct_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            onNewMessage(payload.newRecord);
          },
        )
        .subscribe();
  }

  /// Subscribe to live realtime conversation inbox updates
  RealtimeChannel subscribeToInbox(void Function() onInboxUpdated) {
    return client
        .channel('inbox_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'conversations',
          callback: (_) {
            onInboxUpdated();
          },
        )
        .subscribe();
  }

  // --- SOCIAL FOLLOWS ---

  /// Fetch all followings for the authenticated user
  Future<List<Map<String, dynamic>>> fetchFollowings() async {
    final user = currentUser;
    if (user == null) return [];
    try {
      final res = await client
          .from('user_follows')
          .select('following_id, following:profiles!user_follows_following_id_fkey(id, username)')
          .eq('follower_id', user.id);
      return (res as List<dynamic>).whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      debugPrint('Error fetchFollowings: $e');
      return [];
    }
  }

  /// Follow a target user
  Future<bool> followUser(String targetUserId) async {
    final user = currentUser;
    if (user == null || user.id == targetUserId) return false;
    try {
      await client.from('user_follows').insert({
        'follower_id': user.id,
        'following_id': targetUserId,
      });

      // Send in-app notification to target user
      try {
        await client.from('notifications').insert({
          'user_id': targetUserId,
          'actor_id': user.id,
          'type': 'follow',
          'message': 'mulai mengikuti profil Anda.',
        });
      } catch (_) {}

      return true;
    } catch (e) {
      debugPrint('Error followUser: $e');
      return false;
    }
  }

  /// Unfollow a target user
  Future<bool> unfollowUser(String targetUserId) async {
    final user = currentUser;
    if (user == null) return false;
    try {
      await client
          .from('user_follows')
          .delete()
          .eq('follower_id', user.id)
          .eq('following_id', targetUserId);
      return true;
    } catch (e) {
      debugPrint('Error unfollowUser: $e');
      return false;
    }
  }
}
