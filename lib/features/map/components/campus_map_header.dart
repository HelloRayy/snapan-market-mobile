import 'package:flutter/material.dart';

/// Floating top bar with back navigation, blueprint title, floor selector, and category chips.
class CampusMapHeader extends StatelessWidget {
  final VoidCallback onBack;
  final int currentFloor;
  final ValueChanged<int> onFloorChanged;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const CampusMapHeader({
    super.key,
    required this.onBack,
    required this.currentFloor,
    required this.onFloorChanged,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 8.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back, size: 20.0, color: Color(0xFF0F172A)),
                    constraints: const BoxConstraints(minWidth: 40.0, minHeight: 40.0),
                  ),
                ),
                const SizedBox(width: 10.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 8.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.location_on, size: 14.0, color: Color(0xFF3D38F5)),
                      SizedBox(width: 4.0),
                      Text(
                        "Denah 2D SMKN 8",
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _FloorButton(
                    label: "Lt 1",
                    isActive: currentFloor == 1,
                    onTap: () => onFloorChanged(1),
                  ),
                  _FloorButton(
                    label: "Lt 2",
                    isActive: currentFloor == 2,
                    onTap: () => onFloorChanged(2),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _CategoryChip(
                label: "Semua Spot",
                isActive: selectedCategory == "all",
                onTap: () => onCategoryChanged("all"),
              ),
              _CategoryChip(
                label: "Kantin",
                isActive: selectedCategory == "canteen",
                onTap: () => onCategoryChanged("canteen"),
              ),
              _CategoryChip(
                label: "Lab Komputer",
                isActive: selectedCategory == "lab",
                onTap: () => onCategoryChanged("lab"),
              ),
              _CategoryChip(
                label: "Lobi",
                isActive: selectedCategory == "lobby",
                onTap: () => onCategoryChanged("lobby"),
              ),
              _CategoryChip(
                label: "Gazebo",
                isActive: selectedCategory == "outdoor",
                onTap: () => onCategoryChanged("outdoor"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FloorButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FloorButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0F172A) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF3D38F5) : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: isActive ? const Color(0xFF3D38F5) : const Color(0xFFE2E8F0),
              width: 0.8,
            ),
            boxShadow: const [
              BoxShadow(color: Color(0x0A000000), blurRadius: 6.0),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.white : const Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
  }
}
