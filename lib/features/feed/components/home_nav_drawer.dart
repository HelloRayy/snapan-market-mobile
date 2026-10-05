import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snapan_market/core/services/app_update_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/feed/components/drawer/home_drawer_footer.dart';
import 'package:snapan_market/features/feed/components/drawer/home_drawer_item.dart';
import 'package:snapan_market/features/feed/components/drawer/home_drawer_logout_dialog.dart';
import 'package:snapan_market/features/feed/components/drawer/home_drawer_profile_header.dart';

/// Minimalist Left-to-Right Navigation Drawer for Home Feed
///
/// Displays a pure vertical list reflecting existing menu options:
/// 1. Tampilan (Mode Tema)
/// 2. Pengaturan (Settings)
/// 3. Disukai (Liked Activity)
/// 4. Arsip (Archive)
/// 5. Laporkan masalah (Report issue)
/// 6. Periksa pembaruan (Check update)
/// 7. Masuk / Daftar Akun (Guest) OR Logout (Authenticated)
class HomeNavDrawer extends StatelessWidget {
  final VoidCallback? onAppearanceTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onLikedTap;
  final VoidCallback? onArchiveTap;
  final VoidCallback? onReportTap;
  final VoidCallback? onCheckUpdateTap;
  final VoidCallback? onLogout;
  final VoidCallback? onAuthTap;
  final VoidCallback? onClose;
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
    this.onClose,
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

    final rawFullName = (userProfile?['full_name'] as String?)?.trim() ??
        (currentUser?.userMetadata?['full_name'] as String?)?.trim();
    final rawUsername = (userProfile?['username'] as String?)?.trim() ??
        (currentUser?.userMetadata?['username'] as String?)?.trim() ??
        (currentUser?.email?.contains('@snapan.id') == true
            ? currentUser?.email?.split('@').first
            : null);
    final rawClass = (userProfile?['class_group'] as String?)?.trim() ??
        (currentUser?.userMetadata?['class_group'] as String?)?.trim();

    final String displayName = (rawFullName != null && rawFullName.isNotEmpty)
        ? rawFullName
        : ((rawUsername != null && rawUsername.isNotEmpty)
            ? '@${rawUsername.replaceAll('@', '')}'
            : 'Siswa SMKN 8 Semarang');

    final String cleanUsername = (rawUsername != null && rawUsername.isNotEmpty)
        ? rawUsername.replaceAll('@', '')
        : (currentUser?.email != null && currentUser!.email!.isNotEmpty
            ? currentUser.email!.split('@').first
            : 'siswa');

    final String? resolvedClass = (rawClass != null && rawClass.trim().isNotEmpty)
        ? rawClass.trim()
        : null;

    // Baris kedua drawer: '@username • Kelas / Jurusan' (bukan email sistem @snapan.id)
    final String displaySubtitle;
    if (resolvedClass != null && resolvedClass.toLowerCase() != 'siswa snapan') {
      displaySubtitle = '@$cleanUsername • $resolvedClass';
    } else if (resolvedClass != null) {
      displaySubtitle = '@$cleanUsername • $resolvedClass';
    } else {
      displaySubtitle = '@$cleanUsername • Siswa SMKN 8';
    }

    return Drawer(
      width: 285.0,
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      backgroundColor: bgColor,
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. User Profile Tile / Guest Welcome Banner
            if (isAuthenticated)
              HomeDrawerProfileHeader(
                userProfile: userProfile,
                displayName: displayName,
                displaySubtitle: displaySubtitle,
                borderColor: borderColor,
                inkColor: inkColor,
                mutedColor: mutedColor,
                isDark: isDark,
              ),

            // 2. Main Navigation List (Pure vertical matching original)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                physics: const BouncingScrollPhysics(),
                children: [
                  HomeDrawerItem(
                    icon: CupertinoIcons.circle_lefthalf_fill,
                    label: 'Tampilan',
                    hasChevron: true,
                    inkColor: inkColor,
                    mutedColor: mutedColor,
                    hoverColor: tileHoverColor,
                    onTap: onAppearanceTap,
                    onClose: onClose,
                  ),
                  HomeDrawerItem(
                    icon: CupertinoIcons.bell,
                    label: 'Panduan Notifikasi HP',
                    inkColor: inkColor,
                    mutedColor: mutedColor,
                    hoverColor: tileHoverColor,
                    onTap: onSettingsTap,
                    onClose: onClose,
                  ),
                  HomeDrawerItem(
                    icon: CupertinoIcons.heart,
                    label: 'Disukai',
                    inkColor: inkColor,
                    mutedColor: mutedColor,
                    hoverColor: tileHoverColor,
                    onTap: onLikedTap,
                    onClose: onClose,
                  ),
                  HomeDrawerItem(
                    icon: CupertinoIcons.archivebox,
                    label: 'Arsip',
                    inkColor: inkColor,
                    mutedColor: mutedColor,
                    hoverColor: tileHoverColor,
                    onTap: onArchiveTap,
                    onClose: onClose,
                  ),
                  HomeDrawerItem(
                    icon: CupertinoIcons.exclamationmark_bubble,
                    label: 'Laporkan masalah',
                    inkColor: inkColor,
                    mutedColor: mutedColor,
                    hoverColor: tileHoverColor,
                    onTap: onReportTap,
                    onClose: onClose,
                  ),
                  HomeDrawerItem(
                    icon: CupertinoIcons.arrow_clockwise,
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
                                fontFamily: 'SFPro',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : null,
                    onTap: onCheckUpdateTap,
                    onClose: onClose,
                  ),
                  const SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Divider(color: borderColor, height: 1.0),
                  ),
                  const SizedBox(height: 8.0),
                  if (!isAuthenticated)
                    HomeDrawerItem(
                      icon: CupertinoIcons.arrow_right_square,
                      label: 'Masuk / Daftar Akun',
                      textColor: AppColors.primary,
                      iconColor: AppColors.primary,
                      inkColor: inkColor,
                      mutedColor: mutedColor,
                      hoverColor: isDark
                          ? const Color(0xFF1E1B4B)
                          : const Color(0xFFEEF0FF),
                      onTap: onAuthTap,
                      onClose: onClose,
                    )
                  else
                    HomeDrawerItem(
                      icon: CupertinoIcons.square_arrow_right,
                      label: 'Logout',
                      textColor: AppColors.error,
                      iconColor: AppColors.error,
                      isDestructive: true,
                      inkColor: inkColor,
                      mutedColor: mutedColor,
                      hoverColor: isDark
                          ? const Color(0xFF450A0A)
                          : const Color(0xFFFEF2F2),
                      onTap: () => HomeDrawerLogoutDialog.show(context, onLogout),
                      onClose: onClose,
                    ),
                ],
              ),
            ),

            // 3. Footer Branding & Version
            HomeDrawerFooter(
              borderColor: borderColor,
              inkColor: inkColor,
              mutedColor: mutedColor,
            ),
          ],
        ),
      ),
    );
  }
}
