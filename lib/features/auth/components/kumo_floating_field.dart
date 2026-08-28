import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KumoFloatingField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixWidget;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;

  const KumoFloatingField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixWidget,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.errorText,
  });

  @override
  State<KumoFloatingField> createState() => _KumoFloatingFieldState();
}

class _KumoFloatingFieldState extends State<KumoFloatingField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_isFocused != _focusNode.hasFocus) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasError
              ? const Color(0xFFEF4444)
              : _isFocused
                  ? const Color(0xFF1D64EC) // Kumo Blue Focus
                  : const Color(0xFFE2E8F0),
          width: _isFocused || hasError ? 1.6 : 1.2,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFF1D64EC).withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Label Selalu di Atas (Highlights to Blue on Focus)
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: hasError
                  ? const Color(0xFFEF4444)
                  : _isFocused
                      ? const Color(0xFF1D64EC)
                      : const Color(0xFF64748B),
              letterSpacing: -0.2,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 3),

          // 2. Baris Input Teks (Di Bawah Label, 0% Overlap)
          Row(
            children: [
              if (widget.prefixWidget != null) ...[
                widget.prefixWidget!,
                const SizedBox(width: 8),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction:
                      widget.textInputAction ?? TextInputAction.next,
                  inputFormatters: widget.inputFormatters,
                  onSubmitted: widget.onSubmitted,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                    height: 1.25,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 2),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              if (widget.suffixIcon != null) ...[
                const SizedBox(width: 8),
                widget.suffixIcon!,
              ],
            ],
          ),

          // Error Text if any
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                widget.errorText!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
