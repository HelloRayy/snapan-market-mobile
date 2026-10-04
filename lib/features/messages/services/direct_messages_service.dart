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
  int get totalUnreadCount => _conversations.fold<int>(0, (acc, c) => acc + c.unreadCount);

  List<ChatMessageModel> getMessages(String conversationId) {
    return _conversationMessages[conversationId] ?? [];
  }

  /// Load conversations from Supabase if authenticated
  Future<void> loadConversations() async {
    final currentUser = SupabaseService.instance.currentUser;
    if (currentUser == null || _isFetchingConversations) return;

    _isFetchingConversations = true;
    notifyListeners();
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
      notifyListeners();
    }
  }

  /// Load messages for a conversation from Supabase and mark incoming messages as read
  Future<List<ChatMessageModel>> loadMessages(String conversationId) async {
    final currentUser = SupabaseService.instance.currentUser;
    final currentUserId = currentUser?.id ?? '';

    try {
      final records = await SupabaseService.instance.fetchMessages(conversationId);
      if (records.isNotEmpty) {
        final liveMessages = records.map((r) => ChatMessageModel.fromJson(r, currentUserId)).toList();
        _conversationMessages[conversationId] = liveMessages;
        notifyListeners();

        // Mark incoming messages as read in Supabase & update local conversation badge
        markAsRead(conversationId);

        return liveMessages;
      }
    } catch (e) {
      debugPrint('Error loadMessages from Supabase: $e');
    }
    return _conversationMessages[conversationId] ?? [];
  }

  /// Mark conversation as read locally and in Supabase
  Future<void> markAsRead(String conversationId) async {
    // 1. Supabase background update
    await SupabaseService.instance.markMessagesAsRead(conversationId);

    // 2. Update local unread counter on conversation
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1 && _conversations[idx].unreadCount > 0) {
      _conversations[idx] = _conversations[idx].copyWith(unreadCount: 0);
      notifyListeners();
    }
  }

  /// Migrate conversation ID from temporary placeholder to real UUID
  void updateConversationId({required String oldId, required String newId}) {
    if (oldId == newId) return;

    final msgs = _conversationMessages.remove(oldId);
    if (msgs != null) {
      final existingNewMsgs = _conversationMessages[newId] ?? [];
      for (final m in msgs) {
        if (!existingNewMsgs.any((x) => x.id == m.id)) {
          existingNewMsgs.add(m);
        }
      }
      _conversationMessages[newId] = existingNewMsgs;
    }

    final idx = _conversations.indexWhere((c) => c.id == oldId);
    if (idx != -1) {
      _conversations[idx] = _conversations[idx].copyWith(id: newId);
    }
    notifyListeners();
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

  /// Add message with intelligent deduplication for optimistic updates
  void addMessage(String conversationId, ChatMessageModel msg, {ConversationModel? conversation}) {
    if (!_conversationMessages.containsKey(conversationId)) {
      _conversationMessages[conversationId] = [];
    }

    final msgs = _conversationMessages[conversationId]!;

    // Deduplication: If server sends a confirmed message matching an optimistic temp message, replace it
    if (msg.isMe && !msg.id.startsWith('temp-')) {
      final tempIdx = msgs.lastIndexWhere((m) => m.id.startsWith('temp-') && m.text == msg.text);
      if (tempIdx != -1) {
        msgs[tempIdx] = msg;
      } else if (!msgs.any((m) => m.id == msg.id)) {
        msgs.add(msg);
      }
    } else {
      final exists = msgs.any((m) => m.id == msg.id);
      if (!exists) {
        msgs.add(msg);
      }
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

  /// Update an existing message status (e.g. read receipts from realtime)
  void updateMessage(String conversationId, ChatMessageModel updatedMsg) {
    final msgs = _conversationMessages[conversationId];
    if (msgs != null) {
      final idx = msgs.indexWhere((m) => m.id == updatedMsg.id);
      if (idx != -1) {
        msgs[idx] = updatedMsg;
        notifyListeners();
      }
    }
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

      // Auto-resolve real UUID if still using temporary ID
      if (!isUuid.hasMatch(targetConvId)) {
        String? targetUserId = conversation?.user.id;
        if (targetUserId == null && conversation != null) {
          final profile = await SupabaseService.instance.getProfileByUsername(conversation.user.username);
          targetUserId = profile?['id'] as String?;
        }

        if (targetUserId != null) {
          final realId = await SupabaseService.instance.getOrCreateConversation(
            otherUserId: targetUserId,
            productId: conversation?.productId,
          );
          if (realId != null) {
            updateConversationId(oldId: conversationId, newId: realId);
            targetConvId = realId;
          }
        }
      }

      try {
        final inserted = await SupabaseService.instance.sendDirectMessage(
          conversationId: targetConvId,
          text: text,
        );

        if (inserted != null) {
          final serverMsg = ChatMessageModel.fromJson(inserted, currentUser.id);
          addMessage(targetConvId, serverMsg, conversation: conversation);
        }
      } catch (e) {
        debugPrint('Error sending direct message to Supabase: $e');
      }
    }
  }
}
