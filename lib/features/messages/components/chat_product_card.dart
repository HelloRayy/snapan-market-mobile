import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:snapan_market/core/theme/app_colors.dart";
import "package:snapan_market/features/messages/models/conversation_model.dart";

enum ChatProductCardShape { single, firstReceived, lastReceived }

/// Kartu konteks produk COD 1:1 matching ChatProductCard.tsx
class ChatProductCard extends StatelessWidget {
  final ProductContext product;
  final String location;
  final ChatProductCardShape shape;
  final VoidCallback? onViewProduct;
  final VoidCallback? onCheckLocation;

  const ChatProductCard({
    super.key,
    required this.product,
    this.location = "Lab Fisika Lt 2",
    this.shape = ChatProductCardShape.firstReceived,
    this.onViewProduct,
    this.onCheckLocation,
  });

  BorderRadius _getBorderRadius() {
    switch (shape) {
      case ChatProductCardShape.single:
        return BorderRadius.circular(20.0);
      case ChatProductCardShape.firstReceived:
        return const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
          bottomLeft: Radius.circular(6.0),
        );
      case ChatProductCardShape.lastReceived:
        return const BorderRadius.only(
          topLeft: Radius.circular(6.0),
          topRight: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
          bottomLeft: Radius.circular(4.0),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxCardWidth = screenWidth * 0.85;

    return Container(
      constraints: BoxConstraints(maxWidth: maxCardWidth),
      margin: const EdgeInsets.only(bottom: 6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _getBorderRadius(),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6.0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Top Inset Summary Box
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onViewProduct?.call();
              },
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: const Color(0xFFF1F5F9),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        product.image ?? "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600&q=80",
                        width: 56.0,
                        height: 56.0,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 56.0,
                          height: 56.0,
                          color: const Color(0xFFE2E8F0),
                          child: const Icon(Icons.shopping_bag_outlined, color: AppColors.muted, size: 24.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),

                    // Product Text Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF475569),
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 3.0),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 13.0,
                                color: Color(0xFF64748B),
                              ),
                              children: [
                                const TextSpan(text: "Total: "),
                                TextSpan(
                                  text: product.price,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3.0),
                          const Text(
                            "Terverifikasi",
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1D64EC),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Thin Horizontal Divider
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(
                color: Color(0xFFF1F5F9),
                height: 1.0,
                thickness: 0.8,
              ),
            ),

            // 3. Titik COD Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Titik COD",
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10.0),

            // 4. Full-Width "Cek Lokasi di Peta" Secondary Action Button (1:1 Web)
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                onCheckLocation?.call();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.0,
                  ),
                ),
                child: const Text(
                  "Cek Lokasi di Peta",
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
