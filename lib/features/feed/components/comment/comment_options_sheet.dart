import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Modal bottom sheet for comment options (Reply, Copy Text, Report)
class CommentOptionsSheet {
  static void show({
    required BuildContext context,
    required PostCommentModel comment,
    required String parentCommentId,
    ValueChanged<String>? onReplyClick,
    void Function(String username, String commentId)? onReplyToComment,
  }) {
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
                title: const Text('Balas Komentar', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                onTap: () {
                  Navigator.pop(ctx);
                  final targetUsername = comment.user.username ?? comment.user.name;
                  if (onReplyToComment != null) {
                    onReplyToComment(targetUsername, parentCommentId);
                  } else {
                    onReplyClick?.call(targetUsername);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_rounded, color: Color(0xFF334155)),
                title: const Text('Salin Teks Komentar', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                onTap: () {
                  Navigator.pop(ctx);
                  Clipboard.setData(ClipboardData(text: comment.content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Teks komentar disalin ke papan klip')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.report_outlined, color: Color(0xFFEF4444)),
                title: const Text('Laporkan Komentar', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
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
}
