import "package:snapan_market/features/messages/models/conversation_model.dart";
import "package:snapan_market/features/messages/models/chat_message_model.dart";

/// Dataset mock percakapan 1:1 dari DirectMessagesPage.tsx
final List<ConversationModel> kMockConversations = [
  const ConversationModel(
    id: "17892348123791823",
    user: ConversationUser(
      name: "Dimas Wicaksono",
      username: "dimas_wicak",
      avatar: "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150&q=80",
      classGroup: "XII DKV 2",
      isOnline: true,
    ),
    lastMessage: "Masih ready banget Dimas! Coretannya minim pakai pensil, bisa dihapus kok 👍",
    timestamp: "12m",
    isSender: true,
    isSeller: true,
    productContext: ProductContext(
      title: "Modul Praktikum Fisika Terapan Kelas XII",
      price: "Rp 45.000",
      image: "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600&q=80",
    ),
  ),
  const ConversationModel(
    id: "17845432127501402",
    user: ConversationUser(
      name: "Sarah Anastasya",
      username: "sarahanas",
      avatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&q=80",
      classGroup: "XII PPLG 1",
      isVerified: true,
      isOnline: true,
    ),
    lastMessage: "Kalkulator Casio FX-991EX nya masih ada kak? Bisa COD di kantin?",
    timestamp: "Baru saja",
    unreadCount: 2,
    productContext: ProductContext(
      title: "Kalkulator Casio FX-991EX",
      price: "Rp 185.000",
      image: "https://images.unsplash.com/photo-1587145820266-a5951ee6f620?w=200&q=80",
    ),
  ),
  const ConversationModel(
    id: "17950293812048512",
    user: ConversationUser(
      name: "Nadia Putri",
      username: "nadiaputri",
      avatar: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&q=80",
      classGroup: "XI Kuliner 1",
      isOnline: false,
    ),
    lastMessage: "Makasih ya kak, barangnya masih mulus banget!",
    timestamp: "2j",
  ),
  const ConversationModel(
    id: "17961203912830192",
    user: ConversationUser(
      name: "Rian Pratama",
      username: "rian_pratama",
      avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&q=80",
      classGroup: "XII PPLG 2",
      isOnline: false,
    ),
    lastMessage: "Bisa nego tipis gak bro untuk jas almamaternya?",
    timestamp: "1h",
    isSender: true,
  ),
  const ConversationModel(
    id: "17970192830192831",
    user: ConversationUser(
      name: "Bagus Prakoso",
      username: "bagus_prakoso",
      avatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&q=80",
      classGroup: "X DKV 1",
      isOnline: false,
    ),
    lastMessage: "Halo kak, akun Canva Pro edukasi nya ready gak ya?",
    timestamp: "3h",
    isRequest: true,
    productContext: ProductContext(
      title: "Akun Canva Pro Edukasi 1 Tahun",
      price: "Rp 30.000",
    ),
  ),
];

/// Pesan-pesan awal untuk percakapan Dimas Wicaksono (Product Mode)
final List<ChatMessageModel> kInitialDimasMessages = [
  const ChatMessageModel(
    id: "msg-dimas-1",
    senderId: "dimas_wicak",
    text: "Kak modul fisika terapan ini masih ready ga ya? Mau tanya kondisi coretannya banyak ga?",
    timestamp: "14:20",
    isMe: false,
  ),
  const ChatMessageModel(
    id: "msg-dimas-2",
    senderId: "saya",
    text: "Masih ready banget Dimas! Coretannya minim pakai pensil, bisa dihapus kok 👍",
    timestamp: "14:21",
    isMe: true,
    status: MessageStatus.read,
  ),
];

/// Pesan-pesan awal untuk percakapan Sarah Anastasya
final List<ChatMessageModel> kInitialSarahMessages = [
  const ChatMessageModel(
    id: "msg-1",
    senderId: "sarahanas",
    text: "Halo kak, salam kenal! Mau tanya soal postingan kalkulatornya...",
    timestamp: "14:20",
    isMe: false,
  ),
  const ChatMessageModel(
    id: "msg-2",
    senderId: "sarahanas",
    text: "Kalkulator Casio FX-991EX nya masih ada kak? Bisa COD di kantin?",
    timestamp: "14:22",
    isMe: false,
  ),
];
