import 'package:flutter/material.dart';
import 'package:snapan-market/core/components/kumo_button.dart';
import 'package:snapan-market/core/navigation/app_slide_page_route.dart';
import 'package:snapan-market/core/utils/formatters.dart';
import 'package:snapan-market/features/feed/models/market_post_model.dart';
import 'package:snapan-market/features/locations/models/campus_location_spot.dart';
import 'package:snapan-market/features/messages/models/conversation_model.dart';
import 'package:snapan-market/features/messages/screens/chat_conversation_screen.dart';
import 'package:snapan-market/features/messages/services/direct_messages_service.dart';

/// Modal bottom sheet shown upon successful COD order creation.
class CheckoutSuccessModal extends StatelessWidget {
  final MarketPost post;
  final CampusLocationSpot selectedSpot;

  const CheckoutSuccessModal({
    super.key,
    required this.post,
    required this.selectedSpot,
  });

  static Future<void> show({
    required BuildContext context,
    required MarketPost post,
    required CampusLocationSpot selectedSpot,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CheckoutSuccessModal(
        post: post,
        selectedSpot: selectedSpot,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 24.0,
        bottom: MediaQuery.paddingOf(context).bottom + 20.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          const SizedBox(height: 20.0),
          Container(
            width: 64.0,
            height: 64.0,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, size: 36.0, color: Color(0xFF10B981)),
          ),
          const SizedBox(height: 16.0),
          const Text(
            "Pesanan COD Berhasil Dibuat!",
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            "Temui ${post.sellerName} di ${selectedSpot.name} (${selectedSpot.buildingName}) saat jam istirahat sekolah.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF64748B),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 24.0),
          KumoButton(
            text: "Kirim Pesan ke Penjual",
            iconLeft: const Icon(Icons.chat_bubble_outline_rounded, size: 18.0, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
              final conv = ConversationModel(
                id: "conv-${post.id}",
                user: ConversationUser(
                  name: post.sellerName,
                  username: post.sellerUsername,
                  avatar: post.sellerAvatar,
                  classGroup: post.department,
                  isVerified: post.seller.isVerified,
                ),
                lastMessage: "Halo, saya tertarik dengan ${post.title ?? 'produk ini'}",
                timestamp: "Baru saja",
                isSeller: true,
                productContext: ProductContext(
                  title: post.title ?? "Produk",
                  price: formatRupiah(post.price ?? 0),
                  image: post.imageUrls.isNotEmpty ? post.imageUrls.first : null,
                ),
              );
              DirectMessagesService.instance.addOrUpdateConversation(conv);
              Navigator.of(context).push(
                AppSlidePageRoute(
                  builder: (_) => ChatConversationScreen(conversation: conv),
                ),
              );
            },
          ),
          const SizedBox(height: 10.0),
          KumoButton.secondary(
            text: "Kembali ke Beranda",
            width: double.infinity,
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
