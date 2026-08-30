import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/components/kumo_button.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/utils/formatters.dart';
import 'package:snapan_market/features/feed/components/market_feed_icons.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Interactive Buy Bottom Sheet for Instant COD Order Placement in SMKN 8
class BuyBottomSheet extends StatefulWidget {
  final MarketPostModel post;
  final VoidCallback? onConfirmOrder;
  final VoidCallback? onChatSeller;

  const BuyBottomSheet({
    super.key,
    required this.post,
    this.onConfirmOrder,
    this.onChatSeller,
  });

  static Future<void> show(
    BuildContext context, {
    required MarketPostModel post,
    VoidCallback? onConfirmOrder,
    VoidCallback? onChatSeller,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BuyBottomSheet(
        post: post,
        onConfirmOrder: onConfirmOrder,
        onChatSeller: onChatSeller,
      ),
    );
  }

  @override
  State<BuyBottomSheet> createState() => _BuyBottomSheetState();
}

class _BuyBottomSheetState extends State<BuyBottomSheet> {
  int _quantity = 1;

  int get _maxStock => widget.post.stock ?? 5;
  int get _unitPrice => widget.post.price ?? 0;
  int get _totalPrice => _unitPrice * _quantity;

  bool get _isService {
    final cat = (widget.post.category ?? '').toLowerCase();
    return cat.contains('jasa') || cat.contains('prakerin') || cat.contains('service');
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        boxShadow: [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 30.0,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, bottomPadding > 0 ? bottomPadding + 12.0 : 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),

              const SizedBox(height: 16.0),

              // 1. Seller Header Row
              Row(
                children: [
                  CircleAvatar(
                    radius: 20.0,
                    backgroundColor: const Color(0xFFF1F5F9),
                    backgroundImage: widget.post.seller.avatar.isNotEmpty
                        ? NetworkImage(widget.post.seller.avatar)
                        : null,
                    child: widget.post.seller.avatar.isEmpty
                        ? const Icon(Icons.person, color: AppColors.muted, size: 20)
                        : null,
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.post.seller.name,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            if (widget.post.seller.isVerified) ...[
                              const SizedBox(width: 4.0),
                              const VerifiedBadgeIcon(size: 14.0),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          widget.post.seller.classGroup,
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, size: 18.0, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14.0),
                child: Divider(color: Color(0xFFF1F5F9), height: 1.0),
              ),

              // 2. Product Summary Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Container(
                      width: 72.0,
                      height: 72.0,
                      color: const Color(0xFFF8FAFC),
                      child: widget.post.images.isNotEmpty
                          ? Image.network(
                              widget.post.images.first,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.image_not_supported_outlined,
                                color: AppColors.muted,
                              ),
                            )
                          : const Icon(Icons.shopping_bag_outlined, color: AppColors.muted),
                    ),
                  ),
                  const SizedBox(width: 14.0),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.title ?? widget.post.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Row(
                          children: [
                            Text(
                              AppFormatters.formatRupiah(_unitPrice),
                              style: const TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Text(
                                _isService ? '$_maxStock Slot' : 'Stok $_maxStock',
                                style: const TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14.0),

              // 3. Location Tag & Meeting Point Notice
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPastel,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        size: 16.0,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Titik Temu COD SMKN 8 Jakarta',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            widget.post.locationTag ?? 'Kantin / Lab Komputer SMKN 8',
                            style: const TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16.0),

              // 4. Quantity Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jumlah Pesanan',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_rounded, size: 18.0),
                          visualDensity: VisualDensity.compact,
                          onPressed: _quantity > 1
                              ? () {
                                  HapticFeedback.lightImpact();
                                  setState(() => _quantity -= 1);
                                }
                              : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_rounded, size: 18.0),
                          visualDensity: VisualDensity.compact,
                          onPressed: _quantity < _maxStock
                              ? () {
                                  HapticFeedback.lightImpact();
                                  setState(() => _quantity += 1);
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20.0),

              // 5. Total Price & Place Order Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        AppFormatters.formatRupiah(_totalPrice),
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: KumoButton.primary(
                      text: 'Konfirmasi COD',
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                        widget.onConfirmOrder?.call();
                      },
                    ),

                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
