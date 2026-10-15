import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Card containing buyer notes/instructions for the seller.
class CheckoutBuyerNoteCard extends StatelessWidget {
  final TextEditingController controller;

  const CheckoutBuyerNoteCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final cardBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final fieldFillColor = isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF8FAFC);

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
          Row(
            children: [
              Icon(Icons.edit_note_rounded, size: 18.0, color: secondaryTextColor),
              const SizedBox(width: 8.0),
              Text(
                "Catatan untuk Penjual",
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: primaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          TextField(
            controller: controller,
            maxLines: 2,
            style: TextStyle(
              fontFamily: 'SFPro',
              fontSize: 13.0,
              color: primaryTextColor,
            ),
            decoration: InputDecoration(
              hintText: "Misal: Aku pakai jaket hoodie abu-abu di meja pojok...",
              hintStyle: TextStyle(
                fontFamily: 'SFPro',
                fontSize: 12.5,
                color: secondaryTextColor,
              ),
              filled: true,
              fillColor: fieldFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: cardBorder, width: 0.8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: cardBorder, width: 0.8),
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
    );
  }
}
