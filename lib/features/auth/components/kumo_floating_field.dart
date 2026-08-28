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
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onTextChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;
    final isFloating = _isFocused || hasText;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Outer Container Box with Border & Focus Glow Ring
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: hasError
                      ? const Color(0xFFEF4444) // Error Red
                      : _isFocused
                          ? const Color(0xFF1D64EC) // Kumo Blue Focus
                          : const Color(0xFFE2E8F0), // Subtle Border
                  width: _isFocused || hasError ? 1.5 : 1.2,
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: const Color(0xFF1D64EC).withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Optional Prefix Widget (e.g. 🇮🇩 +62 badge)
                  if (widget.prefixWidget != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 14, right: 6),
                      child: widget.prefixWidget!,
                    ),
                  ] else
                    const SizedBox(width: 16),

                  // Actual Text Input Field
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
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  // Optional Suffix Icon (e.g. Eye Toggle)
                  if (widget.suffixIcon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: widget.suffixIcon!,
                    )
                  else
                    const SizedBox(width: 16),
                ],
              ),
            ),

            // 2. Animated Floating Label
            Positioned(
              left: isFloating
                  ? 14
                  : (widget.prefixWidget != null ? 84 : 16),
              top: isFloating ? -8 : 17,
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: isFloating ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      fontSize: isFloating ? 11.5 : 14.5,
                      fontWeight: isFloating ? FontWeight.w700 : FontWeight.w400,
                      color: hasError
                          ? const Color(0xFFEF4444)
                          : _isFocused
                              ? const Color(0xFF1D64EC)
                              : isFloating
                                  ? const Color(0xFF475569)
                                  : const Color(0xFF94A3B8),
                      letterSpacing: isFloating ? -0.2 : -0.1,
                      fontFamily: 'Inter',
                    ),
                    child: Text(widget.label),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Error message if any
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 14),
            child: Text(
              widget.errorText!,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFFEF4444),
              ),
            ),
          ),
      ],
    );
  }
}
