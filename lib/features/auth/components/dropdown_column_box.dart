import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

class DropdownColumnBox extends StatelessWidget {
  final String label;
  final String? selectedValue;
  final String placeholder;
  final bool hasError;
  final List<String> options;
  final ValueChanged<String> onSelected;

  const DropdownColumnBox({
    super.key,
    required this.label,
    required this.selectedValue,
    this.placeholder = 'Pilih',
    this.hasError = false,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey boxKey = GlobalKey();
    final bool isSelected = selectedValue != null && selectedValue!.isNotEmpty;

    return GestureDetector(
      key: boxKey,
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        FocusManager.instance.primaryFocus?.unfocus();
        HapticFeedback.selectionClick();

        final renderBox =
            boxKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox == null) return;
        final offset = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;

        final selected = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            offset.dx,
            offset.dy + size.height + 4,
            offset.dx + size.width + 60,
            offset.dy + size.height + 300,
          ),
          color: Colors.white,
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
          ),
          menuPadding: const EdgeInsets.symmetric(vertical: 4),
          constraints: const BoxConstraints(minWidth: 150, maxWidth: 200),
          items: options.map((opt) {
            final isItemActive = opt == selectedValue;
            return PopupMenuItem<String>(
              value: opt,
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    opt,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isItemActive ? FontWeight.w700 : FontWeight.w500,
                      color: isItemActive ? AppColors.primary : AppColors.ink,
                    ),
                  ),
                  if (isItemActive)
                    const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF1D64EC),
                      size: 18,
                    ),
                ],
              ),
            );
          }).toList(),
        );

        FocusManager.instance.primaryFocus?.unfocus();

        if (selected != null) {
          HapticFeedback.selectionClick();
          onSelected(selected);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasError ? AppColors.error : const Color(0xFFE2E8F0),
            width: hasError ? 1.4 : 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: hasError ? AppColors.error : const Color(0xFF64748B),
                height: 1.1,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    isSelected ? selectedValue! : placeholder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF64748B),
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
