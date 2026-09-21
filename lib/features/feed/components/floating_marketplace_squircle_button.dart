import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Floating Marketplace Squircle Button
/// Positioned in vertical stack directly above the blue (+) action button:
/// - Squircle box shape matching blue FAB (48x40, borderRadius: 16.0)
/// - Clean white background (#FFFFFF) with subtle 1px border (#E2E8F0)
/// - Elevation shadow (#00000014, blur: 8, offset: (0, 4))
/// - Marketplace storefront icon in deep slate (#0F172A)
/// - Direct trigger for selling mode (PostMode.product)
/// - Tactile micro-press scale & medium impact haptic feedback
class FloatingMarketplaceSquircleButton extends StatefulWidget {
  final VoidCallback onTap;

  const FloatingMarketplaceSquircleButton({
    super.key,
    required this.onTap,
  });

  @override
  State<FloatingMarketplaceSquircleButton> createState() =>
      _FloatingMarketplaceSquircleButtonState();
}

class _FloatingMarketplaceSquircleButtonState
    extends State<FloatingMarketplaceSquircleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Pasang Produk COD / Mode Jualan',
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
            width: 38.0,
            height: 32.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 6.0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.storefront_rounded,
                color: Color(0xFF0F172A),
                size: 18.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
