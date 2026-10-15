import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

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
    BuildContext context,
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
              color: isSelected
                  ? AppColors.adaptiveText(context)
                  : AppColors.adaptiveMuted(context),
            ),
          ),
          const SizedBox(width: 14.0),
          if (isSelected)
            Icon(
              Icons.check_rounded,
              size: 16.0,
              color: AppColors.adaptiveText(context),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.adaptiveCanvas(context),
        border: Border(
          bottom: BorderSide(color: AppColors.adaptiveDivider(context), width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isProductMode
                ? 'Tanya Jawab & Diskusi ($totalCount)'
                : 'Komentar ($totalCount)',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: AppColors.adaptiveText(context),
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
              side: BorderSide(color: AppColors.adaptiveDivider(context), width: 1.0),
            ),
            elevation: 3,
            color: AppColors.adaptiveSurfaceElevated(context),
            itemBuilder: (ctx) => [
              _buildSortMenuItem(ctx, CommentSortOrder.newest, 'Terbaru'),
              _buildSortMenuItem(ctx, CommentSortOrder.top, 'Teratas'),
              _buildSortMenuItem(ctx, CommentSortOrder.oldest, 'Terlama'),
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
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.adaptiveMuted(context),
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
