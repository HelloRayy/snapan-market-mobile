import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Floating Action Button (FAB) with Electric Cyan Style & PLUS Icon
/// Sliced & inspired by reference image FAB style positioned at bottom right
class FloatingKumoFabButton extends StatefulWidget {
  final VoidCallback onTap;

  const FloatingKumoFabButton({super.key, required this.onTap});

  @override
  State<FloatingKumoFabButton> createState() => _FloatingKumoFabButtonState();
}

class _FloatingKumoFabButtonState extends State<FloatingKumoFabButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
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
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isPressed ? 0.90 : 1.0,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOutCubic,
          child: Container(
            width: 54.0,
            height: 54.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00A3FF), // Electric Vivid Cyan
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF38BDF8), // Light Sky Blue
                  Color(0xFF00A3FF), // Electric Cyan
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00A3FF).withValues(alpha: 0.45),
                  blurRadius: 14.0,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 6.0,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Top Shine Highlight
                Positioned(
                  top: 2.0,
                  left: 10.0,
                  right: 10.0,
                  height: 1.5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                // Plus Icon
                const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 32.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
