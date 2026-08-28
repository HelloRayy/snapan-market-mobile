import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Navigation Drawer for Snapan Market
///
/// 100% faithful Flutter translation of `src/ui/components/navigation/NavigationDrawer.tsx`:
/// - Slide-over panel (width: 82vw, max: 280px) with SafeArea awareness
/// - 1. Top Header (52px): Store logo box, brand logotype, and circular close button
/// - 2. Scrollable Middle Stream:
///   * Cluster 1: Feed Utama ("Untuk Anda" hero active pill, "Utas baru", "Cari")
///   * 16px Gap Divider
///   * Cluster 2: Personal & Arsip ("Pesan" with red badge "1", "Aktivitas" with dot, "Profil", "Insight", "Tersimpan")
/// - 3. Pinned Bottom Section (Top border 0xFFE2E8F0):
///   * "Denah 2D SMKN 8 🗺️" (Brand Indigo)
///   * "Brand Color Lab 🎨" (Indigo)
///   * "Unduh Aplikasi 📥"
///   * "Pengaturan Akun ⚙️"
///   * "Keluar Akun 🚪" (Rose Red)
///   * Version text footer: "Snapan Market PWA v0.1.0"
class HomeNavigationDrawer extends StatelessWidget {
  final VoidCallback? onNavigateHome;
  final VoidCallback? onNavigateSearch;
  final VoidCallback? onNavigateMessages;
  final VoidCallback? onNavigateProfile;
  final VoidCallback? onOpenCreateModal;
  final VoidCallback? onNavigateMap;
  final VoidCallback? onNavigateColors;
  final VoidCallback? onNavigateDownload;
  final VoidCallback? onLogout;

