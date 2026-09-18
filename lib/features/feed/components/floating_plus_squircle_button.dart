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
          scale: _isPressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOutCubic,
          child: Container(
            width: 82.0,
            height: 68.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primaryTop,
                  primaryBase,
                ],
              ),
              boxShadow: const [
                // Diffuse Outer Shadow matching user spec (#00000014, y: 6, blur: 8)
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 8.0,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 32.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
