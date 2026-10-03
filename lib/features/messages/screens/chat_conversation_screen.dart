import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snapan_market/core/components/glass_toolbar_top.dart';
import 'package:snapan_market/core/navigation/app_slide_page_route.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/features/map/screens/campus_map_screen.dart';
import 'package:snapan_market/features/messages/components/chat_app_bar_title.dart';
import 'package:snapan_market/features/messages/components/chat_composer_bar.dart';
import 'package:snapan_market/features/messages/components/chat_message_bubble.dart';
import 'package:snapan_market/features/messages/components/chat_options_sheet.dart';
import 'package:snapan_market/features/messages/components/chat_product_card.dart';
import 'package:snapan_market/features/messages/models/chat_message_model.dart';
import 'package:snapan_market/features/messages/models/conversation_model.dart';
import 'package:snapan_market/features/messages/services/direct_messages_service.dart';
import 'package:snapan_market/features/profile/screens/profile_screen.dart';

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
  late String _activeConvId;
  late List<ChatMessageModel> _messages;
  final ScrollController _scrollController = ScrollController();
  RealtimeChannel? _messagesSubscription;

  @override
  void initState() {
    super.initState();
    _activeConvId = widget.conversation.id;
    DirectMessagesService.instance.addListener(_onServiceChanged);

    final savedMessages = DirectMessagesService.instance.getMessages(_activeConvId);
    if (savedMessages.isNotEmpty) {
      _messages = List.from(savedMessages);
    } else if (widget.conversation.lastMessage.trim().isNotEmpty) {
      final initialMsg = ChatMessageModel(
        id: "msg-${DateTime.now().millisecondsSinceEpoch}",
        senderId: widget.conversation.isSender ? "saya" : widget.conversation.user.username,
        text: widget.conversation.lastMessage.trim(),
        timestamp: widget.conversation.timestamp,
        isMe: widget.conversation.isSender,
      );
      _messages = [initialMsg];
      DirectMessagesService.instance.addMessage(
        _activeConvId,
        initialMsg,
        conversation: widget.conversation,
      );
    } else {
      _messages = [];
    }

    _initRealtimeChat();
  }

  void _onServiceChanged() {
    if (!mounted) return;
    final updated = DirectMessagesService.instance.getMessages(_activeConvId);
    if (updated.isNotEmpty) {
      setState(() {
        _messages = List.from(updated);
      });
      _scrollToBottom();
    }
  }

  Future<void> _initRealtimeChat() async {
    final currentUserId = SupabaseService.instance.currentUser?.id ?? '';
    final isUuid = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);

    // Auto-resolve real UUID if opened with temporary conversation ID
    if (!isUuid.hasMatch(_activeConvId)) {
      String? targetUserId = widget.conversation.user.id;
      if (targetUserId == null) {
        final profile = await SupabaseService.instance.getProfileByUsername(widget.conversation.user.username);
        targetUserId = profile?['id'] as String?;
      }

      if (targetUserId != null) {
        final realId = await SupabaseService.instance.getOrCreateConversation(
          otherUserId: targetUserId,
          productId: widget.conversation.productId,
        );
        if (realId != null && realId != _activeConvId) {
          final oldId = _activeConvId;
          _activeConvId = realId;
          DirectMessagesService.instance.updateConversationId(
            oldId: oldId,
            newId: realId,
          );
        }
      }
    }

    // Load message history from Supabase
    final live = await DirectMessagesService.instance.loadMessages(_activeConvId);
    if (live.isNotEmpty && mounted) {
      setState(() {
        _messages = List.from(live);
      });
      _scrollToBottom();
    }

    // Subscribe to live realtime messages and read-status updates
    _messagesSubscription?.unsubscribe();
    _messagesSubscription = SupabaseService.instance.subscribeToMessages(
      _activeConvId,
      (newRecord) {
        if (!mounted) return;
        final msg = ChatMessageModel.fromJson(newRecord, currentUserId);
        DirectMessagesService.instance.addMessage(
          _activeConvId,
          msg,
          conversation: widget.conversation,
        );
        // If message is from other user, automatically mark as read
        if (!msg.isMe) {
          DirectMessagesService.instance.markAsRead(_activeConvId);
        }
        _scrollToBottom();
      },
      onMessageUpdated: (updatedRecord) {
        if (!mounted) return;
        final updatedMsg = ChatMessageModel.fromJson(updatedRecord, currentUserId);
        DirectMessagesService.instance.updateMessage(_activeConvId, updatedMsg);
      },
    );
  }

  @override
  void dispose() {
    DirectMessagesService.instance.removeListener(_onServiceChanged);
    _messagesSubscription?.unsubscribe();
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
    DirectMessagesService.instance.sendMessage(
      conversationId: _activeConvId,
      text: text,
      conversation: widget.conversation,
    );
    _scrollToBottom();
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
      appBar: GlassToolbarTop(
        leadingIcon: CupertinoIcons.chevron_back,
        leadingTooltip: "Kembali",
        onLeadingTap: () => Navigator.of(context).pop(),
        showVerifiedBadge: false,
        titleWidget: ChatAppBarTitle(
          user: widget.conversation.user,
          onTapProfile: _handleViewProfile,
        ),
        trailingActions: [
          GlassToolbarAction(
            icon: CupertinoIcons.phone,
            tooltip: 'Panggilan',
            onTap: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur panggilan suara akan segera hadir!'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          GlassToolbarAction(
            icon: CupertinoIcons.ellipsis,
            tooltip: 'Menu lainnya',
            onTap: () {
              HapticFeedback.lightImpact();
              ChatOptionsSheet.show(
                context: context,
                onViewProfile: _handleViewProfile,
                onReportUser: _handleReportUser,
                onClearChat: _handleClearChat,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
              children: [
                if (widget.conversation.productContext != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ChatProductCard(
                        product: widget.conversation.productContext!,
                        location: "Kantin Belakang SMKN 8 Semarang",
                        onViewProduct: () {
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
                ..._messages.map((msg) => ChatMessageBubble(message: msg)),
              ],
            ),
          ),
          ChatComposerBar(
            onSendMessage: _handleSendMessage,
          ),
        ],
      ),
    );
  }
}
