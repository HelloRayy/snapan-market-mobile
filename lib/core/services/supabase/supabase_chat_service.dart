import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service dedicated to Direct Messages and Realtime Chat via Supabase.
class SupabaseChatService {
  SupabaseChatService(this._client);
  final SupabaseClient _client;

  User? get _currentUser => _client.auth.currentUser;

  /// Fetch all active conversations for the authenticated user along with unread counts
  Future<List<Map<String, dynamic>>> fetchConversations() async {
    final user = _currentUser;
    if (user == null) return [];

    try {
      final response = await _client
          .from('conversations')
          .select('*, participant_one_profile:profiles!conversations_participant_one_fkey(*), participant_two_profile:profiles!conversations_participant_two_fkey(*), product:market_posts(*)')
          .or('participant_one.eq.${user.id},participant_two.eq.${user.id}')
          .order('last_message_at', ascending: false);

      final list = (response as List<dynamic>).whereType<Map<String, dynamic>>().map((e) => Map<String, dynamic>.from(e)).toList();
      if (list.isEmpty) return [];

      // Calculate unread message counts per conversation
      final convIds = list.map((c) => c['id'] as String?).whereType<String>().toList();
      if (convIds.isNotEmpty) {
        try {
          final unreadRows = await _client
              .from('direct_messages')
              .select('conversation_id')
              .inFilter('conversation_id', convIds)
              .neq('sender_id', user.id)
              .eq('is_read', false);

          final unreadMap = <String, int>{};
          for (final row in (unreadRows as List<dynamic>)) {
            if (row is Map<String, dynamic>) {
              final cid = row['conversation_id'] as String?;
              if (cid != null) {
                unreadMap[cid] = (unreadMap[cid] ?? 0) + 1;
              }
            }
          }

          for (final conv in list) {
            final cid = conv['id'] as String?;
            conv['unread_count'] = cid != null ? (unreadMap[cid] ?? 0) : 0;
          }
        } catch (e) {
          debugPrint('Error fetching unread counts: $e');
        }
      }

      return list;
    } catch (e) {
      debugPrint('Error fetchConversations: $e');
      return [];
    }
  }

  /// Get existing conversation or create a new one between two users.
  /// Handles both casual chat (productId == null) and product inquiry chat.
  Future<String?> getOrCreateConversation({
    required String otherUserId,
    String? productId,
  }) async {
    final user = _currentUser;
    if (user == null || user.id == otherUserId || otherUserId.isEmpty) return null;

    try {
      final response = await _client
          .from('conversations')
          .select('id, product_id')
          .or('and(participant_one.eq.${user.id},participant_two.eq.$otherUserId),and(participant_one.eq.$otherUserId,participant_two.eq.${user.id})');

      final list = (response as List<dynamic>).whereType<Map<String, dynamic>>().toList();

      if (list.isNotEmpty) {
        if (productId != null) {
          final withProduct = list.firstWhere(
            (c) => c['product_id'] == productId,
            orElse: () => <String, dynamic>{},
          );
          if (withProduct.isNotEmpty && withProduct['id'] != null) {
            return withProduct['id'] as String;
          }
        } else {
          final casual = list.firstWhere(
            (c) => c['product_id'] == null,
            orElse: () => list.first,
          );
          if (casual['id'] != null) {
            return casual['id'] as String;
          }
        }
      }

      final inserted = await _client.from('conversations').insert({
        'participant_one': user.id,
        'participant_two': otherUserId,
        'product_id': ?productId,
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

      // Update conversation snapshot (defense in depth alongside DB trigger)
      final previewText = text.length > 100 ? '${text.substring(0, 100)}…' : text;
      await _client.from('conversations').update({
        'last_message': previewText,
        'last_message_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', conversationId);

      return inserted;
    } catch (e) {
      debugPrint('Error sendDirectMessage: $e');
      return null;
    }
  }

  /// Mark all incoming messages in a conversation as read
  Future<void> markMessagesAsRead(String conversationId) async {
    final user = _currentUser;
    if (user == null) return;

    try {
      await _client
          .from('direct_messages')
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .neq('sender_id', user.id)
          .eq('is_read', false);
    } catch (e) {
      debugPrint('Error markMessagesAsRead: $e');
    }
  }

  /// Subscribe to live realtime messages for a specific conversation (both inserts & updates)
  RealtimeChannel subscribeToMessages(
    String conversationId,
    void Function(Map<String, dynamic> msg) onNewMessage, {
    void Function(Map<String, dynamic> updatedMsg)? onMessageUpdated,
  }) {
    final channel = _client.channel('dm_$conversationId');

    channel.onPostgresChanges(
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
    );

    if (onMessageUpdated != null) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'direct_messages',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'conversation_id',
          value: conversationId,
        ),
        callback: (payload) {
          onMessageUpdated(payload.newRecord);
        },
      );
    }

    return channel.subscribe();
  }

  /// Subscribe to live realtime conversation inbox updates
  RealtimeChannel subscribeToInbox(void Function() onInboxUpdated) {
    final user = _currentUser;
    final channelName = user != null ? 'inbox_channel_${user.id}' : 'inbox_channel_global';

    return _client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'conversations',
          callback: (_) {
            onInboxUpdated();
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'direct_messages',
          callback: (_) {
            onInboxUpdated();
          },
        )
        .subscribe();
  }
}
