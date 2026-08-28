import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KumoAuthField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixWidget;

  const KumoAuthField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.prefixWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label Bagian Atas
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),

          // Baris Input
          Row(
            children: [
              if (prefixWidget != null) ...[
                prefixWidget!,
                const SizedBox(width: 10),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  textInputAction: textInputAction ?? TextInputAction.next,
                  inputFormatters: inputFormatters,
                  onSubmitted: onSubmitted,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
              suffixIcon ?? const SizedBox.shrink(),
            ],
          ),
        ],
      ),
    );
  }
}
