import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/navigation/app_slide_page_route.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/messages/components/chat_composer_bar.dart';
import 'package:snapan_market/features/messages/components/chat_product_card.dart';
import 'package:snapan_market/features/messages/models/chat_message_model.dart';
import 'package:snapan_market/features/messages/models/conversation_model.dart';
import 'package:snapan_market/features/messages/models/mock_messages_data.dart';
import 'package:snapan_market/features/profile/screens/profile_screen.dart';

/// Layar ruang obrolan 1-on-1 Direct Messaging
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
    if (widget.conversation.id == '17845432127501402') {
      _messages = List.from(kInitialSarahMessages);
    } else {
      _messages = [
        ChatMessageModel(
          id: 'msg-init',
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

  void _handleSendMessage(String text) {
    final newMsg = ChatMessageModel(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'saya',
      text: text,
      timestamp: 'Baru saja',
      isMe: true,
      status: MessageStatus.sent,
    );

    setState(() {
      _messages.add(newMsg);
    });

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

  void _handleViewProfile() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      AppSlidePageRoute(
        builder: (_) => ProfileScreen(
          username: widget.conversation.user.username,
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    color: AppColors.ink,
                  ),
                  tooltip: 'Kembali',
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
                                bottom: -1.0,
                                right: -1.0,
                                child: Container(
                                  width: 11.0,
                                  height: 11.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF31A24C),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.8,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(width: 10.0),

                        // Nama dan Kelas / Status
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
                                        color: AppColors.ink,
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
                                    ? '${widget.conversation.user.classGroup ?? 'Siswa'} · Aktif sekarang'
                                    : widget.conversation.user.classGroup ?? 'Siswa SMKN 8',
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

                // Tombol Lihat Profil Kanan
                IconButton(
                  icon: const Icon(
                    Icons.info_outline_rounded,
                    size: 21.0,
                    color: Color(0xFF64748B),
                  ),
                  tooltip: 'Info Profil',
                  onPressed: _handleViewProfile,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Stream Percakapan
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              children: [
                // Kartu Konteks Produk jika ada
                if (widget.conversation.productContext != null)
                  ChatProductCard(
                    product: widget.conversation.productContext!,
                    onViewProduct: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Membuka katalog "${widget.conversation.productContext!.title}"'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
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
      // Pesan Keluar (Saya) - Warna Biru / Gelap Kumo
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.76,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.0),
                  topRight: Radius.circular(18.0),
                  bottomLeft: Radius.circular(18.0),
                  bottomRight: Radius.circular(4.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    msg.text,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 3.0),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg.timestamp,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(width: 3.0),
                      Icon(
                        Icons.done_all_rounded,
                        size: 13.0,
                        color: Colors.white.withValues(alpha: 0.9),
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
      // Pesan Masuk (Lawan Bicara) - Abu-abu Lembut
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.76,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.0),
                  topRight: Radius.circular(18.0),
                  bottomRight: Radius.circular(18.0),
                  bottomLeft: Radius.circular(4.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: AppColors.ink,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 3.0),
                  Text(
                    msg.timestamp,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF94A3B8),
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
