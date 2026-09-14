import "package:snapan_market/features/map/screens/campus_map_screen.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:snapan_market/core/components/glass_toolbar_top.dart";
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

  void _showConversationMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded, color: Color(0xFF0F172A)),
                  title: const Text('Lihat Profil', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _handleViewProfile();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.shield_outlined, color: Color(0xFF0F172A)),
                  title: const Text('Laporkan Pengguna', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _handleReportUser();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  title: const Text('Bersihkan Obrolan', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _handleClearChat();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: GlassToolbarTop(
        leadingIcon: Icons.arrow_back_rounded,
        leadingTooltip: "Kembali",
        onLeadingTap: () => Navigator.of(context).pop(),
        showVerifiedBadge: false,
        titleWidget: GestureDetector(
          onTap: _handleViewProfile,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar dengan Indikator Online
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 34.0,
                    height: 34.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF1F5F9),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 0.8,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(17.0),
                      child: Image.network(
                        widget.conversation.user.avatar,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person_rounded,
                          color: AppColors.muted,
                          size: 18.0,
                        ),
                      ),
                    ),
                  ),
                  if (widget.conversation.user.isOnline)
                    Positioned(
                      bottom: -0.5,
                      right: -0.5,
                      child: Container(
                        width: 10.0,
                        height: 10.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF31A24C),
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8.0),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            widget.conversation.user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'SF Pro',
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
                            color: Color(0xFF008BFF),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      widget.conversation.user.isOnline
                          ? "Aktif sekarang"
                          : (widget.conversation.user.classGroup ?? "Siswa SMKN 8"),
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 11.0,
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
        trailingActions: [
          GlassToolbarAction(
            icon: Icons.phone_outlined,
            tooltip: 'Panggilan',
            onTap: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur panggilan suara akan segera hadir! 📞'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          GlassToolbarAction(
            icon: Icons.more_horiz_rounded,
            tooltip: 'Menu lainnya',
            onTap: () {
              HapticFeedback.lightImpact();
              _showConversationMenu(context);
            },
          ),
        ],
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
