import "package:flutter/material.dart";
import "package:snapan_market/core/components/kumo_button.dart";
import "package:snapan_market/core/theme/app_colors.dart";
import "package:snapan_market/core/utils/formatters.dart";
import "package:snapan_market/features/checkout/components/checkout_hero_image.dart";
import "package:snapan_market/features/checkout/components/checkout_location_card.dart";
import "package:snapan_market/features/checkout/components/checkout_price_breakdown.dart";
import "package:snapan_market/features/checkout/components/checkout_product_header.dart";
import "package:snapan_market/features/checkout/components/checkout_seller_card.dart";
import "package:snapan_market/features/feed/models/market_post_model.dart";
import "package:snapan_market/features/locations/models/campus_location_spot.dart";
import "package:snapan_market/features/locations/screens/campus_locations_picker_screen.dart";
import "package:snapan_market/features/map/screens/campus_map_screen.dart";
import "package:snapan_market/features/messages/models/conversation_model.dart";
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
      MaterialPageRoute(
        builder: (_) => CampusLocationsPickerScreen(
          selectedSpot: _selectedSpot,
          onSpotSelected: (spot) {
            setState(() => _selectedSpot = spot);
          },
        ),
      ),
    );
  }

  void _openMapPicker() {
    Navigator.of(context).push(
      MaterialPageRoute(
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
                "Temui ${widget.post.sellerName} di ${_selectedSpot.name} (${_selectedSpot.buildingName}) saat jam istirahat sekolah.",
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
                iconLeft: const Icon(Icons.chat_bubble_outline_rounded, size: 18.0, color: Colors.white),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatConversationScreen(
                        conversation: ConversationModel(
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
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10.0),

              // Action 2: Back to Home
              KumoButton.secondary(
                text: "Kembali ke Beranda",
                width: double.infinity,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
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
                  title: widget.post.title ?? "Produk",
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
                                conversation: ConversationModel(
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
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12.0),

                      // Location Card with Blueprint & Spot Selector
                      CheckoutLocationCard(
                        selectedSpot: _selectedSpot,
                        onSelectSpotTap: _openLocationPicker,
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
                            Row(
                              children: const [
                                Icon(Icons.edit_note_rounded, size: 18.0, color: Color(0xFF334155)),
                                SizedBox(width: 8.0),
                                Text(
                                  "Catatan untuk Penjual",
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10.0),
                            TextField(
                              controller: _noteController,
                              maxLines: 2,
                              style: const TextStyle(fontSize: 13.0, color: Color(0xFF0F172A)),
                              decoration: InputDecoration(
                                hintText: "Misal: Aku pakai jaket hoodie abu-abu di meja pojok...",
                                hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 0.8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 0.8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(color: Color(0xFF3D38F5), width: 1.2),
                                ),
                                contentPadding: const EdgeInsets.all(12.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12.0),

                      // Price Breakdown Card
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

          // 3. Sticky Bottom CTA Bar
          Container(
            padding: EdgeInsets.fromLTRB(
              16.0,
              12.0,
              16.0,
              bottomPadding > 0 ? bottomPadding + 8.0 : 16.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 0.8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10.0,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Total Price Column
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total Pembayaran (COD)",
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        formatRupiah(widget.post.price ?? 0),
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Order Button
                SizedBox(
                  width: 170.0,
                  height: 48.0,
                  child: ElevatedButton(
                    onPressed: _isOrdering ? null : _handleOrderSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D38F5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                    ),
                    child: _isOrdering
                        ? const SizedBox(
                            width: 20.0,
                            height: 20.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Buat Pesanan COD",
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
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
