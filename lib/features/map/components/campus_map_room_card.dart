import 'package:flutter/material.dart';
import 'package:snapan_market/core/components/kumo_button.dart';
import 'package:snapan_market/features/map/models/campus_map_models.dart';

/// Floating bottom card displaying selected room/spot details and confirmation CTA.
class CampusMapRoomCard extends StatelessWidget {
  final CampusRoom room;
  final VoidCallback onSelectLocation;

  const CampusMapRoomCard({
    super.key,
    required this.room,
    required this.onSelectLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 16.0, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D38F5),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      "Lantai ${room.floor}",
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    room.categoryLabel,
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3D38F5),
                    ),
                  ),
                ],
              ),
              if (room.isPopularCodSpot)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: const Text(
                    "Spot Terfavorit",
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            room.name,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            room.hint,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF64748B),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14.0),
          KumoButton(
            text: "Pilih Titik COD Ini",
            iconLeft: const Icon(Icons.check_circle_outline_rounded, size: 18.0, color: Colors.white),
            onPressed: onSelectLocation,
          ),
        ],
      ),
    );
  }
}
