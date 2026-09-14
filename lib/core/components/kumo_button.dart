import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum KumoButtonVariant { primary, secondary, outline, black }

/// "Bot Start Button" component sliced 1:1 from pen.dev (`snaps-design.pen`)
///
/// Design Specifications:
/// - Full Pill Capsule geometry (`cornerRadius: 1000`)
/// - Height: 52.0px default (matching 346x52 pen.dev button)
/// - Primary: Vivid iOS Azure `#008BFF` with specular glass gradient `#269DFF -> #008BFF`
/// - Diffuse Elevation: 35px blur shadow (`#0000001f`, offset y=8) + soft azure glow
/// - Inset Top Shine Highlight: 1.5px white specular sheen
/// - Secondary: Soft Gray Capsule `#EDEDED` with `#1A1A1A` ink typography
/// - Black: Deep Obsidian Pill `#1A1A1A` with diffuse shadow
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
    this.borderRadius = 100, // Full Pill Capsule (cornerRadius 1000 in pen.dev)
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
    this.borderRadius = 100,
    this.isLoading = false,
    this.padding,
  }) : variant = KumoButtonVariant.primary;

  const KumoButton.black({
    super.key,
    required this.text,
    this.onPressed,
    this.iconRight,
    this.iconLeft,
    this.height = 52,
    this.width,
    this.borderRadius = 100,
    this.isLoading = false,
    this.padding,
  }) : variant = KumoButtonVariant.black;

  const KumoButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.iconRight,
    this.iconLeft,
    this.height = 52,
    this.width,
    this.borderRadius = 100,
    this.isLoading = false,
    this.padding,
  }) : variant = KumoButtonVariant.secondary;

  const KumoButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.iconRight,
    this.iconLeft,
    this.height = 52,
    this.width,
    this.borderRadius = 100,
    this.isLoading = false,
    this.padding,
  }) : variant = KumoButtonVariant.outline;

  @override
  State<KumoButton> createState() => _KumoButtonState();
}

class _KumoButtonState extends State<KumoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final isPrimary = widget.variant == KumoButtonVariant.primary;
    final isSecondary = widget.variant == KumoButtonVariant.secondary;
    final isOutline = widget.variant == KumoButtonVariant.outline;
    final isBlack = widget.variant == KumoButtonVariant.black;

    // Colors from pen.dev (snaps-design.pen)
    const primaryTop = Color(0xFF269DFF); // Specular top azure
    const primaryBase = Color(0xFF008BFF); // pen.dev accent fill
    const secondaryFill = Color(0xFFEDEDED); // pen.dev selection fill
    const inkDark = Color(0xFF1A1A1A); // pen.dev ink text

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
        duration: const Duration(milliseconds: 90),
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
                      primaryTop,
                      primaryBase,
                    ],
                  )
                : null,
            color: !isEnabled
                ? const Color(0xFFF1F5F9)
                : isPrimary
                    ? null
                    : isSecondary
                        ? secondaryFill
                        : isBlack
                            ? inkDark
                            : isOutline
                                ? Colors.transparent
                                : Colors.white,
            border: Border.all(
              color: !isEnabled
                  ? const Color(0xFFE2E8F0)
                  : isPrimary
                      ? const Color(0xFF0077DB)
                      : isOutline
                          ? primaryBase
                          : isBlack
                              ? inkDark
                              : const Color(0xFFE2E8F0),
              width: isOutline ? 1.5 : 1.0,
            ),
            boxShadow: [
              if (isEnabled && isPrimary) ...[
                // Diffuse outer shadow from pen.dev (#0000001f, y: 8, blur: 35)
                const BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 35.0,
                  offset: Offset(0, 8),
                ),
              ] else if (isEnabled && isBlack) ...[
                const BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 35.0,
                  offset: Offset(0, 8),
                ),
              ] else if (isEnabled && isSecondary) ...[
                const BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 10.0,
                  offset: Offset(0, 3),
                ),
              ] else if (isEnabled && !isOutline) ...[
                const BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 4.0,
                  offset: Offset(0, 2),
                ),
              ],
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Inset Top Shine Highlight (Specularity from pen.dev Bot Start Button)
              if (isEnabled && isPrimary)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 1.5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.40),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(widget.borderRadius),
                      ),
                    ),
                  ),
                ),

              Center(
                child: Padding(
                  padding: widget.padding ??
                      const EdgeInsets.symmetric(horizontal: 20.0),
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 18.0,
                          height: 18.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.iconLeft != null) ...[
                              widget.iconLeft!,
                              const SizedBox(width: 8.0),
                            ],
                            Text(
                              widget.text,
                              style: TextStyle(
                                fontSize: widget.height < 40 ? 13.0 : 16.5,
                                fontWeight: (isPrimary || isBlack)
                                    ? FontWeight.w600
                                    : FontWeight.w600,
                                color: !isEnabled
                                    ? const Color(0xFF94A3B8)
                                    : (isPrimary || isBlack)
                                        ? Colors.white
                                        : isOutline
                                            ? primaryBase
                                            : inkDark,
                                letterSpacing: -0.2,
                              ),
                            ),
                            if (widget.iconRight != null) ...[
                              const SizedBox(width: 8.0),
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
