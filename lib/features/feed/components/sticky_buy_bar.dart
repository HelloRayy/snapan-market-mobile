import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/utils/formatters.dart';

/// Floating bottom dock bar for Marketplace Product Posts
///
/// Features:
/// - Left action: Secondary circular button to toggle comment/chat input bar
/// - Right action: Electric Indigo primary button displaying 'Beli Sekarang' + Formatted Price
class StickyBuyBar extends StatelessWidget {
  final int price;
  final int? originalPrice;
  final int? stockCount;
  final VoidCallback? onBuyClick;
  final VoidCallback? onChatClick;

  const StickyBuyBar({
    super.key,
    required this.price,
    this.originalPrice,
    this.stockCount,
    this.onBuyClick,
    this.onChatClick,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: bottomPadding > 0 ? bottomPadding + 8.0 : 16.0,
      ),
      child: Container(
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(32.0),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 28.0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Secondary Button: "Tanya Penjual" (Chat icon)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onChatClick?.call();
                },
                borderRadius: BorderRadius.circular(22.0),
                child: Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 20.0,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8.0),

            // Right Primary Button: "Beli Sekarang" + Price
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onBuyClick?.call();
                  },
                  borderRadius: BorderRadius.circular(24.0),
                  child: Ink(
                    height: 44.0,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(color: const Color(0xFF312BD9), width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.25),
                          blurRadius: 10.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Label with Credit Card icon
                        const Row(
                          children: [
                            Icon(
                              Icons.credit_card_rounded,
                              size: 18.0,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              'Beli Sekarang',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ],
                        ),

                        // Right Formatted Price
                        Text(
                          AppFormatters.formatRupiah(price),
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
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
