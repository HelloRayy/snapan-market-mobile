import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/components/glass_toolbar_top.dart';
import 'package:snapan_market/core/navigation/app_slide_page_route.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/messages/components/conversation_list_item.dart';
import 'package:snapan_market/features/messages/models/conversation_model.dart';
import 'package:snapan_market/features/messages/models/mock_messages_data.dart';
import 'package:snapan_market/features/messages/screens/chat_conversation_screen.dart';

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
  String _activeFilter = 'inbox'; // 'inbox' | 'requests'
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ConversationModel> get _filteredConversations {
    return kMockConversations.where((conv) {
      // 1. Search Query Filter
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

      // 2. Tab Filter
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
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pilih teman dari daftar kontak sekolah SMKN 8 untuk memulai pesan baru ✨'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredConversations;

    final content = Column(
      children: [
        // Sticky Header / Filter Section
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
              if (widget.showAppBar) ...[
                // Baris 1: Toolbar - Top - Chats (Text-only buttons, 0 hard shadow)
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
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mode edit obrolan aktif ✨'),
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
                  onTrailingTap: () {
                    setState(() {
                      _showSearchBar = !_showSearchBar;
                    });
                  },
                ),
              ],

              // Baris 2: SearchBar Kapsul
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
                          const Icon(
                            Icons.search_rounded,
                            size: 18.0,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: AppColors.ink,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Cari pesan...',
                                hintStyle: TextStyle(
                                  fontSize: 13.5,
                                  color: Color(0xFF94A3B8),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                              },
                              child: const Icon(
                                Icons.cancel_rounded,
                                size: 16.0,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Baris 3: Horizontal Carousel Filters (Obrolan, Pembeli, Belum Dibaca)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: _buildFoldersTabCarousel(),
                  ),
                ],
              ),
            ),

            // Daftar Percakapan
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
                        color: Color(0xFFE6E6E6), // pen.dev _Separator #E6E6E6
                        indent: 76.0,
                      ),
                      itemBuilder: (ctx, index) {
                        // Row 0: Pen.dev "Invite Friends" / "Undang Teman"
                        if (_searchQuery.isEmpty && _activeFilter == 'inbox' && index == 0) {
                          return Material(
                            color: Colors.white,
                            child: InkWell(
                              onTap: _handleNewChat,
                              highlightColor: const Color(0xFFF2F4F7),
                              splashColor: const Color(0xFFF2F4F7),
                              child: Container(
                                height: 72.0,
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: const Row(
                                  children: [
                                    // Symbol Icon in standard 48x48 circular badge
                                    Padding(
                                      padding: EdgeInsets.only(right: 12.0),
                                      child: SizedBox(
                                        width: 48.0,
                                        height: 48.0,
                                        child: Center(
                                          child: Icon(
                                            Icons.person_add_outlined,
                                            color: Color(0xFF008BFF), // pen.dev #008BFF
                                            size: 24.0,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Title matching pen.dev "Invite Friends"
                                    Expanded(
                                      child: Text(
                                        'Undang Teman SMKN 8',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF000000),
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ),

                                    // Chevron Right (pen.dev Drill-in #3C3C434D)
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 20.0,
                                      color: Color(0x4D3C3C43),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
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
                  : _buildEmptyState(),
            ),
          ],
        );

    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: content,
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: content,
    );
  }

  /// Segmented Tab Switch sliced 1:1 from pen.dev Folders (`snaps-design.pen` node `NOYP2`)
  ///
  /// Features:
  /// - Exact 41px height (`height: 41.0`, padding: `3.0`)
  /// - Frosted liquid glass background with cornerRadius 296 (`borderRadius: 21.0`)
  /// - Outer diffuse shadow (#0000001f, y=8, blur=35)
  /// - Selected Tab: 35px height, cornerRadius 20, fill #EDEDED (`Color(0xFFEDEDED)`)
  /// - SF Pro 14px typography with letter-spacing -0.08
  /// Horizontal scrollable carousel filter chips ("Obrolan", "Pembeli", "Belum Dibaca")
  Widget _buildFoldersTabCarousel() {
    final buyerUnreadCount = kMockConversations
        .where((c) => c.isRequest == true && c.unreadCount > 0)
        .fold<int>(0, (acc, c) => acc + c.unreadCount);

    final totalUnreadCount = kMockConversations
        .where((c) => c.unreadCount > 0)
        .fold<int>(0, (acc, c) => acc + c.unreadCount);

    final tabs = [
      (key: 'inbox', label: 'Obrolan', count: null),
      (key: 'requests', label: 'Pembeli', count: buyerUnreadCount > 0 ? buyerUnreadCount : null),
      (key: 'unread', label: 'Belum Dibaca', count: totalUnreadCount > 0 ? totalUnreadCount : null),
    ];

    return SizedBox(
      height: 40.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8.0),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          return _buildCarouselChip(
            key: tab.key,
            label: tab.label,
            count: tab.count,
          );
        },
      ),
    );
  }

  Widget _buildCarouselChip({
    required String key,
    required String label,
    int? count,
  }) {
    final isActive = _activeFilter == key;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _activeFilter = key);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 38.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0x1F000000),
              blurRadius: isActive ? 20.0 : 10.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
            child: Container(
              height: 38.0,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(19.0),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isActive
                      ? [
                          const Color(0xFFEDEDED).withValues(alpha: 0.95),
                          const Color(0xFFE2E2E2).withValues(alpha: 0.85),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.75),
                          Colors.white.withValues(alpha: 0.50),
                        ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isActive ? 0.95 : 0.80),
                  width: 1.1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 14.0,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? const Color(0xFF000000) : const Color(0xFF787574),
                      letterSpacing: -0.15,
                    ),
                  ),
                  if (count != null && count > 0) ...[
                    const SizedBox(width: 6.0),
                    Container(
                      constraints: const BoxConstraints(
                        minWidth: 18.0,
                        minHeight: 18.0,
                      ),
                      height: 18.0,
                      padding: count > 9 ? const EdgeInsets.symmetric(horizontal: 4.0) : EdgeInsets.zero,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF008BFF), // Azure Blue #008BFF
                        borderRadius: BorderRadius.circular(9.0),
                      ),
                      child: Text(
                        count > 99 ? '99+' : count.toString(),
                        style: const TextStyle(
                          fontFamily: 'SF Pro',
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 54.0,
              height: 54.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 28.0,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 14.0),
            Text(
              _activeFilter == 'requests'
                  ? 'Tidak ada pesan dari pembeli'
                  : 'Tidak ada obrolan',
              style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Tidak ditemukan pesan dengan kata kunci "$_searchQuery"'
                  : _activeFilter == 'requests'
                      ? 'Pesan dari calon pembeli produk jualan Anda akan muncul di sini.'
                      : 'Mulai kirim pesan ke teman atau penjual barang di Snapan Market.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF94A3B8),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
