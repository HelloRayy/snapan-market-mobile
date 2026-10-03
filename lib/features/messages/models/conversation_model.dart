/// Model data percakapan untuk halaman Direct Messages (Pesan)
class ConversationUser {
  final String? id;
  final String name;
  final String username;
  final String avatar;
  final String? classGroup;
  final bool isVerified;
  final bool isOnline;

  const ConversationUser({
    this.id,
    required this.name,
    required this.username,
    required this.avatar,
    this.classGroup,
    this.isVerified = false,
    this.isOnline = false,
  });

  ConversationUser copyWith({
    String? id,
    String? name,
    String? username,
    String? avatar,
    String? classGroup,
    bool? isVerified,
    bool? isOnline,
  }) {
    return ConversationUser(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      classGroup: classGroup ?? this.classGroup,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
    );
  }
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
  final String? productId;
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
    this.productId,
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
    String? productId,
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
      productId: productId ?? this.productId,
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

    final otherUserId = otherProfile['id'] as String? ??
        (isParticipantOne ? json['participant_two'] as String? : json['participant_one'] as String?);

    return ConversationModel(
      id: json['id'] as String? ?? '',
      productId: json['product_id'] as String?,
      user: ConversationUser(
        id: otherUserId,
        name: otherProfile['full_name'] as String? ?? otherProfile['username'] as String? ?? 'Siswa',
        username: otherProfile['username'] as String? ?? 'user',
        avatar: otherProfile['avatar_url'] as String? ?? '',
        classGroup: otherProfile['class_group'] as String? ?? 'SMKN 8 Semarang',
        isVerified: otherProfile['is_verified'] == true,
      ),
      lastMessage: json['last_message'] as String? ?? '',
      timestamp: timeStr,
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      isSender: json['last_message_sender_id'] == currentUserId,
      isRequest: json['product_id'] != null,
      productContext: productCtx,
    );
  }
}
