import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/services/theme_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Clean Bottom Sheet to select appearance mode (Sistem, Terang, Gelap)
/// Modeled after Threads / iOS appearance settings with zero-glare design.
class AppearanceBottomSheet extends StatelessWidget {
  const AppearanceBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const AppearanceBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentMode = ThemeService.instance.themeMode;

    final sheetBg = isDark ? AppColors.darkSurfaceElevated : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.ink;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.muted;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
        border: Border(
          top: BorderSide(color: borderColor, width: 0.8),
        ),
      ),
      padding: EdgeInsets.only(
        top: 12.0,
        left: 20.0,
        right: 20.0,
        bottom: MediaQuery.of(context).padding.bottom + 20.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF374151) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          const SizedBox(height: 18.0),

          // Header
          Text(
            'Tampilan',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            'Sesuaikan tema tampilan Snaps agar nyaman di mata.',
            style: TextStyle(
              fontSize: 13.5,
              color: mutedColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20.0),

          // Option 1: Ikuti Sistem
          _buildThemeOption(
            context: context,
            title: 'Sesuai Sistem',
            subtitle: 'Otomatis mengikuti preferensi perangkat Anda',
            icon: CupertinoIcons.device_phone_portrait,
            isSelected: currentMode == AppThemeMode.system,
            isDark: isDark,
            onTap: () => _selectMode(context, AppThemeMode.system),
          ),
          const SizedBox(height: 10.0),

          // Option 2: Mode Terang
          _buildThemeOption(
            context: context,
            title: 'Mode Terang',
            subtitle: 'Latar belakang putih bersih khas Snaps',
            icon: CupertinoIcons.sun_max_fill,
            isSelected: currentMode == AppThemeMode.light,
            isDark: isDark,
            onTap: () => _selectMode(context, AppThemeMode.light),
          ),
          const SizedBox(height: 10.0),

          // Option 3: Mode Gelap
          _buildThemeOption(
            context: context,
            title: 'Mode Gelap',
            subtitle: 'Latar OLED pure black anti-silau ala Threads',
            icon: CupertinoIcons.moon_fill,
            isSelected: currentMode == AppThemeMode.dark,
            isDark: isDark,
            onTap: () => _selectMode(context, AppThemeMode.dark),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final Color itemBg = isSelected
        ? (isDark ? const Color(0xFF262829) : const Color(0xFFEEF2FF))
        : (isDark ? const Color(0xFF161717) : const Color(0xFFF8FAFC));

    final Color borderClr = isSelected
        ? (isDark ? AppColors.darkPrimary : AppColors.primary)
        : (isDark ? const Color(0x1AFFFFFF) : const Color(0xFFE2E8F0));

    final Color titleClr = isDark ? AppColors.darkTextPrimary : AppColors.ink;
    final Color subClr = isDark ? AppColors.darkTextSecondary : AppColors.muted;
    final Color iconClr = isSelected
        ? (isDark ? AppColors.darkPrimary : AppColors.primary)
        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: itemBg,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: borderClr,
            width: isSelected ? 1.4 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconClr, size: 22.0),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: titleClr,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: subClr,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                CupertinoIcons.checkmark_alt_circle_fill,
                color: isDark ? AppColors.darkPrimary : AppColors.primary,
                size: 20.0,
              ),
          ],
        ),
      ),
    );
  }

  void _selectMode(BuildContext context, AppThemeMode mode) {
    HapticFeedback.lightImpact();
    ThemeService.instance.setThemeMode(mode);
    Navigator.of(context).maybePop();
  }
}
