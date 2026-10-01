import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/components/glass_toolbar_top.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/utils/snaps_toast.dart';
import 'package:snapan_market/features/feed/components/buy_bottom_sheet.dart';
import 'package:snapan_market/features/feed/components/market_post_card.dart';
import 'package:snapan_market/features/feed/components/media_lightbox_dialog.dart';
import 'package:snapan_market/features/feed/components/post_detail_bottom_bar.dart';
import 'package:snapan_market/features/feed/components/post_detail_comments_header.dart';
import 'package:snapan_market/features/feed/components/post_detail_comments_list.dart';
import 'package:snapan_market/features/feed/controllers/post_detail_controller.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Focused single post detail view with author thread continuation, comments, and buyer actions.
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
  late final PostDetailController _controller;
  CommentSortOrder _selectedSort = CommentSortOrder.newest;
  final ScrollController _scrollController = ScrollController();

  bool get _isProductMode => _controller.post.isProduct && (_controller.post.price ?? 0) > 0;

  List<PostCommentModel> get _sortedComments {
    final list = List<PostCommentModel>.from(_controller.comments);
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

  int get _totalCommentsCount {
    final chainCount = _controller.post.threadChain.length;
    int directCount = _controller.comments.length;
    for (final c in _controller.comments) {
      directCount += c.replies.length;
    }
    return chainCount + directCount;
  }

  @override
  void initState() {
    super.initState();
    _controller = PostDetailController(post: widget.post);
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleBuySheet() {
    BuyBottomSheet.show(
      context,
      post: _controller.post,
      onConfirmOrder: () {
        SnapsToast.show(
          context,
          'Pesanan COD berhasil dibuat untuk ${_controller.post.seller.name}!',
          hasBottomNav: false,
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 3),
        );
      },
    );
  }

  void _handleImageClick(List<String> images, int index) {
    MediaLightboxDialog.show(
      context: context,
      images: images,
      initialIndex: index,
      post: _controller.post,
      onLikeToggle: widget.onLikeToggle,
      onRepostToggle: widget.onRepostToggle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = _controller.post;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, {'updatedPost': post});
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: GlassToolbarTop(
          leadingIcon: CupertinoIcons.chevron_back,
          leadingTooltip: 'Kembali',
          onLeadingTap: () => Navigator.pop(context, {'updatedPost': post}),
          title: 'Postingan',
          showVerifiedBadge: false,
          trailingActions: [
            GlassToolbarAction(
              icon: CupertinoIcons.share,
              tooltip: 'Bagikan postingan',
              onTap: () {
                HapticFeedback.lightImpact();
                Clipboard.setData(ClipboardData(text: 'https://snapan.id/post/${post.id}'));
                SnapsToast.show(
                  context,
                  'Tautan postingan berhasil disalin',
                  hasBottomNav: false,
                );
              },
            ),
            GlassToolbarAction(
              icon: CupertinoIcons.ellipsis,
              tooltip: 'Menu lainnya',
              onTap: () => _controller.showSubmenu(
                context: context,
                onBookmarkToggle: widget.onBookmarkToggle,
                onDeletePost: widget.onDeletePost,
              ),
            ),
          ],
        ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MarketPostCard(
                    item: post,
                    variant: 'detail',
                    onLikeToggle: (updated) {
                      setState(() => _controller.post = updated);
                      SupabaseService.instance.togglePostLike(updated.id, !updated.isLiked);
                      widget.onLikeToggle?.call(updated);
                    },
                    onRepostToggle: (updated) {
                      setState(() => _controller.post = updated);
                      widget.onRepostToggle?.call(updated);
                    },
                    onDeletePost: (_) => _controller.showSubmenu(
                      context: context,
                      onBookmarkToggle: widget.onBookmarkToggle,
                      onDeletePost: widget.onDeletePost,
                    ),
                    onImageClick: (item, idx) => _handleImageClick(item.images, idx),
                    onVotePoll: (item, optionIds) => _controller.votePoll(optionIds),
                  ),
                  PostDetailCommentsHeader(
                    isProductMode: _isProductMode,
                    totalCount: _totalCommentsCount,
                    selectedSort: _selectedSort,
                    onSortChanged: (val) => setState(() => _selectedSort = val),
                  ),
                  PostDetailCommentsList(
                    post: post,
                    comments: _sortedComments,
                    isLoadingComments: _controller.isLoadingComments,
                    isProductMode: _isProductMode,
                    onReplyClick: (u, [cId]) => _controller.setReply(u, cId),
                    onImageClick: _handleImageClick,
                  ),
                  const SizedBox(height: 100.0),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: PostDetailBottomBar(
                isProductMode: _isProductMode,
                isCommentingActive: _controller.isCommentingActive,
                post: post,
                replyToUser: _controller.replyToUser,
                onBuyClick: _handleBuySheet,
                onCancelReply: () => _controller.cancelReply(_isProductMode),
                onSubmitComment: (content) => _controller.addComment(context, content, _isProductMode),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
