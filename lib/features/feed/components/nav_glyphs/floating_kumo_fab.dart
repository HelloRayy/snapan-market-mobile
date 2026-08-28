import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Center Floating Action Button (+) with Signature Kumo Halo Ring & Glow
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
            width: 44.0,
            height: 38.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF3B82F6), // Blue 500
                  Color(0xFF1D64EC), // Kumo Primary Blue
                ],
              ),
              border: Border.all(
                color: const Color(0xFF154EC1),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1D64EC).withValues(alpha: 0.32),
                  blurRadius: 10.0,
                  offset: const Offset(0, 4),
                ),
                const BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 4.0,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inset top shine highlight
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.38),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16.0),
                      ),
                    ),
                  ),
                ),
                const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 24.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
