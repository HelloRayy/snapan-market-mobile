import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 1:1 Threads-style Header Navigation Menu Popover Overlay
///
/// Anchored floating popup overlay matching the user's reference image:
/// - Dark squircle container (`#1A1A1E`)
/// - Positioned directly below top-left hamburger menu icon
/// - Clean grouped items:
///   1. Tampilan (with chevron >)
///   2. Pengaturan
///   [Divider]
///   3. Disukai
///   4. Arsip
///   [Divider]
///   5. Laporkan masalah
///   [Divider]
///   6. Logout (Red text)
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

  static Future<void> show({
    required BuildContext context,
    VoidCallback? onAppearanceTap,
    VoidCallback? onSettingsTap,
    VoidCallback? onLikedTap,
    VoidCallback? onArchiveTap,
    VoidCallback? onReportTap,
    VoidCallback? onLogout,
    Offset? anchorPosition,
  }) {
    HapticFeedback.lightImpact();

    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'HomeMenuPopover',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (ctx, anim1, anim2) {
        final topOffset = anchorPosition?.dy ??
            (MediaQuery.of(ctx).padding.top + 50.0);
        final leftOffset = anchorPosition?.dx ?? 12.0;

        return Stack(
          children: [
            Positioned(
              top: topOffset,
              left: leftOffset,
              child: Material(
                color: Colors.transparent,
                child: HomeMenuPopover(
                  onAppearanceTap: onAppearanceTap,
                  onSettingsTap: onSettingsTap,
                  onLikedTap: onLikedTap,
                  onArchiveTap: onArchiveTap,
                  onReportTap: onReportTap,
                  onLogout: onLogout,
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.90, end: 1.0).animate(curved),
            alignment: Alignment.topLeft,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000), // Clean light elevation shadow
            blurRadius: 24.0,
            spreadRadius: 0,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Group 1: Tampilan & Pengaturan
          _buildMenuItem(
            context: context,
            label: 'Tampilan',
            hasChevron: true,
            onTap: () {
              Navigator.of(context).pop();
              if (onAppearanceTap != null) {
                onAppearanceTap!();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tampilan: Mode Terang (Default)'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          _buildMenuItem(
            context: context,
            label: 'Pengaturan',
            onTap: () {
              Navigator.of(context).pop();
              if (onSettingsTap != null) {
                onSettingsTap!();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pengaturan akun dibuka'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),

          _buildDivider(),

          // Group 2: Disukai & Arsip
          _buildMenuItem(
            context: context,
            label: 'Disukai',
            onTap: () {
              Navigator.of(context).pop();
              if (onLikedTap != null) {
                onLikedTap!();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Menampilkan postingan yang Anda sukai'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          _buildMenuItem(
            context: context,
            label: 'Arsip',
            onTap: () {
              Navigator.of(context).pop();
              if (onArchiveTap != null) {
                onArchiveTap!();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Arsip postingan & aktivitas dibuka'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),

          _buildDivider(),

          // Group 3: Laporkan masalah
          _buildMenuItem(
            context: context,
            label: 'Laporkan masalah',
            onTap: () {
              Navigator.of(context).pop();
              if (onReportTap != null) {
                onReportTap!();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Laporan masalah terkirim. Terima kasih atas masukan Anda!'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),

          _buildDivider(),

          // Group 4: Logout (Red font)
          _buildMenuItem(
            context: context,
            label: 'Logout',
            textColor: const Color(0xFFEF4444),
            isDestructive: true,
            onTap: () {
              Navigator.of(context).pop();
              _confirmLogout(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
    Color textColor = const Color(0xFF0F172A),
    bool hasChevron = false,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(10.0),
      hoverColor: const Color(0xFFF8FAFC),
      splashColor: const Color(0xFFF1F5F9),
      highlightColor: Colors.transparent,
      child: Container(
        height: 44.0,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                size: 18.0,
                color: Color(0xFF94A3B8),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 3.0),
      child: Divider(
        height: 1.0,
        thickness: 0.8,
        color: Color(0xFFF1F5F9), // Light slate divider
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: const Text(
          'Keluar dari Snapan Market?',
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
