import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Floating Plus Rectangle Button
/// Sliced from the user's layout sketch:
/// - Ergonomic wide rectangle shape (`width: 60.0`, `height: 44.0`, `borderRadius: 16.0`)
/// - Positioned floating at the bottom right above the Center Bot Bar
/// - Azure blue gradient (`#269DFF` to `#008BFF`) from pen.dev spec
/// - Native CupertinoIcons.plus (size 26) with tactile micro-press feedback
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
          HapticFeedback.lightImpact();
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
            width: 60.0,
            height: 44.0,
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
                // Diffuse Outer Shadow matching user spec (#0000001f, y: 4, blur: 8)
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 8.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                CupertinoIcons.plus,
                color: Colors.white,
                size: 26.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
