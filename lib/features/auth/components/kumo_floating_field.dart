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

class _KumoFloatingFieldState extends State<KumoFloatingField>
    with SingleTickerProviderStateMixin {
  AnimationController? _animController;
  Animation<double>? _anim;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _focusNode.addListener(_handleFocusChange);
    widget.controller.addListener(_handleTextChange);
  }

  @override
  void reassemble() {
    super.reassemble();
    _initAnimation();
  }

  void _initAnimation() {
    final bool initiallyFloating = widget.controller.text.isNotEmpty;
    _animController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      value: initiallyFloating ? 1.0 : 0.0,
    );
    _anim ??= CurvedAnimation(
      parent: _animController!,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    widget.controller.removeListener(_handleTextChange);
    _focusNode.dispose();
    _animController?.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_isFocused != _focusNode.hasFocus) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      _updateAnimation();
    }
  }

  void _handleTextChange() {
    _updateAnimation();
  }

  void _updateAnimation() {
    if (_animController == null) return;
    final bool shouldFloat = _isFocused || widget.controller.text.isNotEmpty;
    if (shouldFloat && _animController!.value != 1.0) {
      _animController!.forward();
    } else if (!shouldFloat && _animController!.value != 0.0) {
      _animController!.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    _initAnimation();
    final anim = _anim!;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        final double progress = anim.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Kotak Container Utama
                Container(
                  height: 56,
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
                              color: const Color(0xFF1D64EC)
                                  .withValues(alpha: 0.14),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Prefix Widget (misal: 🇮🇩 +62)
                      if (widget.prefixWidget != null) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 12, right: 12),
                          child: widget.prefixWidget!,
                        ),
                      ] else
                        const SizedBox(width: 16),

                      // Input TextField
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
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),

                      // Suffix Icon (misal: toggle mata password)
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

                // 2. Animated Floating Label Melayang ke Border Atas
                Positioned(
                  left: Tween<double>(
                    begin: widget.prefixWidget != null ? 98.0 : 16.0,
                    end: 14.0,
                  ).evaluate(anim),
                  top: Tween<double>(
                    begin: 17.0, // Posisi tengah saat belum diketik & belum fokus
                    end: -9.0,   // Posisi melayang di atas border saat fokus / ada teks
                  ).evaluate(anim),
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: progress > 0.2
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: Tween<double>(
                            begin: 14.5,
                            end: 11.5,
                          ).evaluate(anim),
                          fontWeight: progress > 0.5
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: hasError
                              ? const Color(0xFFEF4444)
                              : _isFocused
                                  ? const Color(0xFF1D64EC)
                                  : Color.lerp(
                                      const Color(0xFF94A3B8), // Abu-abu saat di tengah
                                      const Color(0xFF475569), // Dark slate saat di atas
                                      progress,
                                    ),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Error Text jika ada
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
      },
    );
  }
}
