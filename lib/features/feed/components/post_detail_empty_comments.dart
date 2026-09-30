import 'package:flutter/material.dart';

/// Empty state placeholder when a post has no comments or thread continuations.
class PostDetailEmptyComments extends StatelessWidget {
  final bool isProductMode;

  const PostDetailEmptyComments({
    super.key,
    required this.isProductMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.chat_bubble_outline_rounded,
            size: 40.0,
            color: Color(0xFFCBD5E1),
          ),
          const SizedBox(height: 12.0),
          Text(
            isProductMode ? 'Belum ada pertanyaan' : 'Belum ada komentar',
            style: const TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            isProductMode
                ? 'Ingin tahu kondisi atau ketersediaan stok? Tanyakan langsung ke penjual.'
                : 'Mulai percakapan dan jadilah yang pertama memberi tanggapan.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
