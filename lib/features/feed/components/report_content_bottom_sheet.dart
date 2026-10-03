import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/utils/snaps_toast.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Interactive Bottom Sheet for reporting content violations
class ReportContentBottomSheet extends StatefulWidget {
  final MarketPostModel post;

  const ReportContentBottomSheet({
    super.key,
    required this.post,
  });

  static Future<bool?> show(BuildContext context, {required MarketPostModel post}) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReportContentBottomSheet(post: post),
    );
  }

  @override
  State<ReportContentBottomSheet> createState() => _ReportContentBottomSheetState();
}

class _ReportContentBottomSheetState extends State<ReportContentBottomSheet> {
  final TextEditingController _detailsController = TextEditingController();
  String _selectedReason = 'Melanggar Tata Tertib Sekolah';
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _reasons = [
    {
      'label': 'Melanggar Tata Tertib Sekolah',
      'icon': CupertinoIcons.shield_fill,
      'desc': 'Konten tidak pantas di lingkungan SMKN 8 Semarang',
    },
    {
      'label': 'Ujaran Kasar / Tidak Pantas',
      'icon': CupertinoIcons.exclamationmark_triangle_fill,
      'desc': 'Kata-kata kasar, intimidasi, pelecehan, atau provokatif',
    },
    {
      'label': 'Dugaan Penipuan / Barang Fiktif',
      'icon': CupertinoIcons.money_dollar_circle_fill,
      'desc': 'Transaksi mencurigakan, barang palsu, atau scam',
    },
    {
      'label': 'Spam / Duplikasi Postingan',
      'icon': CupertinoIcons.doc_on_doc_fill,
      'desc': 'Mengirimkan pesan/postingan berulang tanpa konteks',
    },
    {
      'label': 'Lainnya',
      'icon': CupertinoIcons.ellipsis_circle_fill,
      'desc': 'Pelanggaran lain yang memerlukan peninjauan admin',
    },
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!SupabaseService.instance.isAuthenticated) {
      SnapsToast.show(context, 'Silakan masuk akun terlebih dahulu.');
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.lightImpact();

    try {
      await SupabaseService.instance.reportPost(
        postId: widget.post.id,
        reason: _selectedReason,
        details: _detailsController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context, true);
        SnapsToast.show(
          context,
          'Laporan berhasil dikirim ke Admin Sekolah.',
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        SnapsToast.show(
          context,
          'Gagal mengirim laporan: $e',
          backgroundColor: const Color(0xFFEF4444),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      padding: EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 20.0 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38.0,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 18.0),

          // Title & target post info
          Row(
            children: [
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(
                  CupertinoIcons.flag_fill,
                  color: Color(0xFFDC2626),
                  size: 18.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Laporkan Postingan',
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Laporan untuk @${widget.post.seller.username ?? widget.post.seller.name}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          const Text(
            'PILIH ALASAN PELANGGARAN',
            style: TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8.0),

          // List of reason choices
          ..._reasons.map((r) {
            final isSelected = _selectedReason == r['label'];
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedReason = r['label'] as String);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 8.0),
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.4 : 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      r['icon'] as IconData,
                      size: 19.0,
                      color: isSelected ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r['label'] as String,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected ? const Color(0xFF991B1B) : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            r['desc'] as String,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isSelected ? const Color(0xFFB91C1C) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        CupertinoIcons.checkmark_circle_fill,
                        color: Color(0xFFDC2626),
                        size: 19.0,
                      ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 10.0),

          // Catatan Tambahan (Opsional)
          TextField(
            controller: _detailsController,
            maxLines: 2,
            style: const TextStyle(fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'Tambahkan catatan atau bukti (opsional)...',
              hintStyle: const TextStyle(fontSize: 13.0, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 0.8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 0.8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // Submit button
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18.0,
                          height: 18.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Kirim Laporan',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
