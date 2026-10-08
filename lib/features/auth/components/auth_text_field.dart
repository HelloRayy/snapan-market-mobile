import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Material 3 Floating Label Input Field with animated outline borders
class AuthInputField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextEditingController controller;
  final String? errorText;
  final bool isPassword;
  final bool showPassword;
  final VoidCallback? onTogglePassword;
  final Widget? customSuffixIcon;
  final bool isValid;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  const AuthInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.controller,
    this.errorText,
    this.isPassword = false,
    this.showPassword = false,
    this.onTogglePassword,
    this.customSuffixIcon,
    this.isValid = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.maxLength,
  });

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return TextField(
      focusNode: _focusNode,
      controller: widget.controller,
      obscureText: widget.isPassword && !widget.showPassword,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      inputFormatters: widget.inputFormatters,
      maxLength: widget.maxLength,
      buildCounter: widget.maxLength != null
          ? (context, {required currentLength, required isFocused, maxLength}) => null
          : null,
      cursorColor: AppColors.primary,
      style: const TextStyle(
        fontFamily: 'SFPro',
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
        color: Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: const TextStyle(
          fontFamily: 'SFPro',
          fontSize: 14.0,
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: TextStyle(
          fontFamily: 'SFPro',
          fontSize: 13.0,
          fontWeight: FontWeight.w600,
          color: hasError
              ? AppColors.error
              : widget.isValid
                  ? const Color(0xFF16A34A)
                  : _isFocused
                      ? AppColors.primary
                      : const Color(0xFF64748B),
        ),
        hintText: widget.hint,
        hintStyle: const TextStyle(
          fontFamily: 'SFPro',
          fontSize: 13.5,
          color: Color(0xFF94A3B8),
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(
          widget.prefixIcon,
          size: 19.5,
          color: hasError
              ? AppColors.error
              : widget.isValid
                  ? const Color(0xFF16A34A)
                  : _isFocused
                      ? AppColors.primary
                      : const Color(0xFF64748B),
        ),
        suffixIcon: widget.customSuffixIcon ??
            (widget.isPassword
                ? GestureDetector(
                    onTap: widget.onTogglePassword,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14.0),
                      child: Icon(
                        widget.showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                        size: 19.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  )
                : null),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 40.0,
          minHeight: 20.0,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(
            color: widget.isValid ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
            width: widget.isValid ? 1.5 : 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(
            color: hasError
                ? AppColors.error
                : widget.isValid
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFE2E8F0),
            width: hasError
                ? 1.4
                : widget.isValid
                    ? 1.5
                    : 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(
            color: widget.isValid ? const Color(0xFF16A34A) : AppColors.primary,
            width: 1.8,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: AppColors.error, width: 1.8),
        ),
        errorText: widget.errorText,
        errorStyle: const TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          color: AppColors.error,
        ),
      ),
    );
  }
}

/// Primary CTA Button with micro-tap physics & loading state
/// Primary CTA Button with Threads modern aesthetic (Ink Black / Brand Blue, pill shape, soft shadow)
/// Supports disabled grey state when form fields are incomplete.
class PrimaryAuthButton extends StatefulWidget {
  final String text;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onPressed;

  const PrimaryAuthButton({
    super.key,
    required this.text,
    required this.isLoading,
    this.isEnabled = true,
    required this.onPressed,
  });

  @override
  State<PrimaryAuthButton> createState() => _PrimaryAuthButtonState();
}

class _PrimaryAuthButtonState extends State<PrimaryAuthButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool canInteract = widget.isEnabled && !widget.isLoading;

    return GestureDetector(
      onTapDown: canInteract ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: canInteract ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: canInteract ? () => setState(() => _isPressed = false) : null,
      onTap: () {
        if (!canInteract) return;
        HapticFeedback.mediumImpact();
        widget.onPressed();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: (_isPressed && canInteract) ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          width: double.infinity,
          height: 50.0,
          decoration: BoxDecoration(
            color: !widget.isEnabled
                ? const Color(0xFFE2E8F0) // Disabled soft grey
                : widget.isLoading
                    ? AppColors.primary.withValues(alpha: 0.7)
                    : AppColors.primary,
            borderRadius: BorderRadius.circular(100.0), // Pill / Full Rounded
            boxShadow: [
              if (!_isPressed && widget.isEnabled)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 12.0,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.text,
                    style: TextStyle(
                      fontFamily: 'SFPro',
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                      color: !widget.isEnabled
                          ? const Color(0xFF94A3B8) // Slate 400 disabled text
                          : Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
