import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Secondary grouped card for theme, settings, and problem report in HomeNavDrawer (<100 lines).
class HomeNavPreferencesCard extends StatelessWidget {
  final VoidCallback? onAppearanceTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onReportTap;

  const HomeNavPreferencesCard({
    super.key,
    this.onAppearanceTap,
    this.onSettingsTap,
    this.onReportTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161618),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF27272A), width: 1.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      child: Column(
        children: [
          _buildRow(
            icon: CupertinoIcons.moon,
            title: 'Tampilan & Tema',
            onTap: onAppearanceTap,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Divider(color: const Color(0xFF27272A), height: 1.0),
          ),
          _buildRow(
            icon: CupertinoIcons.gear_alt,
            title: 'Pengaturan Akun',
            onTap: onSettingsTap,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Divider(color: const Color(0xFF27272A), height: 1.0),
          ),
          _buildRow(
            icon: CupertinoIcons.exclamationmark_bubble,
            title: 'Laporkan Masalah',
            onTap: onReportTap,
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16.0, color: const Color(0xFFA1A1AA)),
                const SizedBox(width: 10.0),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFD4D4D8),
                  ),
                ),
              ],
            ),
            const Icon(
              CupertinoIcons.chevron_forward,
              size: 13.0,
              color: Color(0xFF71717A),
            ),
          ],
        ),
      ),
    );
  }
}
