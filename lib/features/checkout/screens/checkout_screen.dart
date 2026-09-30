import 'package:flutter/material.dart';
import 'package:snapan_market/core/navigation/app_slide_page_route.dart';
import 'package:snapan_market/core/utils/formatters.dart';
import 'package:snapan_market/features/checkout/components/checkout_bottom_bar.dart';
import 'package:snapan_market/features/checkout/components/checkout_buyer_note_card.dart';
import 'package:snapan_market/features/checkout/components/checkout_hero_image.dart';
import 'package:snapan_market/features/checkout/components/checkout_location_card.dart';
import 'package:snapan_market/features/checkout/components/checkout_price_breakdown.dart';
import 'package:snapan_market/features/checkout/components/checkout_product_header.dart';
import 'package:snapan_market/features/checkout/components/checkout_seller_card.dart';
import 'package:snapan_market/features/checkout/components/checkout_success_modal.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';
import 'package:snapan_market/features/locations/models/campus_location_spot.dart';
import 'package:snapan_market/features/locations/screens/campus_locations_picker_screen.dart';
import 'package:snapan_market/features/map/screens/campus_map_screen.dart';
import 'package:snapan_market/features/messages/models/conversation_model.dart';
import 'package:snapan_market/features/messages/screens/chat_conversation_screen.dart';
import 'package:snapan_market/features/messages/services/direct_messages_service.dart';
import 'package:snapan_market/features/profile/screens/profile_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final MarketPost post;
  final VoidCallback? onBack;

  const CheckoutScreen({
    super.key,
    required this.post,
    this.onBack,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLiked = false;
  late CampusLocationSpot _selectedSpot;
  final TextEditingController _noteController = TextEditingController();
  bool _isOrdering = false;

  @override
  void initState() {
    super.initState();
    _selectedSpot = kCampusLocationSpots[0];
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _openLocationPicker() {
    Navigator.of(context).push(
      AppSlidePageRoute(
        builder: (_) => CampusLocationsPickerScreen(
          selectedSpot: _selectedSpot,
          onSpotSelected: (spot) => setState(() => _selectedSpot = spot),
        ),
      ),
    );
  }

  void _openMapPicker() {
    Navigator.of(context).push(
      AppSlidePageRoute(
        builder: (_) => CampusMapScreen(
          onBack: () => Navigator.of(context).pop(),
          onSelectLocation: (roomName, floor, category) {
            final matched = kCampusLocationSpots.firstWhere(
              (s) => s.name.toLowerCase().contains(roomName.toLowerCase()) ||
                     roomName.toLowerCase().contains(s.name.toLowerCase()),
              orElse: () => CampusLocationSpot(
                id: roomName.toLowerCase().replaceAll(" ", "-"),
                name: roomName,
                code: roomName.toUpperCase(),
                buildingName: "Area SMKN 8 Semarang",
                floor: floor,
                category: LocationCategory.lobby,
                categoryLabel: category,
                description: "Titik temu yang dipilih dari denah 2D sekolah.",
                codSafetyHint: "Janjian saat jam istirahat atau waktu luang.",
                bestTime: "Jam istirahat sekolah",
                pinPosition: const Offset(500, 400),
                iconData: Icons.place_rounded,
                themeColor: const Color(0xFF3D38F5),
              ),
            );

            setState(() => _selectedSpot = matched);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _handleOrderSubmit() async {
    setState(() => _isOrdering = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isOrdering = false);

    CheckoutSuccessModal.show(
      context: context,
      post: widget.post,
      selectedSpot: _selectedSpot,
    );
  }

  void _handleOpenChat() {
    final conv = ConversationModel(
      id: "conv-${widget.post.id}",
      user: ConversationUser(
        name: widget.post.sellerName,
        username: widget.post.sellerUsername,
        avatar: widget.post.sellerAvatar,
        classGroup: widget.post.department,
        isVerified: widget.post.seller.isVerified,
      ),
      lastMessage: "Halo, saya tertarik dengan ${widget.post.title ?? 'produk ini'}",
      timestamp: "Baru saja",
      isSeller: true,
      productContext: ProductContext(
        title: widget.post.title ?? "Produk",
        price: formatRupiah(widget.post.price ?? 0),
        image: widget.post.imageUrls.isNotEmpty ? widget.post.imageUrls.first : null,
      ),
    );
    DirectMessagesService.instance.addOrUpdateConversation(conv);
    Navigator.of(context).push(
      AppSlidePageRoute(
        builder: (_) => ChatConversationScreen(conversation: conv),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Container(
            color: Colors.white.withValues(alpha: 0.96),
            padding: EdgeInsets.only(
              top: topPadding > 0 ? topPadding + 4.0 : 10.0,
              left: 12.0,
              right: 12.0,
              bottom: 8.0,
            ),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 0.8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, size: 20.0, color: Color(0xFF0F172A)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36.0, minHeight: 36.0),
                  splashRadius: 20.0,
                ),
                const Text(
                  "Checkout Pesanan",
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _isLiked = !_isLiked),
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 20.0,
                    color: _isLiked ? const Color(0xFFF43F5E) : const Color(0xFF0F172A),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36.0, minHeight: 36.0),
                  splashRadius: 20.0,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              children: [
                CheckoutHeroImage(
                  images: widget.post.imageUrls,
                  title: widget.post.title ?? "Produk",
                ),
                const SizedBox(height: 14.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                        ),
                        child: CheckoutProductHeader(post: widget.post),
                      ),
                      const SizedBox(height: 12.0),
                      CheckoutSellerCard(
                        sellerName: widget.post.sellerName,
                        sellerUsername: widget.post.sellerUsername,
                        sellerAvatar: widget.post.sellerAvatar,
                        department: widget.post.department,
                        onProfileTap: () {
                          Navigator.of(context).push(
                            AppSlidePageRoute(
                              builder: (_) => ProfileScreen(
                                username: widget.post.sellerUsername,
                                onBack: () => Navigator.of(context).pop(),
                              ),
                            ),
                          );
                        },
                        onChatTap: _handleOpenChat,
                      ),
                      const SizedBox(height: 12.0),
                      CheckoutLocationCard(
                        selectedSpot: _selectedSpot,
                        onSelectSpotTap: _openLocationPicker,
                        onSelectMapTap: _openMapPicker,
                      ),
                      const SizedBox(height: 12.0),
                      CheckoutBuyerNoteCard(controller: _noteController),
                      const SizedBox(height: 12.0),
                      CheckoutPriceBreakdown(
                        price: widget.post.price ?? 0,
                        originalPrice: widget.post.originalPrice,
                      ),
                      const SizedBox(height: 24.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
          CheckoutBottomBar(
            price: widget.post.price ?? 0,
            isOrdering: _isOrdering,
            onOrderSubmit: _handleOrderSubmit,
          ),
        ],
      ),
    );
  }
}
