import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum KumoButtonVariant { primary, secondary, outline }

class KumoButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final KumoButtonVariant variant;
  final Widget? iconRight;
  final Widget? iconLeft;
  final double height;
  final double? width;
  final double borderRadius;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;

  const KumoButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = KumoButtonVariant.primary,
    this.iconRight,
    this.iconLeft,
    this.height = 52,
    this.width,
    this.borderRadius = 16,
    this.isLoading = false,
    this.padding,
  });

  const KumoButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.iconRight,
    this.iconLeft,
    this.height = 52,
    this.width,
    this.borderRadius = 16,
    this.isLoading = false,
    this.padding,
  }) : variant = KumoButtonVariant.primary;

  const KumoButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.iconRight,
    this.iconLeft,
    this.height = 52,
    this.width,
    this.borderRadius = 16,
    this.isLoading = false,
    this.padding,
  }) : variant = KumoButtonVariant.secondary;

  @override
  State<KumoButton> createState() => _KumoButtonState();
}

class _KumoButtonState extends State<KumoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final isPrimary = widget.variant == KumoButtonVariant.primary;

    return GestureDetector(
      onTapDown: isEnabled
          ? (_) {
              setState(() => _isPressed = true);
              HapticFeedback.selectionClick();
            }
          : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: isEnabled ? widget.onPressed : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: isEnabled && isPrimary
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF3B82F6), // Blue 500
                      Color(0xFF1D64EC), // Kumo Primary Blue
                    ],
                  )
                : null,
            color: !isEnabled
                ? const Color(0xFFF1F5F9)
                : isPrimary
                    ? null
                    : Colors.white,
            border: Border.all(
              color: !isEnabled
                  ? const Color(0xFFE2E8F0)
                  : isPrimary
                      ? const Color(0xFF154EC1)
                      : const Color(0xFFE5E7EB),
              width: 1.0,
            ),
            boxShadow: [
              if (isEnabled && isPrimary)
                BoxShadow(
                  color: const Color(0xFF1D64EC).withValues(alpha: 0.28),
                  blurRadius: 10.0,
                  offset: const Offset(0, 3),
                )
              else if (isEnabled && !isPrimary)
                const BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 3.0,
                  offset: Offset(0, 1),
                ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Inset Top Shine Highlight for Primary Kumo
              if (isEnabled && isPrimary)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(widget.borderRadius),
                      ),
                    ),
                  ),
                ),

              Center(
                child: Padding(
                  padding: widget.padding ??
                      const EdgeInsets.symmetric(horizontal: 18.0),
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 16.0,
                          height: 16.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.iconLeft != null) ...[
                              widget.iconLeft!,
                              const SizedBox(width: 6.0),
                            ],
                            Text(
                              widget.text,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: isPrimary
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: !isEnabled
                                    ? const Color(0xFF94A3B8)
                                    : isPrimary
                                        ? Colors.white
                                        : const Color(0xFF111827),
                                letterSpacing: -0.2,
                              ),
                            ),
                            if (widget.iconRight != null) ...[
                              const SizedBox(width: 6.0),
                              widget.iconRight!,
                            ],
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
