import "package:flutter/material.dart";
import "package:snapan_market/core/utils/formatters.dart";

class CheckoutPriceBreakdown extends StatelessWidget {
  final int productPrice;

  const CheckoutPriceBreakdown({super.key, required this.productPrice});

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
          const Text(
            "Rincian Pembayaran (COD)",
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10.0),

          // Subtotal Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Harga Barang", style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
              Text(formatRupiah(productPrice), style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 6.0),

          // Admin Fee Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Biaya Layanan Kampus", style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
              Text("Rp 0 (Gratis)", style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
            ],
          ),
          const SizedBox(height: 10.0),
          const Divider(color: Color(0xFFF1F5F9), height: 1.0, thickness: 0.8),
          const SizedBox(height: 10.0),

          // Total Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Bayar di Lokasi", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              Text(
                formatRupiah(productPrice),
                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w900, color: Color(0xFF3D38F5)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
