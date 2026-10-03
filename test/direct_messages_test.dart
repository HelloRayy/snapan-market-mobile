import 'package:flutter_test/flutter_test.dart';
import 'package:snapan_market/features/messages/models/chat_message_model.dart';
import 'package:snapan_market/features/messages/models/conversation_model.dart';
import 'package:snapan_market/features/messages/services/direct_messages_service.dart';

void main() {
  group('Direct Messages Model & Service Unit Tests', () {
    test('ConversationModel.fromJson parses fields, unread count, and profiles correctly', () {
      final json = {
        'id': 'b83c5093-f4c2-4021-a3f2-171ef9eb7e91',
        'participant_one': 'user-123',
        'participant_two': 'user-456',
        'product_id': 'prod-789',
        'last_message': 'Halo apakah ready?',
        'last_message_at': '2026-10-03T10:30:00Z',
        'unread_count': 3,
        'participant_one_profile': {
          'id': 'user-123',
          'full_name': 'Rayhan Dev',
          'username': 'rayhan',
          'avatar_url': 'https://example.com/avatar1.jpg',
        },
        'participant_two_profile': {
          'id': 'user-456',
          'full_name': 'Ahmad Seller',
          'username': 'ahmad_smk',
          'avatar_url': 'https://example.com/avatar2.jpg',
          'class_group': 'XII RPL 1',
          'is_verified': true,
        },
        'product': {
          'id': 'prod-789',
          'title': 'Modul Praktikum Jaringan',
          'price': 45000,
          'images': ['https://example.com/product.jpg'],
        },
      };

      final conv = ConversationModel.fromJson(json, 'user-123');

      expect(conv.id, 'b83c5093-f4c2-4021-a3f2-171ef9eb7e91');
      expect(conv.user.id, 'user-456');
      expect(conv.user.name, 'Ahmad Seller');
      expect(conv.user.username, 'ahmad_smk');
      expect(conv.user.classGroup, 'XII RPL 1');
      expect(conv.user.isVerified, true);
      expect(conv.unreadCount, 3);
      expect(conv.isRequest, true);
      expect(conv.productContext != null, true);
      expect(conv.productContext!.title, 'Modul Praktikum Jaringan');
      expect(conv.productContext!.price, 'Rp 45000');
    });

    test('DirectMessagesService handles deduplication of optimistic messages', () {
      final service = DirectMessagesService.instance;
      const convId = 'test-conv-dedup-1';

      // 1. Send optimistic message
      final optimisticMsg = ChatMessageModel(
        id: 'temp-123456789',
        senderId: 'user-123',
        text: 'Pesan tes realtime',
        timestamp: '12:00',
        isMe: true,
        status: MessageStatus.sending,
      );
      service.addMessage(convId, optimisticMsg);

      expect(service.getMessages(convId).length, 1);
      expect(service.getMessages(convId).first.id, 'temp-123456789');

      // 2. Incoming confirmed message from Supabase Realtime with real UUID
      final confirmedMsg = ChatMessageModel(
        id: 'c80884df-fec1-4328-86d1-4191d84e8837',
        senderId: 'user-123',
        text: 'Pesan tes realtime',
        timestamp: '12:00',
        isMe: true,
        status: MessageStatus.sent,
      );
      service.addMessage(convId, confirmedMsg);

      // Deduplication must replace temp message, retaining length = 1
      expect(service.getMessages(convId).length, 1);
      expect(service.getMessages(convId).first.id, 'c80884df-fec1-4328-86d1-4191d84e8837');
      expect(service.getMessages(convId).first.status, MessageStatus.sent);
    });

    test('DirectMessagesService updateConversationId migrates message cache and conversation ID', () {
      final service = DirectMessagesService.instance;
      const oldTempId = 'conv-temp-999';
      const realUuid = 'e9c8bc80-0a71-4770-98d6-3e7510cb1056';

      final conv = ConversationModel(
        id: oldTempId,
        user: const ConversationUser(name: 'Budi', username: 'budi', avatar: ''),
        lastMessage: 'Halo Budi',
        timestamp: '14:20',
      );
      service.addOrUpdateConversation(conv);

      final msg = ChatMessageModel(
        id: 'temp-111',
        senderId: 'saya',
        text: 'Halo Budi',
        timestamp: '14:20',
        isMe: true,
      );
      service.addMessage(oldTempId, msg);

      expect(service.getMessages(oldTempId).length, 1);

      // Migrate ID
      service.updateConversationId(oldId: oldTempId, newId: realUuid);

      expect(service.getMessages(oldTempId).isEmpty, true);
      expect(service.getMessages(realUuid).length, 1);
      expect(service.getMessages(realUuid).first.text, 'Halo Budi');

      final updatedConv = service.conversations.firstWhere((c) => c.id == realUuid);
      expect(updatedConv.id, realUuid);
    });
  });
}
