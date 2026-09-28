/// Model data percakapan untuk halaman Direct Messages (Pesan)
class ConversationUser {
  final String name;
  final String username;
  final String avatar;
  final String? classGroup;
  final bool isVerified;
  final bool isOnline;

  const ConversationUser({
    required this.name,
    required this.username,
    required this.avatar,
    this.classGroup,
    this.isVerified = false,
    this.isOnline = false,
  });
}

class ProductContext {
  final String title;
  final String price;
  final String? image;

  const ProductContext({
    required this.title,
    required this.price,
    this.image,
  });
}

class ConversationModel {
  final String id;
  final ConversationUser user;
  final String lastMessage;
  final String timestamp;
  final int unreadCount;
  final bool isSender;
  final bool isSeller;
  final bool isRequest;
  final ProductContext? productContext;

  const ConversationModel({
    required this.id,
    required this.user,
    required this.lastMessage,
    required this.timestamp,
    this.unreadCount = 0,
    this.isSender = false,
    this.isSeller = false,
    this.isRequest = false,
    this.productContext,
  });

  ConversationModel copyWith({
    String? id,
    ConversationUser? user,
    String? lastMessage,
    String? timestamp,
    int? unreadCount,
    bool? isSender,
    bool? isSeller,
    bool? isRequest,
    ProductContext? productContext,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      user: user ?? this.user,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      isSender: isSender ?? this.isSender,
      isSeller: isSeller ?? this.isSeller,
      isRequest: isRequest ?? this.isRequest,
      productContext: productContext ?? this.productContext,
    );
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    final pOne = json['participant_one'] as String? ?? '';
    final isParticipantOne = pOne == currentUserId;
    final otherProfile = (isParticipantOne
        ? json['participant_two_profile']
        : json['participant_one_profile']) as Map<String, dynamic>? ?? {};

    final lastMsgAt = json['last_message_at'] != null
        ? DateTime.tryParse(json['last_message_at'].toString())
        : null;
    final timeStr = lastMsgAt != null
        ? "${lastMsgAt.toLocal().hour.toString().padLeft(2, '0')}:${lastMsgAt.toLocal().minute.toString().padLeft(2, '0')}"
        : "Baru saja";

    ProductContext? productCtx;
    final prod = json['product'] as Map<String, dynamic>?;
    if (prod != null) {
      final images = prod['images'];
      String? firstImage;
      if (images is List && images.isNotEmpty) firstImage = images.first.toString();
      productCtx = ProductContext(
        title: prod['title'] as String? ?? 'Produk',
        price: 'Rp ${(prod['price'] ?? 0)}',
        image: firstImage,
      );
    }

    return ConversationModel(
      id: json['id'] as String? ?? '',
      user: ConversationUser(
        name: otherProfile['full_name'] as String? ?? otherProfile['username'] as String? ?? 'Siswa',
        username: otherProfile['username'] as String? ?? 'user',
        avatar: otherProfile['avatar_url'] as String? ?? '',
        classGroup: otherProfile['class_group'] as String? ?? 'SMKN 8 Jakarta',
        isVerified: otherProfile['is_verified'] == true,
      ),
      lastMessage: json['last_message'] as String? ?? '',
      timestamp: timeStr,
      unreadCount: 0,
      isSender: false,
      isRequest: json['product_id'] != null,
      productContext: productCtx,
    );
  }
}
