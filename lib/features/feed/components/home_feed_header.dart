import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Top App Bar Header for Home Feed
///
/// Implements 50px fixed height bar with 14px horizontal padding,
/// tactile circular action buttons (Menu & Search), and interactive brand logotype.
class HomeFeedHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onTitleTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onBackTap;

  const HomeFeedHeader({
    super.key,
    this.onMenuTap,
    this.onTitleTap,
    this.onSearchTap,
    this.onBackTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(50.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 50.0,
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Action: Back or Menu Button (36x36 circular button)
              _HeaderIconButton(
                icon: onBackTap != null ? Icons.arrow_back_rounded : Icons.menu_rounded,
                tooltip: onBackTap != null ? 'Kembali' : 'Menu Navigasi',
                onTap: onBackTap ?? onMenuTap,
              ),


              // Center: Brand Logotype ("Snapan Market")
              _HeaderLogotypeButton(
                onTap: onTitleTap,
              ),

              // Right Action: Search Button (36x36 circular button)
              _HeaderIconButton(
                icon: Icons.search_rounded,
                tooltip: 'Cari Produk & Diskusi',
                onTap: onSearchTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular 36x36 Action Icon Button with Tactile Feedback
class _HeaderIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  @override
  State<_HeaderIconButton> createState() => _HeaderIconButtonState();
}

class _HeaderIconButtonState extends State<_HeaderIconButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap?.call();
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: Container(
            width: 36.0,
            height: 36.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isPressed
                  ? Colors.black.withValues(alpha: 0.05)
                  : Colors.transparent,
            ),
            child: Icon(
              widget.icon,
              size: 22.0,
              color: AppColors.slateInk,
            ),
          ),
        ),
      ),
    );
  }
}

/// Interactive Centered Logotype ("Snapan " + "Market")
class _HeaderLogotypeButton extends StatefulWidget {
  final VoidCallback? onTap;

  const _HeaderLogotypeButton({
    this.onTap,
  });

  @override
  State<_HeaderLogotypeButton> createState() => _HeaderLogotypeButtonState();
}

class _HeaderLogotypeButtonState extends State<_HeaderLogotypeButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text.rich(
            TextSpan(
              children: const [
                TextSpan(
                  text: 'Snapan ',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'Market',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
