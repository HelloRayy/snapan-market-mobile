import 'package:flutter/foundation.dart';
import 'package:snapan_market/features/messages/models/conversation_model.dart';
import 'package:snapan_market/features/messages/models/chat_message_model.dart';

/// Singleton service to manage live Direct Message conversations & message history
class DirectMessagesService extends ChangeNotifier {
  static final DirectMessagesService instance = DirectMessagesService._internal();
  DirectMessagesService._internal();

  final List<ConversationModel> _conversations = [];
  final Map<String, List<ChatMessageModel>> _conversationMessages = {};

  List<ConversationModel> get conversations => List.unmodifiable(_conversations);

  List<ChatMessageModel> getMessages(String conversationId) {
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
    _conversationMessages[conversationId]!.add(msg);

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
}
