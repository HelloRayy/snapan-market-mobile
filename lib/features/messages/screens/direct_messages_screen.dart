import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  const DirectMessagesScreen({
    super.key,
    this.onBack,
    this.showBackButton = false,
  });

  @override
  State<DirectMessagesScreen> createState() => _DirectMessagesScreenState();
}

class _DirectMessagesScreenState extends State<DirectMessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeFilter = 'inbox'; // 'inbox' | 'requests'

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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Sticky Header: Baris 1 Title, Baris 2 Search, Baris 3 Filter Pills
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
                  // Baris 1: Header Top (Back di kiri, Judul di tengah, Aksi di kanan)
                  Container(
                    height: 48.0,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Judul Tengah
                        const Center(
                          child: Text(
                            'Pesan',
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),

                        // Tombol Kembali (Jika ada)
                        if (widget.showBackButton || widget.onBack != null)
                          Positioned(
                            left: 0,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                size: 22.0,
                                color: AppColors.ink,
                              ),
                              tooltip: 'Kembali',
                              onPressed: () {
                                if (widget.onBack != null) {
                                  widget.onBack!();
                                } else {
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ),

                        // Tombol Pesan Baru Kanan (SquarePen)
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit_note_rounded,
                              size: 24.0,
                              color: AppColors.ink,
                            ),
                            tooltip: 'Pesan baru',
                            onPressed: _handleNewChat,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Baris 2: SearchBar Kapsul
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

                  // Baris 3: Sub-Navigation Filter Tab Pills ("Obrolan" & "Pembeli")
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 10.0),
                    child: Row(
                      children: [
                        _buildFilterPill('inbox', 'Obrolan'),
                        const SizedBox(width: 8.0),
                        _buildFilterPill('requests', 'Pembeli'),
                      ],
                    ),
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
        ),
      ),
    );
  }

  Widget _buildFilterPill(String key, String label) {
    final isActive = _activeFilter == key;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _activeFilter = key);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEDEDED) : Colors.transparent, // pen.dev capsule #EDEDED
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? const Color(0xFF008BFF) : const Color(0xFF64748B),
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
