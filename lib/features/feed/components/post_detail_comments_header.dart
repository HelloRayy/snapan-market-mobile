import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CommentSortOrder { newest, top, oldest }

/// Section header dividing main post and comments with count and sort menu.
class PostDetailCommentsHeader extends StatelessWidget {
  final bool isProductMode;
  final int totalCount;
  final CommentSortOrder selectedSort;
  final ValueChanged<CommentSortOrder> onSortChanged;

  const PostDetailCommentsHeader({
    super.key,
    required this.isProductMode,
    required this.totalCount,
    required this.selectedSort,
    required this.onSortChanged,
  });

  PopupMenuItem<CommentSortOrder> _buildSortMenuItem(
    CommentSortOrder order,
    String title,
  ) {
    final isSelected = selectedSort == order;
    return PopupMenuItem<CommentSortOrder>(
      value: order,
      height: 38.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 14.0),
          if (isSelected)
            const Icon(
              Icons.check_rounded,
              size: 16.0,
              color: Color(0xFF0F172A),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isProductMode
                ? 'Tanya Jawab & Diskusi ($totalCount)'
                : 'Komentar ($totalCount)',
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          PopupMenuButton<CommentSortOrder>(
            initialValue: selectedSort,
            tooltip: 'Urutkan Komentar',
            onSelected: (val) {
              HapticFeedback.selectionClick();
              onSortChanged(val);
            },
            offset: const Offset(0, 26.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.0),
              side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
            ),
            elevation: 12,
            shadowColor: const Color(0x26000000),
            color: Colors.white,
            itemBuilder: (context) => [
              _buildSortMenuItem(CommentSortOrder.newest, 'Terbaru'),
              _buildSortMenuItem(CommentSortOrder.top, 'Teratas'),
              _buildSortMenuItem(CommentSortOrder.oldest, 'Terlama'),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedSort == CommentSortOrder.newest
                        ? 'Terbaru'
                        : selectedSort == CommentSortOrder.top
                            ? 'Teratas'
                            : 'Terlama',
                    style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 2.0),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16.0,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
