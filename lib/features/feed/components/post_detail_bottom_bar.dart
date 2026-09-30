import 'package:flutter/material.dart';
import 'package:snapan-market/core/navigation/app_slide_page_route.dart';
import 'package:snapan-market/core/utils/formatters.dart';
import 'package:snapan-market/features/feed/components/comment_input_bar.dart';
import 'package:snapan-market/features/feed/components/sticky_buy_bar.dart';
import 'package:snapan-market/features/feed/models/market_post_model.dart';
import 'package:snapan-market/features/messages/models/conversation_model.dart';
import 'package:snapan-market/features/messages/screens/chat_conversation_screen.dart';
import 'package:snapan-market/features/messages/services/direct_messages_service.dart';

/// Floating bottom action bar switching between StickyBuyBar (product mode) and CommentInputBar.
class PostDetailBottomBar extends StatelessWidget {
  final bool isProductMode;
  final bool isCommentingActive;
  final MarketPostModel post;
  final String? replyToUser;
  final VoidCallback onBuyClick;
  final VoidCallback onCancelReply;
  final ValueChanged<String> onSubmitComment;

  const PostDetailBottomBar({
    super.key,
    required this.isProductMode,
    required this.isCommentingActive,
    required this.post,
    required this.replyToUser,
    required this.onBuyClick,
    required this.onCancelReply,
    required this.onSubmitComment,
  });

  @override
  Widget build(BuildContext context) {
    if (isProductMode && !isCommentingActive) {
      return StickyBuyBar(
        price: post.price ?? 0,
        originalPrice: post.originalPrice,
        stockCount: post.stock,
        onBuyClick: onBuyClick,
        onChatClick: () {
          final conv = ConversationModel(
            id: 'conv-${post.id}',
            user: ConversationUser(
              name: post.seller.name,
              username: post.seller.username ?? post.seller.name.toLowerCase().replaceAll(' ', ''),
              avatar: post.seller.avatar,
              classGroup: post.seller.classGroup,
              isVerified: post.seller.isVerified,
            ),
            lastMessage: 'Halo, saya tertarik dengan ${post.title ?? 'produk ini'}',
            timestamp: 'Baru saja',
            isSeller: true,
            productContext: ProductContext(
              title: post.title ?? 'Produk',
              price: formatRupiah(post.price ?? 0),
              image: post.images.isNotEmpty ? post.images.first : null,
            ),
          );
          DirectMessagesService.instance.addOrUpdateConversation(conv);
          Navigator.of(context).push(
            AppSlidePageRoute(
              builder: (_) => ChatConversationScreen(conversation: conv),
            ),
          );
        },
      );
    }

    final authorUsername = post.seller.username ?? post.seller.name;
    return CommentInputBar(
      targetAuthor: authorUsername,
      replyToUser: replyToUser,
      onCancelReply: onCancelReply,
      onSubmitComment: onSubmitComment,
    );
  }
}
