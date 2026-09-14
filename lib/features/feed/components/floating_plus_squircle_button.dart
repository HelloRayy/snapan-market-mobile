import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Floating Plus Squircle Button
/// Sliced from the user's layout sketch:
/// - Squircle / rounded box shape (`borderRadius: BorderRadius.circular(18.0)`)
/// - Positioned floating at the bottom right above the Center Bot Bar
/// - Azure blue gradient (`#269DFF` to `#008BFF`) from pen.dev spec
/// - Specular top shine highlight + diffuse glow shadow
/// - Tactile micro-press feedback
class FloatingPlusSquircleButton extends StatefulWidget {
  final VoidCallback onTap;

  const FloatingPlusSquircleButton({super.key, required this.onTap});

  @override
  State<FloatingPlusSquircleButton> createState() => _FloatingPlusSquircleButtonState();
}

class _FloatingPlusSquircleButtonState extends State<FloatingPlusSquircleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const primaryTop = Color(0xFF269DFF); // Light Azure
    const primaryBase = Color(0xFF008BFF); // pen.dev Primary Accent

    return Semantics(
      label: 'Buat Postingan Baru',
      button: true,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          HapticFeedback.mediumImpact();
        },
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isPressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOutCubic,
          child: Container(
            width: 52.0,
            height: 52.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.0),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primaryTop,
                  primaryBase,
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                // Diffuse Outer Shadow matching pen.dev (#0000001f, y: 8, blur: 30)
                const BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 30.0,
                  offset: Offset(0, 8),
                ),
                // Vivid Azure Glow
                BoxShadow(
                  color: primaryBase.withValues(alpha: 0.40),
                  blurRadius: 14.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inset Top Shine Highlight
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 1.5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.45),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18.0),
                      ),
                    ),
                  ),
                ),

                // Plus Icon
                const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 28.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
