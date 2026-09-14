import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Action descriptor for trailing buttons in [GlassToolbarTop]
class GlassToolbarAction {
  final IconData? icon;
  final String? label;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;
  final int? badgeCount;

  const GlassToolbarAction({
    this.icon,
    this.label,
    required this.tooltip,
    required this.onTap,
    this.color,
    this.badgeCount,
  });
}

/// Sliced 1:1 from pen.dev `Toobar - Top - Chats` (node `JZdLQ`)
///
/// Features:
/// - Leading Capsule (Pill `cornerRadius: 22`, frosted liquid glass, diffuse shadow):
///   Supports text button (Menu / Edit / Kembali) or icon
/// - Center Title:
///   Clean SF Pro / Inter typography with optional verified status badge
/// - Trailing Capsule (Pill `cornerRadius: 22`, frosted liquid glass, diffuse shadow):
///   Holds text label button (Cari) or tactile action icons
class GlassToolbarTop extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final String? leadingText;
  final IconData? leadingIcon;
  final String? leadingTooltip;
  final VoidCallback? onLeadingTap;

  final String title;
  final Widget? titleWidget;
  final bool showVerifiedBadge;
  final VoidCallback? onTitleTap;

  final String? trailingText;
  final String? trailingTooltip;
  final VoidCallback? onTrailingTap;

  final List<GlassToolbarAction>? trailingActions;
  final Widget? trailing;

  final Color backgroundColor;

  const GlassToolbarTop({
    super.key,
    this.leading,
    this.leadingText,
    this.leadingIcon,
    this.leadingTooltip,
    this.onLeadingTap,
    this.title = '',
    this.titleWidget,
    this.showVerifiedBadge = false,
    this.onTitleTap,
    this.trailingText,
    this.trailingTooltip,
    this.onTrailingTap,
    this.trailingActions,
    this.trailing,
    this.backgroundColor = Colors.transparent,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ===============================================================
              // 1. LEADING BUTTON (pen.dev meX9e: cornerRadius 296, height 44)
              // ===============================================================
              Positioned(
                left: 0,
                child: leading ?? _buildDefaultLeading(context),
              ),

              // ===============================================================
              // 2. CENTER TITLE (pen.dev uRDD1: Title + #008BFF Star)
              // ===============================================================
              Center(
                child: _buildCenterTitle(),
              ),

              // ===============================================================
              // 3. TRAILING BUTTON (pen.dev FuSew: double action capsule)
              // ===============================================================
              Positioned(
                right: 0,
                child: trailing ?? _buildDefaultTrailing(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultLeading(BuildContext context) {
    if (leadingText == null && leadingIcon == null && onLeadingTap == null) {
      return const SizedBox.shrink();
    }

    return _GlassCapsuleButton(
      tooltip: leadingTooltip ?? (leadingText ?? 'Aksi'),
      onTap: onLeadingTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: leadingText != null ? 14.0 : 10.0,
        ),
        child: leadingText != null
            ? Text(
                leadingText!,
                style: const TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 15.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A), // pen.dev #1A1A1A
                  letterSpacing: -0.2,
                ),
              )
            : Icon(
                leadingIcon ?? Icons.arrow_back_rounded,
                size: 21.0,
                color: const Color(0xFF1A1A1A),
              ),
      ),
    );
  }

  Widget _buildCenterTitle() {
    return GestureDetector(
      onTap: () {
        if (onTitleTap != null) {
          HapticFeedback.lightImpact();
          onTitleTap!();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: titleWidget ??
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 17.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A), // pen.dev #333333 / #1A1A1A
                    letterSpacing: -0.4,
                  ),
                ),
          ),
          if (showVerifiedBadge) ...[
            const SizedBox(width: 4.5),
            // Azure Blue Star / Status Badge (pen.dev #008BFF)
            Container(
              width: 16.0,
              height: 16.0,
              alignment: Alignment.center,
              child: const Icon(
                Icons.star_rounded,
                size: 17.0,
                color: Color(0xFF008BFF), // pen.dev Azure #008BFF
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultTrailing(BuildContext context) {
    if (trailingText != null) {
      return _GlassCapsuleButton(
        tooltip: trailingTooltip ?? trailingText!,
        onTap: onTrailingTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Text(
            trailingText!,
            style: const TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 15.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.2,
            ),
          ),
        ),
      );
    }

    if (trailingActions == null || trailingActions!.isEmpty) {
      return const SizedBox.shrink();
    }

    return _GlassActionsPill(actions: trailingActions!);
  }
}

/// Single action glass capsule button (pen.dev Leading Button meX9e)
class _GlassCapsuleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String tooltip;

  const _GlassCapsuleButton({
    required this.child,
    this.onTap,
    required this.tooltip,
  });

  @override
  State<_GlassCapsuleButton> createState() => _GlassCapsuleButtonState();
}

class _GlassCapsuleButtonState extends State<_GlassCapsuleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap?.call();
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.93 : 1.0,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOutCubic,
          child: Container(
            height: 42.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(21.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(21.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
                child: Container(
                  height: 42.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(21.0),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFF8FAFC),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.0,
                    ),
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Double/Multi action glass capsule pill (pen.dev Trailing Button FuSew)
class _GlassActionsPill extends StatelessWidget {
  final List<GlassToolbarAction> actions;

  const _GlassActionsPill({
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
          child: Container(
            height: 42.0,
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(21.0),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFF8FAFC),
                ],
              ),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: actions.map((action) {
                return _GlassActionButtonItem(action: action);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassActionButtonItem extends StatefulWidget {
  final GlassToolbarAction action;

  const _GlassActionButtonItem({
    required this.action,
  });

  @override
  State<_GlassActionButtonItem> createState() => _GlassActionButtonItemState();
}

class _GlassActionButtonItemState extends State<_GlassActionButtonItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.action.tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.action.onTap();
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.90 : 1.0,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOutCubic,
          child: Container(
            width: 36.0,
            height: 36.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isPressed
                  ? Colors.black.withValues(alpha: 0.05)
                  : Colors.transparent,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.action.label != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      widget.action.label!,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                        color: widget.action.color ?? const Color(0xFF1A1A1A),
                        letterSpacing: -0.2,
                      ),
                    ),
                  )
                else if (widget.action.icon != null)
                  Icon(
                    widget.action.icon,
                    size: 20.5,
                    color: widget.action.color ?? const Color(0xFF1A1A1A),
                  ),
                if (widget.action.badgeCount != null && widget.action.badgeCount! > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 8.0,
                      height: 8.0,
                      decoration: const BoxDecoration(
                        color: Color(0xFF008BFF),
                        shape: BoxShape.circle,
                      ),
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
