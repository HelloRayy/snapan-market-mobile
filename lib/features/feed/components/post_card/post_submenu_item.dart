import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Interactive Row Item for PostSubmenuPopover (<80 lines)
class PostSubmenuItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback onTap;

  const PostSubmenuItem({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
    this.textColor,
    required this.onTap,
  });

  @override
  State<PostSubmenuItem> createState() => _PostSubmenuItemState();
}

class _PostSubmenuItemState extends State<PostSubmenuItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 9.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: _isPressed
              ? (isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC))
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              widget.icon,
              size: 18.0,
              color: widget.iconColor ?? (isDark ? AppColors.darkTextSecondary : const Color(0xFF334155)),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: widget.textColor ?? AppColors.adaptiveText(context),
                  letterSpacing: -0.15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
