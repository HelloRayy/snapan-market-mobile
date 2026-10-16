import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Top header bar for the Activity Screen, containing title, mark-all-read action,
/// and horizontal filter category chips.
class ActivityHeaderBar extends StatelessWidget {
  final bool showAppBar;
  final int activeTabIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onMarkAllAsRead;

  const ActivityHeaderBar({
    super.key,
    required this.showAppBar,
    required this.activeTabIndex,
    required this.onTabChanged,
    required this.onMarkAllAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 12.0),
      decoration: BoxDecoration(
        color: AppColors.adaptiveSurface(context),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9),
            width: 0.8,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showAppBar) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aktivitas & Notifikasi',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800,
                    color: AppColors.adaptiveText(context),
                    letterSpacing: -0.3,
                  ),
                ),
                IconButton(
                  onPressed: onMarkAllAsRead,
                  icon: Icon(
                    Icons.done_all_rounded,
                    size: 20.0,
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                  ),
                  tooltip: 'Tandai semua dibaca',
                ),
              ],
            ),
            const SizedBox(height: 10.0),
          ],

          // Category Chips (Horizontal Scrollable for overflow prevention)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _ActivityFilterChip(
                  label: 'Semua',
                  isActive: activeTabIndex == 0,
                  onTap: () => onTabChanged(0),
                ),
                _ActivityFilterChip(
                  label: 'Pengumuman',
                  isActive: activeTabIndex == 1,
                  onTap: () => onTabChanged(1),
                ),
                _ActivityFilterChip(
                  label: 'Interaksi',
                  isActive: activeTabIndex == 2,
                  onTap: () => onTabChanged(2),
                ),
                _ActivityFilterChip(
                  label: 'Pesanan COD',
                  isActive: activeTabIndex == 3,
                  onTap: () => onTabChanged(3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ActivityFilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBg = isDark ? Colors.white : const Color(0xFF0F172A);
    final activeText = isDark ? const Color(0xFF0F172A) : Colors.white;
    final inactiveBg = isDark ? AppColors.darkSurface : Colors.white;
    final inactiveBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final inactiveText = isDark ? AppColors.darkTextSecondary : const Color(0xFF475569);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
          decoration: BoxDecoration(
            color: isActive ? activeBg : inactiveBg,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: isActive ? activeBg : inactiveBorder,
              width: 1.0,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: (isDark ? Colors.black : const Color(0xFF0F172A)).withValues(alpha: 0.12),
                      blurRadius: 6.0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? activeText : inactiveText,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}
