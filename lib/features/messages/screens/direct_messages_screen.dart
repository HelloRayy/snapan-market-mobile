import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snapan_market/core/components/glass_toolbar_top.dart';
import 'package:snapan_market/core/components/snaps_skeleton.dart';
import 'package:snapan_market/core/navigation/app_slide_page_route.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/features/messages/components/conversation_list_item.dart';
import 'package:snapan_market/features/messages/components/direct_messages_empty_state.dart';
import 'package:snapan_market/features/messages/components/direct_messages_filter_tabs.dart';
import 'package:snapan_market/features/messages/components/direct_messages_invite_tile.dart';
import 'package:snapan_market/features/messages/components/direct_messages_new_chat_sheet.dart';
import 'package:snapan_market/features/messages/models/conversation_model.dart';
import 'package:snapan_market/features/messages/screens/chat_conversation_screen.dart';
import 'package:snapan_market/features/messages/services/direct_messages_service.dart';

/// Halaman Inbox Direct Messages 1:1 matching DirectMessagesPage.tsx
class DirectMessagesScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final bool showBackButton;
  final bool showAppBar;

  const DirectMessagesScreen({
    super.key,
    this.onBack,
    this.showBackButton = false,
    this.showAppBar = true,
  });

  @override
  State<DirectMessagesScreen> createState() => _DirectMessagesScreenState();
}

class _DirectMessagesScreenState extends State<DirectMessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeFilter = 'inbox'; // 'inbox' | 'requests' | 'unread'
  bool _showSearchBar = false;
  RealtimeChannel? _inboxSubscription;

  @override
  void initState() {
    super.initState();
    DirectMessagesService.instance.addListener(_onServiceUpdate);
    DirectMessagesService.instance.loadConversations();
    _inboxSubscription = SupabaseService.instance.subscribeToInbox(() {
      DirectMessagesService.instance.loadConversations();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _inboxSubscription?.unsubscribe();
    DirectMessagesService.instance.removeListener(_onServiceUpdate);
    _searchController.dispose();
    super.dispose();
  }

  List<ConversationModel> get _filteredConversations {
    return DirectMessagesService.instance.conversations.where((conv) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = conv.user.name.toLowerCase().contains(query);
        final matchesUsername = conv.user.username.toLowerCase().contains(query);
        final matchesMessage = conv.lastMessage.toLowerCase().contains(query);
        final matchesProduct = conv.productContext?.title.toLowerCase().contains(query) ?? false;

        if (!matchesName && !matchesUsername && !matchesMessage && !matchesProduct) {
          return false;
        }
      }

      if (_activeFilter == 'requests') {
        return conv.isRequest == true;
      } else if (_activeFilter == 'unread') {
        return conv.unreadCount > 0;
      }
      return !conv.isRequest;
    }).toList();
  }

  void _handleOpenChat(ConversationModel conversation) {
    Navigator.of(context).push(
      AppSlidePageRoute(
        builder: (_) => ChatConversationScreen(conversation: conversation),
      ),
    );
  }

  void _handleNewChat() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (sheetContext) {
        return DirectMessagesNewChatSheet(
          onUserSelected: (user) async {
            Navigator.of(sheetContext).pop();
            final targetUserId = user['id'] as String?;
            String convId = 'conv_${targetUserId ?? user['username']}';
            if (targetUserId != null) {
              final realConvId = await SupabaseService.instance.getOrCreateConversation(otherUserId: targetUserId);
              if (realConvId != null) {
                convId = realConvId;
              }
            }
            final conv = ConversationModel(
              id: convId,
              user: ConversationUser(
                name: user['full_name'] as String? ?? user['username'] as String? ?? 'Siswa SMKN 8 Semarang',
                username: user['username'] as String? ?? 'user',
                avatar: user['avatar_url'] as String? ?? '',
                classGroup: user['class_group'] as String? ?? 'SMKN 8 Semarang',
                isVerified: user['is_verified'] as bool? ?? false,
              ),
              lastMessage: '',
              timestamp: 'Baru saja',
              unreadCount: 0,
              isSender: true,
            );
            DirectMessagesService.instance.addOrUpdateConversation(conv);
            _handleOpenChat(conv);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredConversations;

    final content = Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFF1F5F9),
                width: 0.8,
              ),
            ),
          ),
          child: Column(
            children: [
              if (widget.showAppBar)
                GlassToolbarTop(
                  leadingText: (widget.showBackButton || widget.onBack != null) ? 'Kembali' : 'Edit',
                  leadingTooltip: (widget.showBackButton || widget.onBack != null) ? 'Kembali' : 'Edit Obrolan',
                  onLeadingTap: () {
                    if (widget.onBack != null) {
                      widget.onBack!();
                    } else if (widget.showBackButton) {
                      Navigator.of(context).pop();
                    } else {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mode edit obrolan aktif'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  title: 'Chat',
                  showVerifiedBadge: false,
                  trailingText: 'Cari',
                  trailingTooltip: 'Cari pesan',
                  onTrailingTap: () => setState(() => _showSearchBar = !_showSearchBar),
                ),
              if (_showSearchBar || _searchQuery.isNotEmpty || !widget.showAppBar)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 10.0),
                  child: Container(
                    height: 38.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F5F7),
                      borderRadius: BorderRadius.circular(19.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.search, size: 18.0, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(fontSize: 13.5, color: AppColors.ink),
                            decoration: const InputDecoration(
                              hintText: 'Cari pesan...',
                              hintStyle: TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () => _searchController.clear(),
                            child: const Icon(CupertinoIcons.clear_thick_circled, size: 16.0, color: Color(0xFF94A3B8)),
                          ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: DirectMessagesFilterTabs(
                  activeFilter: _activeFilter,
                  onSelectFilter: (key) => setState(() => _activeFilter = key),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isNotEmpty
              ? ListView.separated(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 120.0),
                  itemCount: (_searchQuery.isEmpty && _activeFilter == 'inbox')
                      ? filtered.length + 1
                      : filtered.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1.0,
                    thickness: 0.6,
                    color: Color(0xFFE6E6E6),
                    indent: 76.0,
                  ),
                  itemBuilder: (ctx, index) {
                    if (_searchQuery.isEmpty && _activeFilter == 'inbox' && index == 0) {
                      return DirectMessagesInviteTile(onTap: _handleNewChat);
                    }
                    final dataIndex = (_searchQuery.isEmpty && _activeFilter == 'inbox')
                        ? index - 1
                        : index;
                    final conv = filtered[dataIndex];
                    return ConversationListItem(
                      conversation: conv,
                      onTap: () => _handleOpenChat(conv),
                    );
                  },
                )
              : DirectMessagesService.instance.isFetchingConversations
                  ? const SingleChildScrollView(
                      child: ConversationListSkeleton(itemCount: 6),
                    )
                  : DirectMessagesEmptyState(
                      activeFilter: _activeFilter,
                      searchQuery: _searchQuery,
                    ),
        ),
      ],
    );

    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(bottom: false, child: content),
      );
    }

    return Container(color: Colors.white, child: content);
  }
}
