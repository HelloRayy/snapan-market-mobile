import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snapan_market/core/components/snaps_logo.dart';

/// Top App Bar Header for Home Feed
/// Sliced from pen.dev `Toobar - Top - Chats` adapted for Home Screen
class HomeFeedHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuTap;
  final VoidCallback? onTitleTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onBackTap;
  final bool isDark;

  const HomeFeedHeader({
    super.key,
    this.title = 'Snaps.',
    this.onMenuTap,
    this.onTitleTap,
    this.onSearchTap,
    this.onBackTap,
    this.isDark = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(52.0);

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isDark ? const Color(0xFF101010) : Colors.white;
    final Color iconColor = isDark ? const Color(0xFFF3F5F7) : const Color(0xFF1A1A1A);
    final Color textColor = isDark ? const Color(0xFFF3F5F7) : const Color(0xFF111827);

    return Container(
      color: bgColor,
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
                      onBackTap != null ? CupertinoIcons.chevron_back : CupertinoIcons.bars,
                      key: ValueKey(onBackTap != null),
                      size: 22.0,
                      color: iconColor,
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
                      ? const SnapsLogo(height: 34.0)
                      : Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'SFPro',
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: textColor,
                          ),
                        ),
                ),
              ),

              // 3. TRAILING ICON (Cari) - Pure icon only, no bg, no border
              Positioned(
                right: 0,
                child: IconButton(
                  icon: Icon(
                    CupertinoIcons.search,
                    size: 22.0,
                    color: iconColor,
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

