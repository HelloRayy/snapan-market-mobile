import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Modern iOS/Kumo Squircle Bottom Sheet for Confirming Post Deletion
class DeletePostBottomSheet extends StatelessWidget {
  final MarketPostModel post;
  final bool isAdmin;

  const DeletePostBottomSheet({
    super.key,
    required this.post,
    this.isAdmin = false,
  });

  /// Displays the confirmation sheet and returns true if user confirmed deletion
  static Future<bool?> show(
    BuildContext context, {
    required MarketPostModel post,
    bool isAdmin = false,
  }) {
    HapticFeedback.lightImpact();

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DeletePostBottomSheet(
        post: post,
        isAdmin: isAdmin,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final snippet = post.caption.trim();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        boxShadow: [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 24.0,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20.0,
            12.0,
            20.0,
            bottomPadding > 0 ? bottomPadding + 8.0 : 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Drag Handle
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

              const SizedBox(height: 20.0),

              // 2. Destructive Icon Badge
              Center(
                child: Container(
                  width: 52.0,
                  height: 52.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.trash,
                      size: 26.0,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16.0),

              // 3. Title
              Text(
                isAdmin ? 'Hapus Postingan Siswa?' : 'Hapus Postingan?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 8.0),

              // 4. Description
              Text(
                isAdmin
                    ? 'Sebagai admin/moderator, postingan ini akan dihapus permanen dari feed dan katalog Snapan Market beserta seluruh komentar dan interaksinya.'
                    : 'Postingan ini akan dihapus secara permanen dari feed Snapan Market beserta seluruh komentar, foto, dan tanda sukanya. Tindakan ini tidak dapat dibatalkan.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                  height: 1.45,
                ),
              ),

              // 5. Post Snippet Preview Box
              if (snippet.isNotEmpty) ...[
                const SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.quote_bubble,
                        size: 16.0,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          snippet,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.0,
                            color: Color(0xFF475569),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24.0),

              // 6. Action Buttons
              // Destructive Delete Button
              SizedBox(
                height: 48.0,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  child: const Text('Hapus Sekarang'),
                ),
              ),

              const SizedBox(height: 10.0),

              // Cancel Button
              SizedBox(
                height: 48.0,
                child: TextButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pop(false);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: const Color(0xFF475569),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
