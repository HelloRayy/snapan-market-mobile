import "package:flutter/material.dart";
import "package:snapan_market/core/theme/app_colors.dart";
import "package:snapan_market/features/locations/models/campus_location_spot.dart";

class LocationSpotCard extends StatelessWidget {
  final CampusLocationSpot spot;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback? onDetailTap;

  const LocationSpotCard({
    super.key,
    required this.spot,
    this.isSelected = false,
    required this.onSelect,
    this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isSelected
        ? (isDark ? AppColors.darkPrimaryPastel : const Color(0xFFF5F7FF))
        : (isDark ? AppColors.darkSurface : Colors.white);
    final cardBorder = isSelected
        ? const Color(0xFF3D38F5)
        : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0));
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final hintBg = isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF8FAFC);
    final hintBorder = isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9);
    final hintTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF475569);
    final tagBg = isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F9);

    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: cardBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF3D38F5).withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 10.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon + Building + Floor Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Category Box
                Container(
                  width: 42.0,
                  height: 42.0,
                  decoration: BoxDecoration(
                    color: spot.themeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Icon(
                    spot.iconData,
                    size: 22.0,
                    color: spot.themeColor,
                  ),
                ),
                const SizedBox(width: 12.0),

                // Name & Building
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              spot.name,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: primaryTextColor,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (spot.isPopular) ...[
                            const SizedBox(width: 6.0),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(6.0),
                                border: Border.all(color: const Color(0xFFFFEDD5), width: 0.8),
                              ),
                              child: const Text(
                                "🔥 Populer",
                                style: TextStyle(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFEA580C),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        spot.buildingName,
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),

            // Description / Safety Hint
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: hintBg,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: hintBorder, width: 0.8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, size: 14.0, color: Color(0xFF10B981)),
                  const SizedBox(width: 6.0),
                  Expanded(
                    child: Text(
                      spot.codSafetyHint,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: hintTextColor,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),

            // Bottom Meta Row: Floor Tag + Best Time + Selection Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(
                        "Lantai ${spot.floor}",
                        style: const TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3D38F5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: tagBg,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(
                        spot.categoryLabel,
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                          color: hintTextColor,
                        ),
                      ),
                    ),
                  ],
                ),

                // Select / Radio Button
                Container(
                  width: 26.0,
                  height: 26.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color(0xFF3D38F5) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF3D38F5) : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16.0, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
