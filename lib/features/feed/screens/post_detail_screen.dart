import "package:snapan_market/features/checkout/screens/checkout_screen.dart";
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/feed/components/buy_bottom_sheet.dart';
import 'package:snapan_market/features/feed/components/comment_input_bar.dart';
import 'package:snapan_market/features/feed/components/market_post_card.dart';
import 'package:snapan_market/features/feed/components/post_comment_item.dart';
import 'package:snapan_market/features/feed/components/sticky_buy_bar.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

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

  const PostDetailScreen({
    super.key,
    required this.post,
    this.onLikeToggle,
    this.onBookmarkToggle,
    this.onRepostToggle,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late MarketPostModel _post;
  late List<PostCommentModel> _comments;
  CommentSortOrder _selectedSort = CommentSortOrder.newest;
  String? _replyToUser;
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

  void _handleAddComment(String content) {
    HapticFeedback.mediumImpact();
    final newComment = PostCommentModel(
      id: 'comment-local-${DateTime.now().millisecondsSinceEpoch}',
      postId: _post.id,
      user: const CommentUserModel(
        id: 'user-current',
        name: 'Raditya Rayhan',
        avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
        username: 'radityarayhannnn',
        classGroup: 'XII PPLG 1',
        isVerified: true,
      ),
      content: content,
      timestamp: 'Baru saja',
      likesCount: 0,
      isLiked: false,
    );

    setState(() {
      _comments.insert(0, newComment);
      _replyToUser = null;
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

  void _handleReplyClick(String username) {
    HapticFeedback.lightImpact();
    setState(() {
      _replyToUser = username;
      _isCommentingActive = true;
    });
  }

  void _handleCancelReply() {
    setState(() {
      _replyToUser = null;
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
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: Image.network(
                images[index],
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 16.0,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    color: Color(0x80000000),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 20.0),
                ),
              ),
            ),
          ],
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    final authorUsername = _post.seller.username ?? _post.seller.name;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFF1F5F9), width: 0.5),
            ),
          ),

          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back Arrow Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 44.0,
                      height: 44.0,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 22.0,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),

                  // Centered Title
                  const Text(
                    'Postingan',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),

                  // Spacer for Center Alignment
                  const SizedBox(width: 44.0),
                ],
              ),
            ),
          ),
        ),
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
                    widget.onLikeToggle?.call(updated);
                  },
                  onRepostToggle: (updated) {
                    setState(() {
                      _post = updated;
                    });
                    widget.onRepostToggle?.call(updated);
                  },
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
                      onReplyClick: _handleReplyClick,
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
                      onReplyClick: _handleReplyClick,
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
                      setState(() {
                        _isCommentingActive = true;
                      });
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

