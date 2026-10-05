import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Modal bottom sheet for comment options (Reply, Copy Text, Report, Delete)
class CommentOptionsSheet {
  static void show({
    required BuildContext context,
    required PostCommentModel comment,
    required String parentCommentId,
    String? postAuthorId,
    ValueChanged<String>? onReplyClick,
    void Function(String username, String commentId)? onReplyToComment,
    ValueChanged<String>? onDeleteComment,
  }) {
    final currentUserId = SupabaseService.instance.currentUser?.id;
    final bool isCommentAuthor = currentUserId != null && comment.user.id == currentUserId;
    final bool isPostAuthor = currentUserId != null && postAuthorId != null && postAuthorId == currentUserId;
    final bool canDelete = (isCommentAuthor || isPostAuthor) && onDeleteComment != null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.0,
                height: 4.0,
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.reply_rounded, color: Color(0xFF334155)),
                title: const Text(
                  'Balas Komentar',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  final rawUsername = (comment.user.username != null && comment.user.username!.isNotEmpty)
                      ? comment.user.username!
                      : comment.user.name;
                  final targetUsername = rawUsername.trim().replaceAll('@', '').replaceAll(' ', '_');
                  if (onReplyToComment != null) {
                    onReplyToComment(targetUsername, parentCommentId);
                  } else {
                    onReplyClick?.call(targetUsername);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_rounded, color: Color(0xFF334155)),
                title: const Text(
                  'Salin Teks Komentar',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Clipboard.setData(ClipboardData(text: comment.content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Teks komentar disalin ke papan klip')),
                  );
                },
              ),
              if (canDelete)
                ListTile(
                  leading: const Icon(CupertinoIcons.trash, color: AppColors.error),
                  title: const Text(
                    'Hapus Komentar',
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.error),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final bool? confirm = await _showDeleteConfirmation(context);
                    if (confirm == true) {
                      onDeleteComment(comment.id);
                    }
                  },
                ),
              if (!isCommentAuthor)
                ListTile(
                  leading: const Icon(Icons.report_outlined, color: Color(0xFFEF4444)),
                  title: const Text(
                    'Laporkan Komentar',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFEF4444)),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Laporan terkirim, terima kasih atas masukan Anda')),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<bool?> _showDeleteConfirmation(BuildContext context) {
    HapticFeedback.lightImpact();

    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 24.0),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.0,
                height: 4.0,
                margin: const EdgeInsets.only(bottom: 20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: const Center(
                  child: Icon(
                    CupertinoIcons.trash,
                    size: 24.0,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
              const SizedBox(height: 14.0),
              const Text(
                'Hapus Komentar?',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6.0),
              const Text(
                'Komentar ini akan dihapus secara permanen dan tidak dapat dipulihkan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.0,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13.0),
                        backgroundColor: AppColors.error,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                      ),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                      ),
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
