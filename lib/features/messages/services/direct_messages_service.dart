import 'package:flutter/foundation.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/features/messages/models/conversation_model.dart';
import 'package:snapan_market/features/messages/models/chat_message_model.dart';

/// Singleton service to manage live Direct Message conversations & message history with Supabase Realtime
class DirectMessagesService extends ChangeNotifier {
  static final DirectMessagesService instance = DirectMessagesService._internal();
  DirectMessagesService._internal();

  final List<ConversationModel> _conversations = [];
  final Map<String, List<ChatMessageModel>> _conversationMessages = {};
  bool _isFetchingConversations = false;

  List<ConversationModel> get conversations => List.unmodifiable(_conversations);
  bool get isFetchingConversations => _isFetchingConversations;

  List<ChatMessageModel> getMessages(String conversationId) {
    return _conversationMessages[conversationId] ?? [];
  }

  /// Load conversations from Supabase if authenticated
  Future<void> loadConversations() async {
    final currentUser = SupabaseService.instance.currentUser;
    if (currentUser == null || _isFetchingConversations) return;

    _isFetchingConversations = true;
    try {
      final records = await SupabaseService.instance.fetchConversations();
      final liveList = records.map((r) => ConversationModel.fromJson(r, currentUser.id)).toList();

      for (final conv in liveList) {
        final existingIdx = _conversations.indexWhere((c) => c.id == conv.id);
        if (existingIdx != -1) {
          _conversations[existingIdx] = conv;
        } else {
          _conversations.add(conv);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loadConversations: $e');
    } finally {
      _isFetchingConversations = false;
    }
  }

  /// Load messages for a conversation from Supabase
  Future<List<ChatMessageModel>> loadMessages(String conversationId) async {
    final currentUser = SupabaseService.instance.currentUser;
    final currentUserId = currentUser?.id ?? '';

    try {
      final records = await SupabaseService.instance.fetchMessages(conversationId);
      if (records.isNotEmpty) {
        final liveMessages = records.map((r) => ChatMessageModel.fromJson(r, currentUserId)).toList();
        _conversationMessages[conversationId] = liveMessages;
        notifyListeners();
        return liveMessages;
      }
    } catch (e) {
      debugPrint('Error loadMessages from Supabase: $e');
    }
    return _conversationMessages[conversationId] ?? [];
  }

  void addOrUpdateConversation(ConversationModel conv) {
    final idx = _conversations.indexWhere((c) => c.id == conv.id || c.user.username == conv.user.username);
    if (idx != -1) {
      _conversations[idx] = conv;
    } else {
      _conversations.insert(0, conv);
    }
    notifyListeners();
  }

  void addMessage(String conversationId, ChatMessageModel msg, {ConversationModel? conversation}) {
    if (!_conversationMessages.containsKey(conversationId)) {
      _conversationMessages[conversationId] = [];
    }
    final exists = _conversationMessages[conversationId]!.any((m) => m.id == msg.id);
    if (!exists) {
      _conversationMessages[conversationId]!.add(msg);
    }

    // Update conversation lastMessage & timestamp
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      _conversations[idx] = _conversations[idx].copyWith(
        lastMessage: msg.text,
        timestamp: msg.timestamp,
        isSender: msg.isMe,
      );
    } else if (conversation != null) {
      _conversations.insert(0, conversation.copyWith(
        lastMessage: msg.text,
        timestamp: msg.timestamp,
        isSender: msg.isMe,
      ));
    }
    notifyListeners();
  }

  /// Send message both optimistically and into Supabase
  Future<void> sendMessage({
    required String conversationId,
    required String text,
    ConversationModel? conversation,
  }) async {
    final currentUser = SupabaseService.instance.currentUser;
    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    // Optimistic UI update
    final tempMsg = ChatMessageModel(
      id: "temp-${now.millisecondsSinceEpoch}",
      senderId: currentUser?.id ?? "saya",
      text: text,
      timestamp: timeStr,
      isMe: true,
      status: MessageStatus.sending,
    );
    addMessage(conversationId, tempMsg, conversation: conversation);

    // Send to Supabase
    if (currentUser != null) {
      String targetConvId = conversationId;
      final isUuid = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);
      if (!isUuid.hasMatch(targetConvId) && conversation != null) {
        final profile = await SupabaseService.instance.getProfileByUsername(conversation.user.username);
        if (profile != null && profile['id'] != null) {
          final realId = await SupabaseService.instance.getOrCreateConversation(
            otherUserId: profile['id'] as String,
          );
          if (realId != null) {
            targetConvId = realId;
          }
        }
      }

      final inserted = await SupabaseService.instance.sendDirectMessage(
        conversationId: targetConvId,
        text: text,
      );
      if (inserted != null) {
        final serverMsg = ChatMessageModel.fromJson(inserted, currentUser.id);
        final msgs = _conversationMessages[conversationId];
        if (msgs != null) {
          final tempIdx = msgs.indexWhere((m) => m.id == tempMsg.id);
          if (tempIdx != -1) {
            msgs[tempIdx] = serverMsg;
            notifyListeners();
          }
        }
      }
    }
  }
}
