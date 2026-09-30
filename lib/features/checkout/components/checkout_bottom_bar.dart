import 'package:flutter/material.dart';
import 'package:snapan_market/core/utils/formatters.dart';

/// Sticky bottom CTA bar with total COD price and submit order button.
class CheckoutBottomBar extends StatelessWidget {
  final int price;
  final bool isOrdering;
  final VoidCallback onOrderSubmit;

  const CheckoutBottomBar({
    super.key,
    required this.price,
    required this.isOrdering,
    required this.onOrderSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
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
                  formatRupiah(price),
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
          SizedBox(
            width: 170.0,
            height: 48.0,
            child: ElevatedButton(
              onPressed: isOrdering ? null : onOrderSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D38F5),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
              ),
              child: isOrdering
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
    );
  }
}