  const HomeNavigationDrawer({
    super.key,
    this.onNavigateHome,
    this.onNavigateSearch,
    this.onNavigateMessages,
    this.onNavigateProfile,
    this.onOpenCreateModal,
    this.onNavigateMap,
    this.onNavigateColors,
    this.onNavigateDownload,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final drawerWidth = (screenWidth * 0.82).clamp(240.0, 280.0);

    return Drawer(
      width: drawerWidth,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 16.0,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(0)),
      ),
      child: SafeArea(
        top: true,
        bottom: true,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Color(0xFFF1F5F9), // border-neutral-200/80
                width: 1.0,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Header (52px)
              _buildTopHeader(context),

              // 2. Middle Scrollable Stream (Cluster 1 & Cluster 2)
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Cluster 1: Feed Utama
                      _buildCluster1(context),

                      // 16px Distinct Spacing Gap
                      const SizedBox(height: 16.0),

                      // Cluster 2: Personal & Arsip
                      _buildCluster2(context),
                    ],
                  ),
                ),
              ),

              // 3. Pinned Bottom Section (Utility & Logout)
              _buildBottomSection(context),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Top Header Bar (52px)
  Widget _buildTopHeader(BuildContext context) {
    return Container(
      height: 52.0,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF8FAFC), // border-neutral-100
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Store Logo Box + "Snapan Market"
          Row(
            children: [
              Container(
                width: 30.0,
                height: 30.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 1.0,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.storefront_rounded,
                    size: 16.0,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              const Text(
                'Snapan Market',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),

          // Right: Circular Close Button
          _DrawerIconButton(
            icon: Icons.close_rounded,
            tooltip: 'Tutup Menu',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // Cluster 1: Feed Utama
  Widget _buildCluster1(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Untuk Anda (Active Hero Pill)
        _DrawerItemButton(
          label: 'Untuk Anda',
          iconWidget: const Icon(
            Icons.home_rounded,
            size: 18.0,
            color: AppColors.ink,
          ),
          isActiveHero: true,
          onTap: () {
            Navigator.of(context).pop();
            onNavigateHome?.call();
          },
        ),
        const SizedBox(height: 4.0),

        // 2. Utas baru
        _DrawerItemButton(
          label: 'Utas baru',
          iconWidget: const Icon(
            Icons.add_rounded,
            size: 19.0,
            color: AppColors.slateInk,
          ),
          onTap: () {
            Navigator.of(context).pop();
            onOpenCreateModal?.call();
          },
        ),
        const SizedBox(height: 4.0),

        // 3. Cari
        _DrawerItemButton(
          label: 'Cari',
          iconWidget: const Icon(
            Icons.search_rounded,
            size: 18.0,
            color: AppColors.slateInk,
          ),
          onTap: () {
            Navigator.of(context).pop();
            onNavigateSearch?.call();
          },
        ),
      ],
    );
  }

  // Cluster 2: Personal & Arsip
  Widget _buildCluster2(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 4. Pesan with Red Numeric Badge "1"
        _DrawerItemButton(
          label: 'Pesan',
          iconWidget: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                CupertinoIcons.paperplane,
                size: 17.0,
                color: AppColors.slateInk,
              ),
              Positioned(
                top: -3.0,
                right: -6.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3.5),
                  constraints: const BoxConstraints(
                    minWidth: 15.0,
                    minHeight: 15.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3040),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.of(context).pop();
            onNavigateMessages?.call();
          },
        ),
        const SizedBox(height: 4.0),

        // 5. Aktivitas with Red Dot
        _DrawerItemButton(
          label: 'Aktivitas',
          iconWidget: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                CupertinoIcons.heart,
                size: 18.0,
                color: AppColors.slateInk,
              ),
              Positioned(
                top: -1.0,
                right: -2.0,
                child: Container(
                  width: 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3040),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 4.0),

        // 6. Profil
        _DrawerItemButton(
          label: 'Profil',
          iconWidget: const Icon(
            CupertinoIcons.person,
            size: 18.0,
            color: AppColors.slateInk,
          ),
          onTap: () {
            Navigator.of(context).pop();
            onNavigateProfile?.call();
          },
        ),
        const SizedBox(height: 4.0),

        // 7. Insight
        _DrawerItemButton(
          label: 'Insight',
          iconWidget: const Icon(
            CupertinoIcons.chart_bar,
            size: 18.0,
            color: AppColors.slateInk,
          ),
          onTap: () {
            Navigator.of(context).pop();
            onNavigateProfile?.call();
          },
        ),
        const SizedBox(height: 4.0),

        // 8. Tersimpan
        _DrawerItemButton(
          label: 'Tersimpan',
          iconWidget: const Icon(
            CupertinoIcons.bookmark,
            size: 18.0,
            color: AppColors.slateInk,
          ),
          onTap: () {
            Navigator.of(context).pop();
            onNavigateProfile?.call();
          },
        ),
      ],
    );
  }

  // 3. Bottom Utility & System Section (Pinned to Bottom)
  Widget _buildBottomSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10.0, bottom: 12.0),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFF1F5F9), // border-neutral-200/90
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Denah 2D SMKN 8
          _DrawerItemButton(
            label: 'Denah 2D SMKN 8 🗺️',
            textColor: AppColors.primary,
            isBold: true,
            iconWidget: const Icon(
              CupertinoIcons.map,
              size: 18.0,
              color: AppColors.primary,
            ),
            onTap: () {
              Navigator.of(context).pop();
              onNavigateMap?.call();
            },
          ),
          const SizedBox(height: 3.0),

          // Brand Color Lab
          _DrawerItemButton(
            label: 'Brand Color Lab 🎨',
            textColor: const Color(0xFF4F46E5),
            isBold: true,
            iconWidget: const Icon(
              CupertinoIcons.paintbrush,
              size: 18.0,
              color: Color(0xFF4F46E5),
            ),
            onTap: () {
              Navigator.of(context).pop();
              onNavigateColors?.call();
            },
          ),
          const SizedBox(height: 3.0),

          // Unduh Aplikasi
          _DrawerItemButton(
            label: 'Unduh Aplikasi',
            textColor: AppColors.primary,
            isBold: true,
            iconWidget: const Icon(
              CupertinoIcons.arrow_down_to_line,
              size: 18.0,
              color: AppColors.primary,
            ),
            onTap: () {
              Navigator.of(context).pop();
              onNavigateDownload?.call();
            },
          ),
          const SizedBox(height: 3.0),

          // Pengaturan Akun
          _DrawerItemButton(
            label: 'Pengaturan Akun',
            iconWidget: const Icon(
              CupertinoIcons.settings,
              size: 18.0,
              color: AppColors.slateInk,
            ),
            onTap: () {
              Navigator.of(context).pop();
              onNavigateProfile?.call();
            },
          ),
          const SizedBox(height: 3.0),

          // Keluar Akun (Logout)
          _DrawerItemButton(
            label: 'Keluar Akun',
            textColor: const Color(0xFFE11D48), // Rose 600
            isBold: true,
            iconWidget: const Icon(
              Icons.logout_rounded,
              size: 17.0,
              color: Color(0xFFE11D48),
            ),
            onTap: () {
              Navigator.of(context).pop();
              onLogout?.call();
            },
          ),
          const SizedBox(height: 6.0),

          // Version Text Footer
          const Center(
            child: Text(
              'Snapan Market PWA v0.1.0',
              style: TextStyle(
                fontSize: 11.0,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular Action Icon Button (Close Button)
class _DrawerIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _DrawerIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_DrawerIconButton> createState() => _DrawerIconButtonState();
}

class _DrawerIconButtonState extends State<_DrawerIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150), // transition-all duration-150
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          width: 32.0,
          height: 32.0,
          decoration: BoxDecoration(
            color: _isPressed
                ? const Color(0x0D000000) // hover:bg-black/5
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: 18.0,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable Drawer Row Button with Micro-Tap Scale
class _DrawerItemButton extends StatefulWidget {
  final String label;
  final Widget iconWidget;
  final VoidCallback onTap;
  final bool isActiveHero;
  final Color? textColor;
  final bool isBold;

  const _DrawerItemButton({
    required this.label,
    required this.iconWidget,
    required this.onTap,
    this.isActiveHero = false,
    this.textColor,
    this.isBold = false,
  });

  @override
  State<_DrawerItemButton> createState() => _DrawerItemButtonState();
}

class _DrawerItemButtonState extends State<_DrawerItemButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0, // active:scale-[0.98]
        duration: const Duration(milliseconds: 150), // transition-all duration-150
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150), // transition-all duration-150
          curve: Curves.easeOutCubic,
          height: widget.isActiveHero ? 38.0 : 36.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: widget.isActiveHero
                ? const Color(0x0D000000) // 5% black matching hover:bg-black/5
                : _isPressed
                    ? const Color(0x0D000000) // hover:bg-black/5
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20.0,
                height: 20.0,
                child: Center(child: widget.iconWidget),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: widget.isActiveHero || widget.isBold
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: widget.textColor ??
                        (widget.isActiveHero
                            ? AppColors.ink
                            : AppColors.slateInk),
                    letterSpacing: -0.2,
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
