import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/components/glass_toolbar_top.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Top App Bar Header for Home Feed
/// Sliced from pen.dev `Toobar - Top - Chats` adapted for Home Screen
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
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return GlassToolbarTop(
      leadingIcon: onBackTap != null ? Icons.arrow_back_rounded : Icons.menu_rounded,
      leadingTooltip: onBackTap != null ? 'Kembali' : 'Menu Navigasi',
      onLeadingTap: onBackTap ?? onMenuTap,
      titleWidget: GestureDetector(
        onTap: onTitleTap,
        child: const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Snapan ',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 17.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.4,
                ),
              ),
              TextSpan(
                text: 'Market',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 17.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF008BFF),
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
      ),
      showVerifiedBadge: true,
      onTitleTap: onTitleTap,
      trailingActions: [
        GlassToolbarAction(
          icon: Icons.search_rounded,
          tooltip: 'Cari Produk & Diskusi',
          onTap: () => onSearchTap?.call(),
        ),
        GlassToolbarAction(
          icon: Icons.tune_rounded,
          tooltip: 'Filter & Kategori',
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Filter feed & kategori dibuka ✨'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }
}

