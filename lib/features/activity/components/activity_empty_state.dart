import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Empty state placeholder view displayed when an activity category has no notifications.
class ActivityEmptyState extends StatelessWidget {
  const ActivityEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64.0,
            height: 64.0,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 28.0,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            'Belum ada aktivitas baru',
            style: TextStyle(
              color: AppColors.adaptiveText(context),
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Notifikasi pengumuman dan interaksi akan muncul di sini.',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}
