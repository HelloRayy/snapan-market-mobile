import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 1:1 Threads-style Header Navigation Menu Popover Overlay
///
/// Anchored floating popup overlay matching the user's reference image:
/// - Pure white squircle container (224px width, 16px radius)
/// - Positioned directly below top-left hamburger menu icon
/// - Clean grouped items without divider clutter:
///   1. Tampilan (with subtle grey chevron >)
///   2. Pengaturan
///   3. Disukai
///   4. Arsip
///   5. Laporkan masalah
///   6. Logout (Red text #EF4444)
/// - Non-blocking overlay architecture: allows the feed behind it to scroll freely!
class HomeMenuPopover extends StatelessWidget {
  final VoidCallback? onAppearanceTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onLikedTap;
  final VoidCallback? onArchiveTap;
  final VoidCallback? onReportTap;
  final VoidCallback? onLogout;

  const HomeMenuPopover({
    super.key,
    this.onAppearanceTap,
    this.onSettingsTap,
    this.onLikedTap,
    this.onArchiveTap,
    this.onReportTap,
    this.onLogout,
  });

  static OverlayEntry? _currentOverlay;
  static final GlobalKey _menuKey = GlobalKey();

  static bool get isShowing => _currentOverlay != null;

  static void dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  static void toggle({
    required BuildContext context,
    VoidCallback? onAppearanceTap,
    VoidCallback? onSettingsTap,
    VoidCallback? onLikedTap,
    VoidCallback? onArchiveTap,
    VoidCallback? onReportTap,
    VoidCallback? onLogout,
    Offset? anchorPosition,
  }) {
    if (isShowing) {
      dismiss();
    } else {
      show(
        context: context,
        onAppearanceTap: onAppearanceTap,
        onSettingsTap: onSettingsTap,
        onLikedTap: onLikedTap,
        onArchiveTap: onArchiveTap,
        onReportTap: onReportTap,
        onLogout: onLogout,
        anchorPosition: anchorPosition,
      );
    }
  }

  static void show({
    required BuildContext context,
    VoidCallback? onAppearanceTap,
    VoidCallback? onSettingsTap,
    VoidCallback? onLikedTap,
    VoidCallback? onArchiveTap,
    VoidCallback? onReportTap,
    VoidCallback? onLogout,
    Offset? anchorPosition,
  }) {
    dismiss();
    HapticFeedback.lightImpact();

    final overlayState = Overlay.of(context, rootOverlay: true);
    final mediaQuery = MediaQuery.of(context);
    final topOffset = anchorPosition?.dy ?? (mediaQuery.padding.top + 46.0);
    final leftOffset = anchorPosition?.dx ?? 12.0;

    _currentOverlay = OverlayEntry(
      builder: (ctx) {
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            final renderBox = _menuKey.currentContext?.findRenderObject() as RenderBox?;
            if (renderBox != null) {
              final local = renderBox.globalToLocal(event.position);
              if (!renderBox.paintBounds.contains(local)) {
                dismiss();
              }
            }
          },
          child: Stack(
            children: [
              Positioned(
                top: topOffset,
                left: leftOffset,
                child: KeyedSubtree(
                  key: _menuKey,
                  child: Material(
                    color: Colors.transparent,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.scale(
                            scale: 0.94 + (0.06 * value),
                            alignment: Alignment.topLeft,
                            child: child,
                          ),
                        );
                      },
                      child: HomeMenuPopover(
                        onAppearanceTap: () {
                          dismiss();
                          onAppearanceTap?.call();
                        },
                        onSettingsTap: () {
                          dismiss();
                          onSettingsTap?.call();
                        },
                        onLikedTap: () {
                          dismiss();
                          onLikedTap?.call();
                        },
                        onArchiveTap: () {
                          dismiss();
                          onArchiveTap?.call();
                        },
                        onReportTap: () {
                          dismiss();
                          onReportTap?.call();
                        },
                        onLogout: () {
                          dismiss();
                          _confirmLogout(context, onLogout);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    overlayState.insert(_currentOverlay!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 224.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 24.0,
            spreadRadius: 0,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Tampilan (with chevron >)
          _buildMenuItem(
            context: context,
            label: 'Tampilan',
            hasChevron: true,
            onTap: onAppearanceTap,
          ),

          // 2. Pengaturan
          _buildMenuItem(
            context: context,
            label: 'Pengaturan',
            onTap: onSettingsTap,
          ),

          // 3. Disukai
          _buildMenuItem(
            context: context,
            label: 'Disukai',
            onTap: onLikedTap,
          ),

          // 4. Arsip
          _buildMenuItem(
            context: context,
            label: 'Arsip',
            onTap: onArchiveTap,
          ),

          // 5. Laporkan masalah
          _buildMenuItem(
            context: context,
            label: 'Laporkan masalah',
            onTap: onReportTap,
          ),

          // 6. Logout (Red font #EF4444)
          _buildMenuItem(
            context: context,
            label: 'Logout',
            textColor: const Color(0xFFEF4444),
            isDestructive: true,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String label,
    VoidCallback? onTap,
    Color textColor = const Color(0xFF0F172A),
    bool hasChevron = false,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      borderRadius: BorderRadius.circular(10.0),
      hoverColor: const Color(0xFFF8FAFC),
      splashColor: const Color(0xFFF1F5F9),
      highlightColor: Colors.transparent,
      child: Container(
        height: 39.0,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: isDestructive ? FontWeight.w600 : FontWeight.w500,
                color: textColor,
                letterSpacing: -0.2,
              ),
            ),
            if (hasChevron)
              const Icon(
                Icons.chevron_right_rounded,
                size: 17.5,
                color: Color(0xFF94A3B8),
              ),
          ],
        ),
      ),
    );
  }

  static void _confirmLogout(BuildContext context, VoidCallback? onLogout) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: const Text(
          'Keluar dari Snaps?',
          style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        content: const Text(
          'Anda harus masuk kembali untuk membuat postingan, pesan, dan berbelanja.',
          style: TextStyle(
            fontSize: 14.0,
            color: Color(0xFF64748B),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onLogout?.call();
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
