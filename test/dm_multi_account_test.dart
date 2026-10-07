import 'package:flutter_test/flutter_test.dart';
import 'package:snapan_market/features/messages/models/conversation_model.dart';
import 'package:snapan_market/features/messages/models/chat_message_model.dart';
import 'package:snapan_market/features/messages/services/direct_messages_service.dart';

void main() {
  group('SNAPS-42: DirectMessagesService Multi-Account Isolation Tests', () {
    late DirectMessagesService service;

    setUp(() {
      service = DirectMessagesService.instance;
      service.clear();
    });

    tearDown(() {
      service.clear();
    });

    test('Initial state of DirectMessagesService is completely clean', () {
      expect(service.conversations, isEmpty);
      expect(service.totalUnreadCount, equals(0));
      expect(service.getMessages('any-id'), isEmpty);
    });

    test('clear() purges conversations and messages across accounts', () {
      // 1. Simulate Account A adding a conversation and messages
      const convA = ConversationModel(
        id: 'conv-user-a',
        user: ConversationUser(
          id: 'user-2',
          name: 'Budi Santoso',
          username: 'budi',
          avatar: '',
        ),
        lastMessage: 'Halo bro ini chat rahasia akun A',
        timestamp: '10:00',
        unreadCount: 3,
      );

      final msgA = ChatMessageModel(
        id: 'msg-1',
        senderId: 'account-a-id',
        text: 'Halo bro ini chat rahasia akun A',
        timestamp: '10:00',
        isMe: true,
      );

      service.addOrUpdateConversation(convA);
      service.addMessage('conv-user-a', msgA);

      expect(service.conversations.length, equals(1));
      expect(service.conversations.first.id, equals('conv-user-a'));
      expect(service.getMessages('conv-user-a').length, equals(1));
      expect(service.totalUnreadCount, equals(3));

      // 2. User logs out (triggers clear())
      service.clear();

      // Verify memory is 100% purged
      expect(service.conversations, isEmpty);
      expect(service.getMessages('conv-user-a'), isEmpty);
      expect(service.totalUnreadCount, equals(0));

      // 3. Simulate Account B logging in and having its own distinct conversation
      const convB = ConversationModel(
        id: 'conv-user-b',
        user: ConversationUser(
          id: 'user-3',
          name: 'Siti Aminah',
          username: 'siti',
          avatar: '',
        ),
        lastMessage: 'Chat khusus akun B',
        timestamp: '11:00',
        unreadCount: 0,
      );

      service.addOrUpdateConversation(convB);

      // Verify Account B never sees Account A's conversations or messages
      expect(service.conversations.length, equals(1));
      expect(service.conversations.first.id, equals('conv-user-b'));
      expect(service.conversations.any((c) => c.id == 'conv-user-a'), isFalse);
      expect(service.getMessages('conv-user-a'), isEmpty);
    });

    test('Replacing conversation list avoids retaining ghost conversations', () {
      const oldConv = ConversationModel(
        id: 'old-conv',
        user: ConversationUser(name: 'User 1', username: 'user1', avatar: ''),
        lastMessage: 'Old message',
        timestamp: '09:00',
      );
      service.addOrUpdateConversation(oldConv);
      expect(service.conversations.length, equals(1));

      // Clear on account change
      service.clear();

      const newConv = ConversationModel(
        id: 'new-conv',
        user: ConversationUser(name: 'User 2', username: 'user2', avatar: ''),
        lastMessage: 'New message',
        timestamp: '12:00',
      );
      service.addOrUpdateConversation(newConv);

      expect(service.conversations.length, equals(1));
      expect(service.conversations.first.id, equals('new-conv'));
      expect(service.conversations.map((c) => c.id), isNot(contains('old-conv')));
    });
  });
}
