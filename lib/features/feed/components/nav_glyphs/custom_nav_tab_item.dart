import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Touch-friendly interactive nav tab container with micro-tap scale physics
class CustomNavTabItem extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final VoidCallback onTap;
  final String tooltip;

  const CustomNavTabItem({
    super.key,
    required this.child,
    required this.isActive,
    required this.onTap,
    required this.tooltip,
  });

  @override
  State<CustomNavTabItem> createState() => _CustomNavTabItemState();
}

class _CustomNavTabItemState extends State<CustomNavTabItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.tooltip,
      button: true,
      selected: widget.isActive,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          HapticFeedback.selectionClick();
        },
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isPressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 75),
          curve: Curves.easeOutCubic,
          child: Container(
            height: 50.0,
            alignment: Alignment.center,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
