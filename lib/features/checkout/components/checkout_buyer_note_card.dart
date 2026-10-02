import 'package:flutter/material.dart';

/// Card containing buyer notes/instructions for the seller.
class CheckoutBuyerNoteCard extends StatelessWidget {
  final TextEditingController controller;

  const CheckoutBuyerNoteCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            controller: controller,
            maxLines: 2,
            style: const TextStyle(
              fontFamily: 'SFPro',
              fontSize: 13.0,
              color: Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: "Misal: Aku pakai jaket hoodie abu-abu di meja pojok...",
              hintStyle: const TextStyle(
                fontFamily: 'SFPro',
                fontSize: 12.5,
                color: Color(0xFF94A3B8),
              ),
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
    );
  }
}
