import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Clean, modern dropdown field matching the Snaps design system.
/// Uses custom popup overlay to eliminate Material 3 tonal beige tint.
class AppDropdownField extends StatefulWidget {
  final String label;
  final String? value;
  final List<String> options;
  final bool hasError;
  final ValueChanged<String?> onChanged;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    this.hasError = false,
    required this.onChanged,
  });

  @override
  State<AppDropdownField> createState() => _AppDropdownFieldState();
}

class _AppDropdownFieldState extends State<AppDropdownField> {
  bool _isOpen = false;

  Future<void> _handleTap() async {
    FocusManager.instance.primaryFocus?.unfocus();
    HapticFeedback.lightImpact();

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenWidth = MediaQuery.of(context).size.width;

    final popupWidth = math.max(size.width, 105.0);
    final double left = offset.dx.clamp(8.0, math.max(8.0, screenWidth - popupWidth - 8.0));
    final double right = screenWidth - (left + popupWidth);
    final double top = offset.dy + size.height + 4.0;
    final double bottom = offset.dy + size.height + 280.0;

    setState(() => _isOpen = true);

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(left, top, right, bottom),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
      ),
      menuPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
      constraints: BoxConstraints(minWidth: popupWidth, maxWidth: popupWidth + 24.0),
      items: widget.options.map((opt) {
        final isItemActive = opt == widget.value;
        return PopupMenuItem<String>(
          value: opt,
          height: 38.0,
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: isItemActive ? AppColors.primaryPastel : Colors.transparent,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  opt,
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 14.0,
                    fontWeight: isItemActive ? FontWeight.w700 : FontWeight.w500,
                    color: isItemActive ? AppColors.primary : const Color(0xFF0F172A),
                  ),
                ),
                if (isItemActive)
                  const Icon(
                    Icons.check_rounded,
                    color: AppColors.primary,
                    size: 16.0,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );

    if (mounted) {
      setState(() => _isOpen = false);
    }

    if (selected != null && selected != widget.value) {
      HapticFeedback.selectionClick();
      widget.onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelected = widget.value != null && widget.value!.isNotEmpty;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48.0,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: widget.hasError
                ? AppColors.error
                : (_isOpen ? AppColors.primary : const Color(0xFFE2E8F0)),
            width: (widget.hasError || _isOpen) ? 1.6 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                isSelected ? widget.value! : widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: isSelected ? 14.5 : 13.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                ),
              ),
            ),
            const SizedBox(width: 4.0),
            AnimatedRotation(
              turns: _isOpen ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18.0,
                color: _isOpen ? AppColors.primary : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
