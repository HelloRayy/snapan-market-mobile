import "package:snapan_market/features/checkout/screens/checkout_screen.dart";
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/components/glass_toolbar_top.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/features/feed/components/buy_bottom_sheet.dart';
import 'package:snapan_market/features/feed/components/comment_input_bar.dart';
import 'package:snapan_market/features/feed/components/market_post_card.dart';
import 'package:snapan_market/features/feed/components/delete_post_bottom_sheet.dart';
import 'package:snapan_market/features/feed/components/post_comment_item.dart';
import 'package:snapan_market/features/feed/components/post_submenu_popover.dart';
import 'package:snapan_market/features/feed/components/sticky_buy_bar.dart';
import 'package:snapan_market/features/feed/components/media_lightbox_dialog.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';
import 'package:snapan_market/core/navigation/app_slide_page_route.dart';
import 'package:snapan_market/core/utils/formatters.dart';
import 'package:snapan_market/features/messages/models/conversation_model.dart';
import 'package:snapan_market/features/messages/screens/chat_conversation_screen.dart';
import 'package:snapan_market/features/messages/services/direct_messages_service.dart';

/// PostDetailScreen
/// 100% Sliced 1:1 from Web React PostDetailPage.tsx
///
/// Features:
/// - Sticky top header with Back arrow button and centered "Postingan" logotype
/// - Focused main post card rendered in single-column detail variant
/// - Section divider: "Komentar (N)" / "Tanya Jawab & Diskusi (N)"
/// - Author Thread Continuations (e.g. Part 2/2) with "👑 Pembuat Utas" badge
/// - User comments list with threaded connector lines and nested replies
/// - Product mode morphing: StickyBuyBar <-> CommentInputBar + BuyBottomSheet
enum CommentSortOrder { newest, top, oldest }

class PostDetailScreen extends StatefulWidget {
  final MarketPostModel post;
  final ValueChanged<MarketPostModel>? onLikeToggle;
  final ValueChanged<MarketPostModel>? onBookmarkToggle;
  final ValueChanged<MarketPostModel>? onRepostToggle;
  final ValueChanged<MarketPostModel>? onDeletePost;

  const PostDetailScreen({
    super.key,
    required this.post,
    this.onLikeToggle,
    this.onBookmarkToggle,
    this.onRepostToggle,
    this.onDeletePost,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late MarketPostModel _post;
  late List<PostCommentModel> _comments;
  CommentSortOrder _selectedSort = CommentSortOrder.newest;
  String? _replyToUser;
  String? _replyToCommentId;
  bool _isCommentingActive = false;
  final ScrollController _scrollController = ScrollController();

  bool get _isProductMode => _post.isProduct && (_post.price ?? 0) > 0;

  List<PostCommentModel> get _sortedComments {
    final list = List<PostCommentModel>.from(_comments);
    switch (_selectedSort) {
      case CommentSortOrder.newest:
        return list;
      case CommentSortOrder.top:
        list.sort((a, b) => b.likesCount.compareTo(a.likesCount));
        return list;
      case CommentSortOrder.oldest:
        return list.reversed.toList();
    }
  }

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _comments = List<PostCommentModel>.from(widget.post.comments);
    _loadLiveComments();
  }

  Future<void> _loadLiveComments() async {
    try {
      final live = await SupabaseService.instance.fetchPostComments(_post.id);
      if (live.isNotEmpty && mounted) {
        setState(() {
          _comments = live;
        });
      }
    } catch (e) {
      debugPrint('Error _loadLiveComments: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int get _totalCommentsCount {
    final chainCount = _post.threadChain.length;
    int directCount = _comments.length;
    for (final c in _comments) {
      directCount += c.replies.length;
    }
    return chainCount + directCount;
  }

  Future<void> _handleAddComment(String content) async {
    if (content.trim().isEmpty) return;
    HapticFeedback.mediumImpact();

    if (!SupabaseService.instance.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masuk akun terlebih dahulu untuk berkomentar.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final liveComment = await SupabaseService.instance.addComment(
        postId: _post.id,
        content: content.trim(),
        parentCommentId: _replyToCommentId,
      );

      if (mounted) {
        setState(() {
          if (_replyToCommentId != null) {
            _comments = _comments.map((c) {
              if (c.id == _replyToCommentId || c.replies.any((r) => r.id == _replyToCommentId)) {
                return c.copyWith(replies: [...c.replies, liveComment]);
              }
              return c;
            }).toList();
          } else {
            _comments.insert(0, liveComment);
          }
          _post = _post.copyWith(commentsCount: _post.commentsCount + 1);
          _replyToUser = null;
          _replyToCommentId = null;
          if (_isProductMode) {
            _isCommentingActive = false;
          }
        });

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tanggapan berhasil dikirim!'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error adding comment: $e');
      final user = SupabaseService.instance.currentUser;
      final fallbackComment = PostCommentModel(
        id: 'comment-local-${DateTime.now().millisecondsSinceEpoch}',
        postId: _post.id,
        user: CommentUserModel(
          id: user?.id ?? 'user-current',
          name: 'Akun Anda',
          avatar: '',
        ),
        content: content.trim(),
        timestamp: 'Baru saja',
      );

      if (mounted) {
        setState(() {
          _comments.insert(0, fallbackComment);
          _replyToUser = null;
          _replyToCommentId = null;
        });
      }
    }
  }

  void _handleReplyClick(String username, [String? commentId]) {
    HapticFeedback.lightImpact();
    setState(() {
      _replyToUser = username;
      _replyToCommentId = commentId;
      _isCommentingActive = true;
    });
  }

  void _handleCancelReply() {
    setState(() {
      _replyToUser = null;
      _replyToCommentId = null;
      if (_isProductMode) {
        _isCommentingActive = false;
      }
    });
  }

  void _handleBuySheet() {
    BuyBottomSheet.show(
      context,
      post: _post,
      onConfirmOrder: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan COD berhasil dibuat untuk ${_post.seller.name}!'),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
          ),
        );
      },
    );
  }

