import "package:flutter/material.dart";
import "package:snapan_market/core/theme/app_colors.dart";
import "package:snapan_market/core/utils/formatters.dart";
import "package:snapan_market/features/feed/models/market_post_model.dart";

class CheckoutProductHeader extends StatelessWidget {
  final MarketPost post;

  const CheckoutProductHeader({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Pill & Condition
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF0FF),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                (post.category != null && post.category!.isNotEmpty) ? post.category! : "Karya Siswa",
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3D38F5),
                  letterSpacing: -0.1,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                post.department.isNotEmpty ? post.department : "SMKN 8",
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),

        // Product Title
        Text(
          (post.title != null && post.title!.isNotEmpty) ? post.title! : "Produk Tanpa Judul",
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.4,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8.0),

        // Formatted Price in Rupiah
        Text(
          formatRupiah(post.price ?? 0),
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w900,
            color: Color(0xFF3D38F5),
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}
