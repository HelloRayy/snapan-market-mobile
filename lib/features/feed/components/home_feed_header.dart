import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:snapan_market/core/components/glass_toolbar_top.dart';
import 'package:snapan_market/core/components/snaps_logo.dart';

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
  Size get preferredSize => const Size.fromHeight(52.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 52.0,
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. LEADING ICON (Menu / Kembali) - Pure icon only, no bg, no border
              Positioned(
                left: 0,
                child: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      onBackTap != null ? LucideIcons.arrowLeft : LucideIcons.menu,
                      key: ValueKey(onBackTap != null),
                      size: 22.0,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  onPressed: onBackTap ?? onMenuTap,
                  tooltip: onBackTap != null ? 'Kembali' : 'Menu Navigasi',
                  splashRadius: 20.0,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                ),
              ),

              // 2. CENTER LOGO (Snaps Official Vector Logo) OR TITLE
              Center(
                child: GestureDetector(
                  onTap: onTitleTap,
                  behavior: HitTestBehavior.opaque,
                  child: title == 'Snaps.'
                      ? const SnapsLogo(height: 24.0)
                      : Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: const Color(0xFF111827),
                          ),
                        ),
                ),
              ),

              // 3. TRAILING ICON (Cari) - Pure icon only, no bg, no border
              Positioned(
                right: 0,
                child: IconButton(
                  icon: const Icon(
                    LucideIcons.search,
                    size: 21.0,
                    color: Color(0xFF1A1A1A),
                  ),
                  onPressed: onSearchTap,
                  tooltip: 'Cari Produk & Diskusi',
                  splashRadius: 20.0,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