  void _handleImageClick(List<String> images, int index) {
    MediaLightboxDialog.show(
      context: context,
      images: images,
      initialIndex: index,
      post: widget.post,
      onLikeToggle: widget.onLikeToggle,
      onRepostToggle: widget.onRepostToggle,
    );
  }

  PopupMenuItem<CommentSortOrder> _buildSortMenuItem(
    CommentSortOrder order,
    String title,
  ) {

    final isSelected = _selectedSort == order;
    return PopupMenuItem<CommentSortOrder>(
      value: order,
      height: 38.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 14.0),
          if (isSelected)
            const Icon(
              Icons.check_rounded,
              size: 16.0,
              color: Color(0xFF0F172A),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmAndDeletePost() async {
    final currentUser = SupabaseService.instance.currentUser;
    final bool isOwner = currentUser != null && (currentUser.id == _post.seller.id);
    final bool isAdmin = await SupabaseService.instance.isCurrentUserAdmin();

    if (!mounted) return;

    final confirmed = await DeletePostBottomSheet.show(
      context,
      post: _post,
      isAdmin: isAdmin && !isOwner,
    );

    if (confirmed == true && mounted) {
      widget.onDeletePost?.call(_post);
      Navigator.of(context).pop({'deleted': true, 'postId': _post.id});

      try {
        await SupabaseService.instance.deletePost(_post.id, asAdmin: isAdmin && !isOwner);
      } catch (e) {
        debugPrint('Error deleting post from detail: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authorUsername = _post.seller.username ?? _post.seller.name;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GlassToolbarTop(
        leadingIcon: Icons.arrow_back_rounded,
        leadingTooltip: 'Kembali',
        onLeadingTap: () => Navigator.pop(context),
        title: 'Postingan',
        showVerifiedBadge: true,
        trailingActions: [
          GlassToolbarAction(
            icon: Icons.share_outlined,
            tooltip: 'Bagikan postingan',
            onTap: () {
              HapticFeedback.lightImpact();
              Clipboard.setData(ClipboardData(text: 'https://snapan.id/post/${_post.id}'));
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tautan postingan berhasil disalin'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          GlassToolbarAction(
            icon: Icons.more_horiz_rounded,
            tooltip: 'Menu lainnya',
            onTap: () async {
              HapticFeedback.lightImpact();
              final currentUser = SupabaseService.instance.currentUser;
              final bool isOwner = currentUser != null && (currentUser.id == _post.seller.id);
              final bool isAdmin = await SupabaseService.instance.isCurrentUserAdmin();

              if (!context.mounted) return;

              PostSubmenuPopover.show(
                context: context,
                post: _post,
                isSaved: _post.isSaved,
                isOwner: isOwner,
                isAdmin: isAdmin,
                onToggleSave: () {
                  final nextSaved = !_post.isSaved;
                  setState(() {
                    _post = _post.copyWith(isSaved: nextSaved);
                  });
                  SupabaseService.instance.togglePostBookmark(_post.id, !nextSaved);
                  widget.onBookmarkToggle?.call(_post);
                },
                onDeletePost: _confirmAndDeletePost,
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Scrollable Content
            SingleChildScrollView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                // 1. Focused Post in Detail Variant
                MarketPostCard(
                  item: _post,
                  variant: 'detail',
                  onLikeToggle: (updated) {
                    setState(() {
                      _post = updated;
                    });
                    SupabaseService.instance.togglePostLike(updated.id, !updated.isLiked);
                    widget.onLikeToggle?.call(updated);
                  },
                  onRepostToggle: (updated) {
                    setState(() {
                      _post = updated;
                    });
                    widget.onRepostToggle?.call(updated);
                  },
                  onDeletePost: (_) => _confirmAndDeletePost(),
                  onImageClick: (item, idx) => _handleImageClick(item.images, idx),
                ),

                // 2. Comments Section Divider (Identical 0.5px subtle line separator)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFF1F5F9), width: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isProductMode
                            ? 'Tanya Jawab & Diskusi ($_totalCommentsCount)'
                            : 'Komentar ($_totalCommentsCount)',
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),

                      // Compact Dropdown Trigger (Button No Background - Top ⌄)
                      PopupMenuButton<CommentSortOrder>(
                        initialValue: _selectedSort,
                        tooltip: 'Urutkan Komentar',
                        onSelected: (val) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedSort = val;
                          });
                        },
                        offset: const Offset(0, 26.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                        ),
                        elevation: 12,
                        shadowColor: const Color(0x26000000),
                        color: Colors.white,
                        itemBuilder: (context) => [
                          _buildSortMenuItem(CommentSortOrder.newest, 'Terbaru'),
                          _buildSortMenuItem(CommentSortOrder.top, 'Teratas'),
                          _buildSortMenuItem(CommentSortOrder.oldest, 'Terlama'),
                        ],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedSort == CommentSortOrder.newest
                                    ? 'Terbaru'
                                    : _selectedSort == CommentSortOrder.top
                                        ? 'Teratas'
                                        : 'Terlama',
                                style: const TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 2.0),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16.0,
                                color: Color(0xFF64748B),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Thread Continuation Comments (e.g. Part 2/2 by Author)

                if (_post.threadChain.isNotEmpty) ...[
                  ..._post.threadChain.map((chain) {
                    final chainComment = PostCommentModel(
                      id: chain.id,
                      postId: _post.id,
                      user: CommentUserModel(
                        id: _post.seller.id,
                        name: _post.seller.name,
                        username: _post.seller.username ?? _post.seller.name,
                        avatar: _post.seller.avatar,
                        classGroup: _post.seller.classGroup,
                        isVerified: _post.seller.isVerified,
                        isAuthor: true,
                      ),
                      content: chain.caption,
                      images: chain.images,
                      threadPart: chain.partNumber,
                      totalParts: chain.totalParts,
                      timestamp: chain.timestamp,
                      likesCount: chain.likesCount,
                      isLiked: chain.isLiked,
                    );

                    return PostCommentItem(
                      key: ValueKey(chain.id),
                      comment: chainComment,
                      onReplyClick: (u) => _handleReplyClick(u, chain.id),
                      onReplyToComment: (u, cId) => _handleReplyClick(u, cId),
                      onImageClick: (imgs, idx) => _handleImageClick(imgs, idx),
                    );
                  }),
                ],

                // 4. General User Comments List (Sorted by active filter)
                if (_sortedComments.isNotEmpty) ...[
                  ..._sortedComments.map((comment) {
                    return PostCommentItem(
                      key: ValueKey(comment.id),
                      comment: comment,
                      onReplyClick: (u) => _handleReplyClick(u, comment.id),
                      onReplyToComment: (u, cId) => _handleReplyClick(u, cId),
                      onImageClick: (imgs, idx) => _handleImageClick(imgs, idx),
                    );
                  }),
                ],

                // Empty State if no comments and no threadChain
                if (_post.threadChain.isEmpty && _comments.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 40.0,
                          color: Color(0xFFCBD5E1),
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          _isProductMode ? 'Belum ada pertanyaan' : 'Belum ada komentar',
                          style: const TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          _isProductMode
                              ? 'Ingin tahu kondisi atau ketersediaan stok? Tanyakan langsung ke penjual.'
                              : 'Mulai percakapan dan jadilah yang pertama memberi tanggapan.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Bottom Buffer for Floating Capsule Dock
                const SizedBox(height: 100.0),
              ],
            ),
          ),

          // Bottom Floating Dock:
          // In Product Mode: Toggle between StickyBuyBar and CommentInputBar
          // In Thread Mode: Always show CommentInputBar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _isProductMode && !_isCommentingActive
                ? StickyBuyBar(
                    price: _post.price ?? 0,
                    originalPrice: _post.originalPrice,
                    stockCount: _post.stock,
                    onBuyClick: _handleBuySheet,
                    onChatClick: () {
                      final conv = ConversationModel(
                        id: 'conv-${_post.id}',
                        user: ConversationUser(
                          name: _post.seller.name,
                          username: _post.seller.username ?? _post.seller.name.toLowerCase().replaceAll(' ', ''),
                          avatar: _post.seller.avatar,
                          classGroup: _post.seller.classGroup,
                          isVerified: _post.seller.isVerified,
                        ),
                        lastMessage: 'Halo, saya tertarik dengan ${_post.title ?? 'produk ini'}',
                        timestamp: 'Baru saja',
                        isSeller: true,
                        productContext: ProductContext(
                          title: _post.title ?? 'Produk',
                          price: formatRupiah(_post.price ?? 0),
                          image: _post.images.isNotEmpty ? _post.images.first : null,
                        ),
                      );
                      DirectMessagesService.instance.addOrUpdateConversation(conv);
                      Navigator.of(context).push(
                        AppSlidePageRoute(
                          builder: (_) => ChatConversationScreen(conversation: conv),
                        ),
                      );
                    },
                  )
                : CommentInputBar(
                    targetAuthor: authorUsername,
                    replyToUser: _replyToUser,
                    onCancelReply: _handleCancelReply,
                    onSubmitComment: _handleAddComment,
                  ),
          ),
        ],
      ),
    ),
  );
}
}

