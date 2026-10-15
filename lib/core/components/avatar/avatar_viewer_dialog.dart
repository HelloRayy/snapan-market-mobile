import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/components/avatar/default_profile_avatar.dart';

/// Fullscreen Circle Avatar Viewer Dialog
///
/// Implements Jakob's Law (industry standard avatar inspection matching WhatsApp/Telegram)
/// with theme awareness (white background on Light Theme, dark cinema on Dark Theme):
/// - Theme-responsive backdrop and barrier (Light -> White, Dark -> Dark Cinema #0B0F17)
/// - Centered perfect-circle frame (p1: full circle) with adaptive outline and shadow
/// - Pinch-to-zoom support with gesture disambiguation
/// - Fluid swipe-down-to-dismiss and tap-outside-to-dismiss
/// - Contextual header showing user title and username in theme-contrasted typography
/// - Smooth Hero transition support
class AvatarViewerDialog extends StatefulWidget {
  final String imageUrl;
  final String? title;
  final String? subtitle;
  final String? heroTag;

  const AvatarViewerDialog({
    super.key,
    required this.imageUrl,
    this.title,
    this.subtitle,
    this.heroTag,
  });

  static Future<void> show({
    required BuildContext context,
    required String imageUrl,
    String? title,
    String? subtitle,
    String? heroTag,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Avatar Viewer',
      barrierColor: isDark
          ? Colors.black.withValues(alpha: 0.94)
          : Colors.white.withValues(alpha: 0.96),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, anim1, anim2) {
        return AvatarViewerDialog(
          imageUrl: imageUrl,
          title: title,
          subtitle: subtitle,
          heroTag: heroTag,
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<AvatarViewerDialog> createState() => _AvatarViewerDialogState();
}

class _AvatarViewerDialogState extends State<AvatarViewerDialog>
    with SingleTickerProviderStateMixin {
  late final TransformationController _transformController;
  late final AnimationController _springBackAnimController;
  Animation<double>? _springBackAnim;

  double _dragOffsetY = 0.0;
  bool _isCurrentZoomed = false;

  @override
  void initState() {
    super.initState();
    _transformController = TransformationController();
    _transformController.addListener(_handleTransform);

    _springBackAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
  }

  @override
  void dispose() {
    _transformController.removeListener(_handleTransform);
    _transformController.dispose();
    _springBackAnimController.dispose();
    super.dispose();
  }

  void _handleTransform() {
    final scale = _transformController.value.getMaxScaleOnAxis();
    final zoomed = scale > 1.05;
    if (zoomed != _isCurrentZoomed) {
      setState(() => _isCurrentZoomed = zoomed);
    }
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    if (_isCurrentZoomed) return;
    setState(() {
      _dragOffsetY += details.delta.dy;
      if (_dragOffsetY < 0) {
        _dragOffsetY = _dragOffsetY.clamp(-25.0, 0.0);
      }
    });
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (_isCurrentZoomed) return;
    final velocity = details.primaryVelocity ?? 0.0;
    if (_dragOffsetY > 110.0 || velocity > 650.0) {
      HapticFeedback.lightImpact();
      Navigator.of(context).pop();
    } else if (_dragOffsetY != 0.0) {
      _springBackAnim = Tween<double>(begin: _dragOffsetY, end: 0.0).animate(
        CurvedAnimation(
          parent: _springBackAnimController,
          curve: Curves.easeOutCubic,
        ),
      )..addListener(() {
          setState(() {
            _dragOffsetY = _springBackAnim!.value;
          });
        });
      _springBackAnimController.forward(from: 0.0);
    }
  }

  Widget _buildAvatarImage(double size, bool isDark) {
    final cleanUrl = widget.imageUrl.trim();
    Widget imageWidget;

    final fallbackBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final fallbackIcon = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    if (cleanUrl.isEmpty) {
      imageWidget = DefaultProfileAvatar(
        size: size,
        backgroundColor: fallbackBg,
        iconColor: fallbackIcon,
      );
    } else if (cleanUrl.startsWith('assets/')) {
      imageWidget = Image.asset(
        cleanUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => DefaultProfileAvatar(
          size: size,
          backgroundColor: fallbackBg,
          iconColor: fallbackIcon,
        ),
      );
    } else {
      imageWidget = Image.network(
        cleanUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: size,
            height: size,
            color: fallbackBg,
            child: Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                    : null,
                strokeWidth: 2.5,
                color: const Color(0xFF008BFF),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => DefaultProfileAvatar(
          size: size,
          backgroundColor: fallbackBg,
          iconColor: fallbackIcon,
        ),
      );
    }

    if (widget.heroTag != null && widget.heroTag!.isNotEmpty) {
      imageWidget = Hero(
        tag: widget.heroTag!,
        child: imageWidget,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.18)
              : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.55)
                : const Color(0x18000000),
            blurRadius: isDark ? 28.0 : 20.0,
            spreadRadius: isDark ? 4.0 : 2.0,
          ),
        ],
      ),
      child: ClipOval(
        child: imageWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final screenWidth = mediaQuery.size.width;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Avatar diameter: proportional full circle (~290dp)
    final double avatarSize = (screenWidth * 0.76).clamp(240.0, 320.0);

    final double pullProgress = (_dragOffsetY.clamp(0.0, 300.0) / 300.0);
    final double bgOpacity = (1.0 - pullProgress * 0.7).clamp(0.0, 1.0);
    final double scale = (1.0 - pullProgress * 0.15).clamp(0.7, 1.0);
    final double controlsAlpha = (1.0 - pullProgress * 2.5).clamp(0.0, 1.0);

    final Color bgColor = isDark ? const Color(0xFF0B0F17) : Colors.white;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Material(
        color: bgColor.withValues(alpha: bgOpacity),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // Tap outside avatar image dismisses dialog
            Navigator.of(context).pop();
          },
          onVerticalDragUpdate: _handleVerticalDragUpdate,
          onVerticalDragEnd: _handleVerticalDragEnd,
          child: Stack(
            children: [
              // 1. Centered Full-Circle Avatar with Zoom and Drag
              Center(
                child: Transform.translate(
                  offset: Offset(0.0, _dragOffsetY),
                  child: Transform.scale(
                    scale: scale,
                    child: GestureDetector(
                      // Prevent tap on avatar from closing modal
                      onTap: () {},
                      child: InteractiveViewer(
                        transformationController: _transformController,
                        minScale: 1.0,
                        maxScale: 3.5,
                        panEnabled: _isCurrentZoomed,
                        clipBehavior: Clip.none,
                        child: _buildAvatarImage(avatarSize, isDark),
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Contextual Top Header (User info + Close button)
              Positioned(
                top: topPadding + 14.0,
                left: 16.0,
                right: 16.0,
                child: IgnorePointer(
                  ignoring: controlsAlpha < 0.05,
                  child: Opacity(
                    opacity: controlsAlpha,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Circular close button (theme adaptive)
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => Navigator.of(context).pop(),
                            child: isDark
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                      child: Container(
                                        width: 40.0,
                                        height: 40.0,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.16),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          size: 20.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 40.0,
                                    height: 40.0,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                        width: 1.0,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x10000000),
                                          blurRadius: 6.0,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 20.0,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(width: 14.0),

                        // User displayName & @username
                        if (widget.title != null || widget.subtitle != null)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.title != null && widget.title!.isNotEmpty)
                                  Text(
                                    widget.title!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                if (widget.subtitle != null && widget.subtitle!.isNotEmpty)
                                  Text(
                                    widget.subtitle!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w400,
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.68)
                                          : const Color(0xFF64748B),
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
