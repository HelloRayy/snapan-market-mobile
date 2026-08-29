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
            width: 48.0,
            height: 48.0,
            padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.95),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1D64EC).withValues(alpha: 0.35),
                  blurRadius: 10.0,
                  offset: const Offset(0, 4),
                ),
                const BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 4.0,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
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
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Inset top shine highlight
                  Positioned(
                    top: 0,
                    left: 4.0,
                    right: 4.0,
                    height: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.40),
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 26.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
