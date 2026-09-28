/// Model pesan individu dalam ruang obrolan 1-on-1
enum MessageStatus { sending, sent, delivered, read }

class ChatMessageModel {
  final String id;
  final String senderId;
  final String text;
  final String timestamp;
  final bool isMe;
  final MessageStatus status;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isMe,
    this.status = MessageStatus.read,
  });

  ChatMessageModel copyWith({
    String? id,
    String? senderId,
    String? text,
    String? timestamp,
    bool? isMe,
    MessageStatus? status,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isMe: isMe ?? this.isMe,
      status: status ?? this.status,
    );
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    final senderId = json['sender_id'] as String? ?? '';
    final createdAt = json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null;
    final timeStr = createdAt != null
        ? "${createdAt.toLocal().hour.toString().padLeft(2, '0')}:${createdAt.toLocal().minute.toString().padLeft(2, '0')}"
        : "Baru saja";

    return ChatMessageModel(
      id: json['id'] as String? ?? '',
      senderId: senderId,
      text: json['message_text'] as String? ?? '',
      timestamp: timeStr,
      isMe: senderId == currentUserId,
      status: json['is_read'] == true ? MessageStatus.read : MessageStatus.sent,
    );
  }
}
