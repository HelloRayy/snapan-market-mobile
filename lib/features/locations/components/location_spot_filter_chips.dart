import "package:flutter/material.dart";
import "package:snapan_market/core/theme/app_colors.dart";

class LocationSpotFilterChips extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  const LocationSpotFilterChips({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  static const List<Map<String, String>> _filters = [
    {"id": "all", "label": "Semua Spot"},
    {"id": "popular", "label": "🔥 Terfavorit"},
    {"id": "floor-1", "label": "Lantai 1"},
    {"id": "floor-2", "label": "Lantai 2"},
    {"id": "canteen", "label": "Kantin & Makanan"},
    {"id": "lobby", "label": "Lobi & Masuk"},
    {"id": "outdoor", "label": "Area Terbuka"},
    {"id": "lab", "label": "Lab & Vokasi"},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBg = isDark ? Colors.white : const Color(0xFF0F172A);
    final activeText = isDark ? const Color(0xFF0F172A) : Colors.white;
    final inactiveBg = isDark ? AppColors.darkSurface : Colors.white;
    final inactiveBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final inactiveText = isDark ? AppColors.darkTextSecondary : const Color(0xFF475569);

    return SizedBox(
      height: 38.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8.0),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = activeFilter == filter["id"];

          return InkWell(
            onTap: () => onFilterChanged(filter["id"]!),
            borderRadius: BorderRadius.circular(20.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: isSelected ? activeBg : inactiveBg,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: isSelected ? activeBg : inactiveBorder,
                  width: 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: (isDark ? Colors.white : const Color(0xFF0F172A)).withValues(alpha: 0.12),
                          blurRadius: 6.0,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  filter["label"]!,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? activeText : inactiveText,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
