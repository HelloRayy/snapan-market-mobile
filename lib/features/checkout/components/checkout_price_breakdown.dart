import "package:flutter/material.dart";
import "package:snapan_market/core/theme/app_colors.dart";
import "package:snapan_market/core/utils/formatters.dart";

class CheckoutPriceBreakdown extends StatelessWidget {
  final int price;
  final int? originalPrice;

  const CheckoutPriceBreakdown({
    super.key,
    required this.price,
    this.originalPrice,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = originalPrice != null && originalPrice! > price;
    final discountAmount = hasDiscount ? originalPrice! - price : 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final cardBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final dividerColor = isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9);

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: cardBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Rincian Pembayaran (COD)",
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: primaryTextColor,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10.0),

          // Subtotal Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Harga Barang", style: TextStyle(fontSize: 12.5, color: secondaryTextColor)),
              Text(formatRupiah(price), style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600, color: primaryTextColor)),
            ],
          ),
          if (hasDiscount) ...[
            const SizedBox(height: 6.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Potongan Diskon", style: TextStyle(fontSize: 12.5, color: Color(0xFFEA580C))),
                Text("-${formatRupiah(discountAmount)}", style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.w700, color: Color(0xFFEA580C))),
              ],
            ),
          ],
          const SizedBox(height: 6.0),

          // Admin Fee Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Biaya Layanan Kampus", style: TextStyle(fontSize: 12.5, color: secondaryTextColor)),
              const Text("Rp 0 (Gratis)", style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
            ],
          ),
          const SizedBox(height: 10.0),
          Divider(color: dividerColor, height: 1.0, thickness: 0.8),
          const SizedBox(height: 10.0),

          // Total Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Bayar di Lokasi", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: primaryTextColor)),
              Text(
                formatRupiah(price),
                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w900, color: Color(0xFF3D38F5)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
