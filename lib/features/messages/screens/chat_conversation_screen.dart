import "package:snapan_market/features/map/screens/campus_map_screen.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:snapan_market/core/navigation/app_slide_page_route.dart";
import "package:snapan_market/core/theme/app_colors.dart";
import "package:snapan_market/features/messages/components/chat_composer_bar.dart";
import "package:snapan_market/features/messages/components/chat_product_card.dart";
import "package:snapan_market/features/messages/models/chat_message_model.dart";
import "package:snapan_market/features/messages/models/conversation_model.dart";
import "package:snapan_market/features/messages/models/mock_messages_data.dart";
import "package:snapan_market/features/profile/screens/profile_screen.dart";

/// Layar ruang obrolan 1-on-1 Direct Messaging (1:1 ActiveChatOverlay.tsx)
class ChatConversationScreen extends StatefulWidget {
  final ConversationModel conversation;

  const ChatConversationScreen({
    super.key,
    required this.conversation,
  });

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  late List<ChatMessageModel> _messages;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.conversation.id == "17892348123791823") {
      _messages = List.from(kInitialDimasMessages);
    } else if (widget.conversation.id == "17845432127501402") {
      _messages = List.from(kInitialSarahMessages);
    } else {
      _messages = [
        ChatMessageModel(
          id: "msg-init",
          senderId: widget.conversation.user.username,
          text: widget.conversation.lastMessage,
          timestamp: widget.conversation.timestamp,
          isMe: widget.conversation.isSender,
        ),
      ];
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSendMessage(String text) {
    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final newMsg = ChatMessageModel(
      id: "msg-${now.millisecondsSinceEpoch}",
      senderId: "saya",
      text: text,
      timestamp: timeStr,
      isMe: true,
      status: MessageStatus.sent,
    );

    setState(() {
      _messages.add(newMsg);
    });
    _scrollToBottom();

    // Auto-Reply simulation matching ActiveChatOverlay.tsx
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      final replyMsg = ChatMessageModel(
        id: "reply-${DateTime.now().millisecondsSinceEpoch}",
        senderId: widget.conversation.user.username,
        text: "Halo! Pesan kamu sudah diterima yaa 👍 Btw barangnya masih ready dan bisa COD di area sekolah!",
        timestamp: timeStr,
        isMe: false,
      );
      setState(() {
        _messages.add(replyMsg);
      });
      _scrollToBottom();
    });
  }

  void _handleViewProfile() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      AppSlidePageRoute(
        builder: (_) => ProfileScreen(
          username: widget.conversation.user.username,
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _handleReportUser() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Laporan terhadap @${widget.conversation.user.username} telah dikirim ke admin sekolah."),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleClearChat() {
    HapticFeedback.mediumImpact();
    setState(() {
      _messages.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Obrolan telah dibersihkan."),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: SafeArea(
          bottom: false,
          child: Container(
            height: 56.0,
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFF1F5F9),
                  width: 0.8,
                ),
              ),
            ),
            child: Row(
              children: [
                // Tombol Kembali
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    size: 22.0,
                    color: Color(0xFF0F172A),
                  ),
                  tooltip: "Kembali",
                  onPressed: () => Navigator.of(context).pop(),
                ),

                // Info Profil Lawan Bicara (Clickable)
                Expanded(
                  child: GestureDetector(
                    onTap: _handleViewProfile,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        // Avatar dengan Indikator Online
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 38.0,
                              height: 38.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFF1F5F9),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 0.8,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(19.0),
                                child: Image.network(
                                  widget.conversation.user.avatar,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person_rounded,
                                    color: AppColors.muted,
                                    size: 20.0,
                                  ),
                                ),
                              ),
                            ),
                            if (widget.conversation.user.isOnline)
                              Positioned(
                                bottom: -0.5,
                                right: -0.5,
                                child: Container(
                                  width: 12.0,
                                  height: 12.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF31A24C),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(width: 10.0),

                        // Nama dan Status Aktif
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.conversation.user.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ),
                                  if (widget.conversation.user.isVerified) ...[
                                    const SizedBox(width: 3.5),
                                    const Icon(
                                      Icons.verified_rounded,
                                      size: 14.0,
                                      color: Color(0xFF1D64EC),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 1.5),
                              Text(
                                widget.conversation.user.isOnline
                                    ? "Aktif sekarang"
                                    : (widget.conversation.user.classGroup ?? "Siswa SMKN 8"),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: widget.conversation.user.isOnline
                                      ? const Color(0xFF31A24C)
                                      : const Color(0xFF94A3B8),
                                  fontWeight: widget.conversation.user.isOnline
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Submenu Dropdown 3 Dots
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    size: 21.0,
                    color: Color(0xFF64748B),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  onSelected: (value) {
                    if (value == "profile") _handleViewProfile();
                    if (value == "report") _handleReportUser();
                    if (value == "clear") _handleClearChat();
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: "profile",
                      child: Row(
                        children: [
                          Icon(Icons.person_outline_rounded, size: 18.0, color: Color(0xFF0F172A)),
                          SizedBox(width: 10.0),
                          Text("Lihat Profil", style: TextStyle(fontSize: 13.5)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: "report",
                      child: Row(
                        children: [
                          Icon(Icons.shield_outlined, size: 18.0, color: Color(0xFF0F172A)),
                          SizedBox(width: 10.0),
                          Text("Laporkan Pengguna", style: TextStyle(fontSize: 13.5)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: "clear",
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 18.0, color: Colors.red),
                          SizedBox(width: 10.0),
                          Text("Bersihkan Obrolan", style: TextStyle(fontSize: 13.5, color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Stream Percakapan dengan Background #F6F7F9
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
              children: [
                // Kartu Konteks Produk jika ada
                if (widget.conversation.productContext != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ChatProductCard(
                        product: widget.conversation.productContext!,
                        location: widget.conversation.id == "17892348123791823" ? "Lab Fisika Lt 2" : "Kantin Belakang SMKN 8",
                        onViewProduct: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Membuka katalog \"${widget.conversation.productContext!.title}\""),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        onCheckLocation: () {
                          Navigator.of(context).push(
                            AppSlidePageRoute(
                              builder: (_) => CampusMapScreen(
                                onBack: () => Navigator.pop(context),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // Bubble Pesan
                ..._messages.map((msg) => _buildChatBubble(msg)),
              ],
            ),
          ),

          // Baris Composer Teks Bawah
          ChatComposerBar(
            onSendMessage: _handleSendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessageModel msg) {
    if (msg.isMe) {
      // Pesan Keluar (Saya) - Warna Biru Kumo #1D64EC (1:1 chat-bubble.tsx)
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.82,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              decoration: const BoxDecoration(
                color: Color(0xFF1D64EC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(4.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x101D64EC),
                    blurRadius: 4.0,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    msg.text,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: Colors.white,
                      height: 1.38,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 3.0),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg.timestamp,
                        style: TextStyle(
                          fontSize: 11.0,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      const Icon(
                        Icons.done_all_rounded,
                        size: 14.0,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Pesan Masuk (Lawan Bicara) - Putih dengan Border Halus (1:1 chat-bubble.tsx)
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.82,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                  bottomLeft: Radius.circular(4.0),
                ),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 0.8,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 4.0,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: Color(0xFF0F172A),
                      height: 1.38,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 3.0),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      msg.timestamp,
                      style: const TextStyle(
                        fontSize: 11.0,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
