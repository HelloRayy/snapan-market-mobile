import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Reusable dropdown form field matching Snaps authentication & profile design system
class AppDropdownField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('$label-$value'),
      value: value,
      isExpanded: true,
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(16.0),
      elevation: 4,
      menuMaxHeight: 260.0,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF64748B),
        size: 18.0,
      ),
      style: const TextStyle(
        fontFamily: 'SFPro',
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: const TextStyle(
          fontFamily: 'SFPro',
          fontSize: 13.5,
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: TextStyle(
          fontFamily: 'SFPro',
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: hasError ? AppColors.error : AppColors.primary,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(
            color: hasError ? AppColors.error : const Color(0xFFE2E8F0),
            width: hasError ? 1.4 : 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
      ),
      items: options.map((opt) {
        return DropdownMenuItem<String>(
          value: opt,
          child: Text(
            opt,
            style: const TextStyle(
              fontFamily: 'SFPro',
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        );
      }).toList(),
      onChanged: (val) {
        HapticFeedback.selectionClick();
        onChanged(val);
      },
    );
  }
}
