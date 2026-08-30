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
}
