import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snapan_market/core/models/mascot_flair_model.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';
import 'package:snapan_market/core/services/supabase/supabase_auth_service.dart';
import 'package:snapan_market/core/services/supabase/supabase_profile_service.dart';
import 'package:snapan_market/core/services/supabase/supabase_feed_service.dart';
import 'package:snapan_market/core/services/supabase/supabase_chat_service.dart';
import 'package:snapan_market/core/services/supabase/supabase_social_service.dart';
import 'package:snapan_market/core/services/supabase/supabase_storage_service.dart';
import 'package:snapan_market/core/services/supabase/supabase_poll_service.dart';

export 'package:snapan_market/core/services/supabase/supabase_auth_service.dart';
export 'package:snapan_market/core/services/supabase/supabase_profile_service.dart';
export 'package:snapan_market/core/services/supabase/supabase_feed_service.dart';
export 'package:snapan_market/core/services/supabase/supabase_chat_service.dart';
export 'package:snapan_market/core/services/supabase/supabase_social_service.dart';
export 'package:snapan_market/core/services/supabase/supabase_storage_service.dart';
export 'package:snapan_market/core/services/supabase/supabase_poll_service.dart';

/// Unified Facade for Supabase services across Snaps Mobile.
/// Decomposed into domain-specific modules under `lib/core/services/supabase/`.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  // Domain service accessors
  late final SupabaseAuthService auth = SupabaseAuthService(client);
  late final SupabaseProfileService profile = SupabaseProfileService(client);
  late final SupabaseFeedService feed = SupabaseFeedService(client);
  late final SupabaseChatService chat = SupabaseChatService(client);
  late final SupabaseSocialService social = SupabaseSocialService(client);
  late final SupabaseStorageService storage = SupabaseStorageService(client);
  late final SupabasePollService poll = SupabasePollService(client);

  // --- AUTH DELEGATIONS ---
  User? get currentUser {
    try {
      return auth.currentUser;
    } catch (_) {
      return null;
    }
  }
  String? get currentUserId => currentUser?.id;
  bool get isAuthenticated => currentUser != null;
  Stream<AuthState> get onAuthStateChange => auth.onAuthStateChange;
  Future<bool> signInWithGoogle() => auth.signInWithGoogle();
  Future<void> signOut() {
    profile.currentUserProfileNotifier.value = null;
    return auth.signOut();
  }
  Future<bool> isCurrentUserAdmin() => auth.isCurrentUserAdmin();

  // --- STORAGE DELEGATIONS ---
  Future<String?> uploadImage({
    required Uint8List bytes,
    required String fileName,
    String bucket = 'market-media',
  }) =>
      storage.uploadImage(bytes: bytes, fileName: fileName, bucket: bucket);

  Future<bool> deleteImage({
    required String urlOrPath,
    String bucket = 'market-media',
  }) =>
      storage.deleteImage(urlOrPath: urlOrPath, bucket: bucket);

  Future<bool> deleteImages({
    required List<String> urlsOrPaths,
    String bucket = 'market-media',
  }) =>
      storage.deleteImages(urlsOrPaths: urlsOrPaths, bucket: bucket);

  // --- PROFILE DELEGATIONS ---
  ValueNotifier<Map<String, dynamic>?> get currentUserProfileNotifier =>
      profile.currentUserProfileNotifier;

  Future<Map<String, dynamic>?> getProfile(String userId) =>
      profile.getProfile(userId);

  Future<Map<String, dynamic>?> getProfileByUsername(String username) =>
      profile.getProfileByUsername(username);

  Future<Map<String, dynamic>?> getProfileByNis(String nis) =>
      profile.getProfileByNis(nis);

  Future<bool> isNisClaimed(String nis) =>
      profile.isNisClaimed(nis);

  RealtimeChannel subscribeToProfile(
    String userId,
    void Function(Map<String, dynamic> newRecord) onUpdate,
  ) =>
      profile.subscribeToProfile(userId, onUpdate);

  Future<void> updateProfile({
    required String userId,
    required String fullName,
    String? displayName,
    required String username,
    required String classGroup,
    String? nis,
    String? avatarUrl,
    String? bio,
    List<String>? tags,
    String? link,
    Map<String, dynamic>? mascotFlair,
  }) =>
      profile.updateProfile(
        userId: userId,
        fullName: fullName,
        displayName: displayName,
        username: username,
        classGroup: classGroup,
        nis: nis,
        avatarUrl: avatarUrl,
        bio: bio,
        tags: tags,
        link: link,
        mascotFlair: mascotFlair,
      );

  Future<bool> isUsernameTaken(String username) =>
      profile.isUsernameTaken(username);

  Future<List<Map<String, dynamic>>> searchProfiles(String query) =>
      profile.searchProfiles(query);

  Future<List<Map<String, dynamic>>> fetchSuggestedProfiles({int limit = 15}) =>
      profile.fetchSuggestedProfiles(limit: limit);

  Future<void> syncProfileAuthCredentials() =>
      profile.syncProfileAuthCredentials();

  // --- FEED & POST DELEGATIONS ---
  List<MarketPostModel> get cachedFeedPosts => feed.cachedFeedPosts;
  bool get hasCachedFeedPosts => feed.hasCachedFeedPosts;

  Future<List<MarketPostModel>> fetchFeedPosts({
    int limit = 15,
    int offset = 0,
  }) =>
      feed.fetchFeedPosts(limit: limit, offset: offset);

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
    MascotFlairModel? mascotFlair,
  }) =>
      feed.createPost(
        postType: postType,
        caption: caption,
        title: title,
        description: description,
        price: price,
        originalPrice: originalPrice,
        stock: stock,
        category: category,
        locationTag: locationTag,
        topicTag: topicTag,
        images: images,
        poll: poll,
        mascotFlair: mascotFlair,
      );

  Future<int?> recordPostView(String postId, {required String deviceId}) =>
      feed.recordPostView(postId, deviceId: deviceId);

  // --- POLL DELEGATIONS ---
  Future<PostPollModel> votePoll({
    required String postId,
    required List<String> optionIds,
  }) =>
      poll.votePoll(postId: postId, optionIds: optionIds);

  Future<PostPollModel> closePoll(String postId) => poll.closePoll(postId);

  Future<void> deletePost(String postId, {bool asAdmin = false}) =>
      feed.deletePost(postId, asAdmin: asAdmin);

  Future<MarketPostModel?> fetchPostById(String postId) =>
      feed.fetchPostById(postId);

  Future<List<MarketPostModel>> fetchUserPosts(String userId) =>
      feed.fetchUserPosts(userId);

  Future<bool> togglePostLike(String postId, bool isCurrentlyLiked) =>
      feed.togglePostLike(postId, isCurrentlyLiked);

  Future<Set<String>> fetchLikedPostIds() => feed.fetchLikedPostIds();

  Future<bool> togglePostBookmark(String postId, bool isCurrentlySaved) =>
      feed.togglePostBookmark(postId, isCurrentlySaved);

  Future<Set<String>> fetchBookmarkedPostIds() =>
      feed.fetchBookmarkedPostIds();

  Future<List<PostCommentModel>> fetchPostComments(String postId) =>
      feed.fetchPostComments(postId);

  Future<bool> toggleCommentLike(String commentId, bool isCurrentlyLiked) =>
      feed.toggleCommentLike(commentId, isCurrentlyLiked);

  Future<PostCommentModel> addComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) =>
      feed.addComment(
        postId: postId,
        content: content,
        parentCommentId: parentCommentId,
      );

  Future<void> deleteComment(String commentId) =>
      feed.deleteComment(commentId);

  Future<List<MarketPostModel>> searchPosts(String query) =>
      feed.searchPosts(query);

  Future<void> reportPost({
    required String postId,
    required String reason,
    String? details,
  }) =>
      feed.reportPost(
        postId: postId,
        reason: reason,
        details: details,
      );

  // --- CHAT & DM DELEGATIONS ---
  Future<List<Map<String, dynamic>>> fetchConversations() =>
      chat.fetchConversations();

  Future<Map<String, dynamic>?> fetchConversationById(String conversationId) =>
      chat.fetchConversationById(conversationId);

  Future<String?> getOrCreateConversation({
    required String otherUserId,
    String? productId,
  }) =>
      chat.getOrCreateConversation(
        otherUserId: otherUserId,
        productId: productId,
      );

  Future<List<Map<String, dynamic>>> fetchMessages(String conversationId) =>
      chat.fetchMessages(conversationId);

  Future<Map<String, dynamic>?> sendDirectMessage({
    required String conversationId,
    required String text,
  }) =>
      chat.sendDirectMessage(
        conversationId: conversationId,
        text: text,
      );

  Future<void> markMessagesAsRead(String conversationId) =>
      chat.markMessagesAsRead(conversationId);

  RealtimeChannel subscribeToMessages(
    String conversationId,
    void Function(Map<String, dynamic> msg) onNewMessage, {
    void Function(Map<String, dynamic> updatedMsg)? onMessageUpdated,
  }) =>
      chat.subscribeToMessages(
        conversationId,
        onNewMessage,
        onMessageUpdated: onMessageUpdated,
      );

  RealtimeChannel subscribeToInbox(void Function() onInboxUpdated) =>
      chat.subscribeToInbox(onInboxUpdated);

  // --- SOCIAL & NOTIFICATION DELEGATIONS ---
  Future<List<Map<String, dynamic>>> fetchNotifications() =>
      social.fetchNotifications();

  Future<void> markNotificationsAsRead() =>
      social.markNotificationsAsRead();

  Future<void> markSingleNotificationAsRead(String notificationId) =>
      social.markSingleNotificationAsRead(notificationId);

  Future<int> getUnreadNotificationsCount() =>
      social.getUnreadNotificationsCount();

  RealtimeChannel subscribeToNotifications(void Function(Map<String, dynamic> record) onNewNotification) =>
      social.subscribeToNotifications(onNewNotification);

  Future<List<Map<String, dynamic>>> fetchFollowings() =>
      social.fetchFollowings();

  Future<bool> followUser(String targetUserId) =>
      social.followUser(targetUserId);

  Future<bool> unfollowUser(String targetUserId) =>
      social.unfollowUser(targetUserId);

  Future<int> getFollowersCount(String userId) =>
      social.getFollowersCount(userId);

  Future<int> getFollowingCount(String userId) =>
      social.getFollowingCount(userId);

  RealtimeChannel subscribeToFollowers(
    String userId,
    void Function() onFollowChange,
  ) =>
      social.subscribeToFollowers(userId, onFollowChange);

  Future<void> saveFcmToken(String token) => social.saveFcmToken(token);
}
