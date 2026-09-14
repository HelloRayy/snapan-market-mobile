import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/components/glass_toolbar_top.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Top App Bar Header for Home Feed
/// Sliced from pen.dev `Toobar - Top - Chats` adapted for Home Screen
class HomeFeedHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuTap;
  final VoidCallback? onTitleTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onBackTap;

  const HomeFeedHeader({
    super.key,
    this.title = 'Snaps.',
    this.onMenuTap,
    this.onTitleTap,
    this.onSearchTap,
    this.onBackTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return GlassToolbarTop(
      leadingText: onBackTap != null ? 'Kembali' : 'Menu',
      leadingTooltip: onBackTap != null ? 'Kembali' : 'Menu Navigasi',
      onLeadingTap: onBackTap ?? onMenuTap,
      titleWidget: GestureDetector(
        onTap: onTitleTap,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            title,
            key: ValueKey(title),
            style: const TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 17.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.4,
            ),
          ),
        ),
      ),
      showVerifiedBadge: false,
      onTitleTap: onTitleTap,
      trailingText: 'Cari',
      trailingTooltip: 'Cari Produk & Diskusi',
      onTrailingTap: onSearchTap,
    );
  }
}

