import "package:flutter/material.dart";

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
                color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                  width: 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.12),
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
                    color: isSelected ? Colors.white : const Color(0xFF475569),
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
