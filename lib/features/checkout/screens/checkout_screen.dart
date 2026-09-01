import "package:flutter/material.dart";
import "package:snapan_market/core/components/kumo_button.dart";
import "package:snapan_market/core/theme/app_colors.dart";
import "package:snapan_market/core/utils/formatters.dart";
import "package:snapan_market/features/checkout/components/checkout_hero_image.dart";
import "package:snapan_market/features/checkout/components/checkout_location_card.dart";
import "package:snapan_market/features/checkout/components/checkout_price_breakdown.dart";
import "package:snapan_market/features/checkout/components/checkout_product_header.dart";
import "package:snapan_market/features/checkout/components/checkout_seller_card.dart";
import "package:snapan_market/features/checkout/models/checkout_models.dart";
import "package:snapan_market/features/feed/models/market_post_model.dart";
import "package:snapan_market/features/map/screens/campus_map_screen.dart";
import "package:snapan_market/features/messages/screens/chat_conversation_screen.dart";
import "package:snapan_market/features/profile/screens/profile_screen.dart";

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
  late CheckoutSpot _selectedSpot;
  final TextEditingController _noteController = TextEditingController();
  bool _isOrdering = false;

  @override
  void initState() {
    super.initState();
    _selectedSpot = kDefaultCampusSpots[0];
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _openMapPicker() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CampusMapScreen(
          onBack: () => Navigator.of(context).pop(),
          onSelectLocation: (roomName, floor, category) {
            setState(() {
              _selectedSpot = CheckoutSpot(
                id: roomName.toLowerCase().replaceAll(" ", "-"),
                name: roomName,
                building: "Area SMKN 8",
                floor: floor,
                categoryLabel: category,
                hint: "Titik temu yang dipilih dari denah 2D sekolah.",
              );
            });
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

    _showOrderSuccessModal();
  }

  void _showOrderSuccessModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
          ),
          padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 24.0,
            bottom: MediaQuery.paddingOf(ctx).bottom + 20.0,
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

              // Success Icon
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
                "Temui ${widget.post.sellerName} di ${_selectedSpot.name} saat jam istirahat sekolah.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24.0),

              // Action 1: Chat Seller
              KumoButton(
                text: "Kirim Pesan ke Penjual",
                icon: Icons.chat_bubble_outline_rounded,
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatConversationScreen(
                        conversationId: "conv-${widget.post.id}",
                        recipientName: widget.post.sellerName,
                        recipientUsername: widget.post.sellerUsername,
                        recipientAvatar: widget.post.sellerAvatar,
                        productCardPost: widget.post,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10.0),

              // Action 2: Back to Home
              OutlinedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F172A),
                  side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                  minimumSize: const Size(double.infinity, 48.0),
                ),
                child: const Text(
                  "Kembali ke Beranda",
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // 1. Sticky Top Navigation Bar
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

          // 2. Scrollable Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              children: [
                // Hero Image Carousel
                CheckoutHeroImage(
                  images: widget.post.imageUrls,
                  title: widget.post.title,
                ),
                const SizedBox(height: 14.0),

                // Form Container
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Column(
                    children: [
                      // Product Info Box
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

                      // Seller Card
                      CheckoutSellerCard(
                        sellerName: widget.post.sellerName,
                        sellerUsername: widget.post.sellerUsername,
                        sellerAvatar: widget.post.sellerAvatar,
                        department: widget.post.department,
                        onProfileTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProfileScreen(
                                username: widget.post.sellerUsername,
                                onBack: () => Navigator.of(context).pop(),
                              ),
                            ),
                          );
                        },
                        onChatTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatConversationScreen(
                                conversationId: "conv-${widget.post.id}",
                                recipientName: widget.post.sellerName,
                                recipientUsername: widget.post.sellerUsername,
                                recipientAvatar: widget.post.sellerAvatar,
                                productCardPost: widget.post,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12.0),

                      // Location Card with Blueprint Picker
                      CheckoutLocationCard(
                        selectedSpot: _selectedSpot,
                        onSelectMapTap: _openMapPicker,
                      ),
                      const SizedBox(height: 12.0),

                      // Buyer Note Input
                      Container(
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Catatan untuk Penjual (Opsional)",
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            TextField(
                              controller: _noteController,
                              maxLines: 3,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0F172A),
                              ),
                              decoration: InputDecoration(
                                hintText: "Contoh: Bawa pas jam istirahat pertama di meja kantin nomor 4 ya kak.",
                                hintStyle: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF94A3B8),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 0.8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 0.8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: const BorderSide(color: Color(0xFF3D38F5), width: 1.2),
                                ),
                                contentPadding: const EdgeInsets.all(12.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12.0),

                      // Price Breakdown
                      CheckoutPriceBreakdown(productPrice: widget.post.price),
                      const SizedBox(height: 24.0),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Sticky Bottom Buy Dock Bar
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 12.0,
              bottom: bottomPadding > 0 ? bottomPadding + 8.0 : 14.0,
            ),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 0.8)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Total COD",
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      formatRupiah(widget.post.price),
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF3D38F5),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16.0),

                Expanded(
                  child: KumoButton(
                    text: _isOrdering ? "Memproses..." : "Pesankan Sekarang",
                    icon: Icons.shopping_bag_outlined,
                    onTap: _isOrdering ? null : _handleOrderSubmit,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
