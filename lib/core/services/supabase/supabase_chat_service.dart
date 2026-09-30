import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseChatService {
  SupabaseChatService(this._client);
  final SupabaseClient _client;

  User? get _currentUser => _client.auth.currentUser;

  /// Fetch all active conversations for the authenticated user
  Future<List<Map<String, dynamic>>> fetchConversations() async {
    final user = _currentUser;
    if (user == null) return [];

    try {
      final response = await _client
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
    final user = _currentUser;
    if (user == null || user.id == otherUserId) return null;

    try {
      final existing = await _client
          .from('conversations')
          .select('id')
          .or('and(participant_one.eq.${user.id},participant_two.eq.$otherUserId),and(participant_one.eq.$otherUserId,participant_two.eq.${user.id})')
          .maybeSingle();

      if (existing != null && existing['id'] != null) {
        return existing['id'] as String;
      }

      final inserted = await _client.from('conversations').insert({
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
      final response = await _client
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
    final user = _currentUser;
    if (user == null) return null;

    try {
      final inserted = await _client.from('direct_messages').insert({
        'conversation_id': conversationId,
        'sender_id': user.id,
        'message_text': text,
        'is_read': false,
      }).select('*, sender:profiles!direct_messages_sender_id_fkey(*)').single();

      // Update conversation last_message & timestamp
      await _client.from('conversations').update({
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
    return _client
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
    return _client
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
}
