import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:snapan_market/core/services/app_update_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Minimalist Left-to-Right Navigation Drawer for Home Feed
///
/// Replaces the legacy top-left popover menu with a smooth 280dp flat drawer.
/// Displays a pure vertical list reflecting existing menu options:
/// 1. Tampilan (Mode Tema)
/// 2. Pengaturan (Settings)
/// 3. Disukai (Liked Activity)
/// 4. Arsip (Archive)
/// 5. Laporkan masalah (Report issue)
/// 6. Masuk / Daftar Akun (Guest) OR Logout (Authenticated)
class HomeNavDrawer extends StatelessWidget {
  final VoidCallback? onAppearanceTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onLikedTap;
  final VoidCallback? onArchiveTap;
  final VoidCallback? onReportTap;
  final VoidCallback? onCheckUpdateTap;
  final VoidCallback? onLogout;
  final VoidCallback? onAuthTap;
  final Map<String, dynamic>? userProfile;

  const HomeNavDrawer({
    super.key,
    this.onAppearanceTap,
    this.onSettingsTap,
    this.onLikedTap,
    this.onArchiveTap,
    this.onReportTap,
    this.onCheckUpdateTap,
    this.onLogout,
    this.onAuthTap,
    this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAuthenticated = SupabaseService.instance.isAuthenticated;
    final currentUser = SupabaseService.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark ? const Color(0xFF101010) : Colors.white;
    final Color inkColor = isDark ? const Color(0xFFF3F5F7) : const Color(0xFF111827);
    final Color mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final Color tileHoverColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);

    final String displayName = userProfile?['full_name'] ??
        currentUser?.userMetadata?['full_name'] ??
        currentUser?.email?.split('@').first ??
        'Siswa SMKN 8 Semarang';
    final String displayEmail = currentUser?.email ?? 'Belum masuk';

    return Drawer(
      width: 280.0,
      elevation: 16.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      backgroundColor: bgColor,
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // 2. User Profile Tile / Guest Welcome Banner
            if (isAuthenticated)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161E2E) : const Color(0xFFF8FAFC),
                  border: Border(
                    bottom: BorderSide(color: borderColor, width: 1.0),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20.0,
                      backgroundColor: AppColors.primary,
                      backgroundImage: userProfile?['avatar_url'] != null
                          ? NetworkImage(userProfile!['avatar_url'])
                          : null,
                      child: userProfile?['avatar_url'] == null
                          ? Text(
                              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'S',
                              style: GoogleFonts.inter(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: inkColor,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            displayEmail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12.0,
                              color: mutedColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // 3. Main Navigation List (Pure vertical matching popup)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                physics: const BouncingScrollPhysics(),
                children: [
                  // 1. Tampilan
                  _buildDrawerItem(
                    context: context,
                    icon: LucideIcons.palette,
                    label: 'Tampilan',
                    hasChevron: true,
                    inkColor: inkColor,
                    mutedColor: mutedColor,
                    hoverColor: tileHoverColor,
                    onTap: onAppearanceTap,
                  ),

                  // 2. Pengaturan
                  _buildDrawerItem(
                    context: context,
                    icon: LucideIcons.settings,
                    label: 'Pengaturan',
                    inkColor: inkColor,
                    mutedColor: mutedColor,
                    hoverColor: tileHoverColor,
                    onTap: onSettingsTap,
                  ),

                  // 3. Disukai
                  _buildDrawerItem(
                    context: context,
                    icon: LucideIcons.heart,
                    label: 'Disukai',
                    inkColor: inkColor,
                    mutedColor: mutedColor,
                    hoverColor: tileHoverColor,
                    onTap: onLikedTap,
                  ),

                  // 4. Arsip
                  _buildDrawerItem(
                    context: context,
                    icon: LucideIcons.bookmark,
                    label: 'Arsip',
                    inkColor: inkColor,
                    mutedColor: mutedColor,
                    hoverColor: tileHoverColor,
                    onTap: onArchiveTap,
                  ),

                  // 5. Laporkan masalah
                  _buildDrawerItem(
                    context: context,
                    icon: LucideIcons.messageSquareWarning,
                    label: 'Laporkan masalah',
                    inkColor: inkColor,
                    mutedColor: mutedColor,
                    hoverColor: tileHoverColor,
                    onTap: onReportTap,
                  ),

                  // 6. Periksa pembaruan
                  _buildDrawerItem(
                    context: context,
                    icon: LucideIcons.refreshCw,
                    label: 'Periksa pembaruan',
                    inkColor: inkColor,
                    mutedColor: mutedColor,
                    hoverColor: tileHoverColor,
                    trailingWidget: AppUpdateService.instance.hasAvailableUpdate
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: const Text(
                              'Update',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : null,
                    onTap: onCheckUpdateTap,
                  ),

                  const SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Divider(color: borderColor, height: 1.0),
                  ),
                  const SizedBox(height: 8.0),

                  // 6. Masuk / Daftar Akun OR Logout
                  if (!isAuthenticated)
                    _buildDrawerItem(
                      context: context,
                      icon: LucideIcons.logIn,
                      label: 'Masuk / Daftar Akun',
                      textColor: AppColors.primary,
                      iconColor: AppColors.primary,
                      inkColor: inkColor,
                      mutedColor: mutedColor,
                      hoverColor: isDark
                          ? const Color(0xFF1E1B4B)
                          : const Color(0xFFEEF0FF),
                      onTap: onAuthTap,
                    )
                  else
                    _buildDrawerItem(
                      context: context,
                      icon: LucideIcons.logOut,
                      label: 'Logout',
                      textColor: AppColors.error,
                      iconColor: AppColors.error,
                      isDestructive: true,
                      inkColor: inkColor,
                      mutedColor: mutedColor,
                      hoverColor: isDark
                          ? const Color(0xFF450A0A)
                          : const Color(0xFFFEF2F2),
                      onTap: () => _confirmLogout(context, onLogout),
                    ),
                ],
              ),
            ),

            // 4. Footer Branding & Version
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: borderColor, width: 1.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Snaps Market Mobile v1.0.2 (Build 3)',
                    style: GoogleFonts.inter(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: inkColor,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'E-Commerce & Social Feed • SMKN 8 Semarang',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: mutedColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color inkColor,
    required Color mutedColor,
    required Color hoverColor,
    VoidCallback? onTap,
    Color? textColor,
    Color? iconColor,
    Widget? trailingWidget,
    bool hasChevron = false,
    bool isDestructive = false,
  }) {
    final effectiveTextColor = textColor ?? inkColor;
    final effectiveIconColor = iconColor ?? mutedColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop(); // Close drawer first
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(10.0),
        hoverColor: hoverColor,
        splashColor: hoverColor,
        highlightColor: Colors.transparent,
        child: Container(
          height: 46.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Icon(
                icon,
                size: 19.0,
                color: effectiveIconColor,
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    fontWeight: isDestructive ? FontWeight.w600 : FontWeight.w500,
                    color: effectiveTextColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              if (trailingWidget != null)
                trailingWidget
              else if (hasChevron)
                Icon(
                  LucideIcons.chevronRight,
                  size: 16.0,
                  color: mutedColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, VoidCallback? onLogoutAction) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text(
          'Keluar dari Snaps?',
          style: GoogleFonts.inter(
            fontSize: 17.0,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Anda harus masuk kembali untuk membuat postingan, pesan, dan berbelanja.',
          style: GoogleFonts.inter(
            fontSize: 14.0,
            color: const Color(0xFF64748B),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.inter(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
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
              onLogoutAction?.call();
            },
            child: Text(
              'Logout',
              style: GoogleFonts.inter(
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
