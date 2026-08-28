import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum KumoButtonVariant { primary, secondary, outline }

class KumoButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final KumoButtonVariant variant;
  final Widget? iconRight;
  final Widget? iconLeft;
  final double height;
  final double? width;
  final double borderRadius;

  const KumoButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = KumoButtonVariant.primary,
    this.iconRight,
    this.iconLeft,
    this.height = 52,
    this.width,
    this.borderRadius = 16,
  });

  const KumoButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.iconRight,
    this.iconLeft,
    this.height = 52,
    this.width,
    this.borderRadius = 16,
  }) : variant = KumoButtonVariant.primary;

  const KumoButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.iconRight,
    this.iconLeft,
    this.height = 52,
    this.width,
    this.borderRadius = 16,
  }) : variant = KumoButtonVariant.secondary;

  @override
  State<KumoButton> createState() => _KumoButtonState();
}

class _KumoButtonState extends State<KumoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.variant == KumoButtonVariant.primary;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: isPrimary
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF3B82F6), // Blue 500
                      Color(0xFF1D64EC), // Kumo Primary Blue
                    ],
                  )
                : null,
            color: isPrimary ? null : Colors.white,
            border: Border.all(
              color: isPrimary
                  ? const Color(0xFF154EC1)
                  : const Color(0xFFE5E7EB),
              width: 1,
            ),
            boxShadow: [
              if (isPrimary) ...[
                BoxShadow(
                  color: const Color(0xFF1D64EC).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ] else ...[
                const BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ],
          ),
          child: Stack(
            children: [
              // Inset Highlight Shadow for Primary Kumo
              if (isPrimary)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 1,
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.iconLeft != null) ...[
                        widget.iconLeft!,
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
                          color: isPrimary
                              ? Colors.white
                              : const Color(0xFF111827),
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (widget.iconRight != null) ...[
                        const SizedBox(width: 8),
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
