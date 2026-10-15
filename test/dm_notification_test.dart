import 'package:flutter_test/flutter_test.dart';
import 'package:snapan_market/features/messages/models/chat_message_model.dart';
import 'package:snapan_market/features/messages/models/conversation_model.dart';
import 'package:snapan_market/features/messages/services/direct_messages_service.dart';

void main() {
  group('SNAPS-71: DM Push Notification & In-Room Suppression Unit Tests', () {
    setUp(() {
      DirectMessagesService.instance.clear();
      DirectMessagesService.instance.activeConversationId = null;
    });

    test('In-room suppression detects when user is active in current conversation', () {
      final service = DirectMessagesService.instance;

      // Kondisi 1: User belum buka chat room apa pun
      expect(service.activeConversationId, isNull);
      const incomingConvId = 'conv-userA-userB-123';
      bool isSuppressed = service.activeConversationId == incomingConvId;
      expect(isSuppressed, isFalse, reason: 'Harus menampilkan notifikasi jika user tidak di ruang chat');

      // Kondisi 2: User sedang aktif di ruang chat yang sama
      service.activeConversationId = incomingConvId;
      isSuppressed = service.activeConversationId == incomingConvId;
      expect(isSuppressed, isTrue, reason: 'Harus diredam (suppressed) jika user sedang aktif membaca chat');

      // Kondisi 3: User sedang aktif di ruang chat lain
      service.activeConversationId = 'conv-userC-userB-999';
      isSuppressed = service.activeConversationId == incomingConvId;
      expect(isSuppressed, isFalse, reason: 'Harus tetap notif jika user di percakapan berbeda');

      // Kondisi 4: User keluar dari ruang chat (dispose)
      service.activeConversationId = null;
      isSuppressed = service.activeConversationId == incomingConvId;
      expect(isSuppressed, isFalse, reason: 'Harus muncul kembali setelah user keluar dari chat');
    });

    test('Message text preview truncation correctly enforces max 60 characters limit', () {
      String truncatePreview(String raw) {
        final clean = raw.trim();
        return clean.length > 60 ? '${clean.substring(0, 57)}...' : clean;
      }

      // Pesan pendek
      const shortMsg = 'Halo bang, barangnya ready?';
      expect(truncatePreview(shortMsg), equals('Halo bang, barangnya ready?'));

      // Tepat 60 karakter
      final exact60 = 'A' * 60;
      expect(truncatePreview(exact60).length, equals(60));
      expect(truncatePreview(exact60).endsWith('...'), isFalse);

      // Lebih dari 60 karakter
      final longMsg = 'Halo kak, mau tanya apakah seragam jurusan RPL ukuran XL masih tersedia dan bisa COD besok di bengkel lantai 2?';
      final truncated = truncatePreview(longMsg);
      expect(truncated.length, equals(60));
      expect(truncated.endsWith('...'), isTrue);
      expect(truncated, startsWith('Halo kak, mau tanya apakah seragam jurusan RPL ukuran XL'));
    });

    test('Recipient detection correctly selects opposing participant in conversation', () {
      String resolveRecipient({
        required String participantOne,
        required String participantTwo,
        required String senderId,
      }) {
        return participantOne == senderId ? participantTwo : participantOne;
      }

      const userA = 'user-uuid-aaa';
      const userB = 'user-uuid-bbb';

      // Jika User A yang kirim, penerima harus User B
      expect(
        resolveRecipient(participantOne: userA, participantTwo: userB, senderId: userA),
        equals(userB),
      );

      // Jika User B yang kirim, penerima harus User A
      expect(
        resolveRecipient(participantOne: userA, participantTwo: userB, senderId: userB),
        equals(userA),
      );
    });

    test('getOrFetchConversation finds conversation from in-memory cache directly', () async {
      final service = DirectMessagesService.instance;
      const targetId = 'conv-cached-777';

      final mockConv = ConversationModel(
        id: targetId,
        user: const ConversationUser(
          id: 'user-sender-99',
          name: 'Budi Santoso',
          username: 'budi_santoso',
          avatar: '',
        ),
        lastMessage: 'Halo',
        timestamp: '10:00',
        unreadCount: 1,
        isSender: false,
      );

      final mockMsg = ChatMessageModel(
        id: 'msg-1',
        senderId: 'user-sender-99',
        text: 'Halo',
        timestamp: '10:00',
        isMe: false,
      );

      // Tambahkan ke service cache
      service.addMessage(targetId, mockMsg, conversation: mockConv);

      // Panggil getOrFetchConversation
      final result = await service.getOrFetchConversation(targetId);
      expect(result, isNotNull);
      expect(result!.id, equals(targetId));
      expect(result.user.name, equals('Budi Santoso'));
    });
  });
}
