import "package:flutter/material.dart";
import "package:snapan_market/core/theme/app_colors.dart";
import "package:snapan_market/features/locations/components/location_spot_card.dart";
import "package:snapan_market/features/locations/components/location_spot_detail_sheet.dart";
import "package:snapan_market/features/locations/components/location_spot_filter_chips.dart";
import "package:snapan_market/features/locations/models/campus_location_spot.dart";
import "package:snapan_market/features/map/screens/campus_map_screen.dart";

class CampusLocationsPickerScreen extends StatefulWidget {
  final CampusLocationSpot? selectedSpot;
  final ValueChanged<CampusLocationSpot> onSpotSelected;

  const CampusLocationsPickerScreen({
    super.key,
    this.selectedSpot,
    required this.onSpotSelected,
  });

  @override
  State<CampusLocationsPickerScreen> createState() => _CampusLocationsPickerScreenState();
}

class _CampusLocationsPickerScreenState extends State<CampusLocationsPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = "all";
  late String _selectedSpotId;

  @override
  void initState() {
    super.initState();
    _selectedSpotId = widget.selectedSpot?.id ?? kCampusLocationSpots.first.id;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CampusLocationSpot> get _filteredSpots {
    final query = _searchController.text.trim().toLowerCase();

    return kCampusLocationSpots.where((spot) {
      // 1. Search Query Filter
      if (query.isNotEmpty) {
        final matchesName = spot.name.toLowerCase().contains(query);
        final matchesBuilding = spot.buildingName.toLowerCase().contains(query);
        final matchesCategory = spot.categoryLabel.toLowerCase().contains(query);
        if (!matchesName && !matchesBuilding && !matchesCategory) {
          return false;
        }
      }

      // 2. Category / Floor Filter
      switch (_activeFilter) {
        case "popular":
          return spot.isPopular;
        case "floor-1":
          return spot.floor == 1;
        case "floor-2":
          return spot.floor == 2;
        case "canteen":
          return spot.category == LocationCategory.canteen;
        case "lobby":
          return spot.category == LocationCategory.lobby;
        case "outdoor":
          return spot.category == LocationCategory.outdoor;
        case "lab":
          return spot.category == LocationCategory.lab;
        case "all":
        default:
          return true;
      }
    }).toList();
  }

  void _handleSelectSpot(CampusLocationSpot spot) {
    setState(() => _selectedSpotId = spot.id);
    widget.onSpotSelected(spot);
    Navigator.of(context).pop();
  }

  void _open2DMap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CampusMapScreen(
          onBack: () => Navigator.of(context).pop(),
          onSelectLocation: (roomName, floor, category) {
            // Find matched spot or create one
            final matchedSpot = kCampusLocationSpots.firstWhere(
              (s) => s.name.toLowerCase().contains(roomName.toLowerCase()) ||
                     roomName.toLowerCase().contains(s.name.toLowerCase()),
              orElse: () => CampusLocationSpot(
                id: roomName.toLowerCase().replaceAll(" ", "-"),
                name: roomName,
                code: roomName.toUpperCase(),
                buildingName: "Area SMKN 8 Semarang",
                floor: floor,
                category: LocationCategory.lobby,
                categoryLabel: category,
                description: "Titik temu yang dipilih langsung dari Denah 2D Kampus.",
                codSafetyHint: "Pastikan janjian pada jam istirahat agar mudah bertemu.",
                bestTime: "Jam istirahat sekolah",
                pinPosition: const Offset(500, 400),
                iconData: Icons.place_rounded,
                themeColor: const Color(0xFF3D38F5),
              ),
            );

            Navigator.of(context).pop(); // Close 2D Map
            _handleSelectSpot(matchedSpot);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredSpots;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Pilih Titik Temu COD",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            Text(
              "SMK Negeri 8 Semarang",
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        actions: [
          // 2D Map Button in Header
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              onPressed: _open2DMap,
              icon: const Icon(Icons.map_outlined, size: 16.0, color: Color(0xFF3D38F5)),
              label: const Text(
                "Buka Denah",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3D38F5),
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFEEF0FF),
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Section: Search Bar & Info Banner
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
            child: Column(
              children: [
                // Search TextField
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: "Cari nama spot, gedung, atau lantai...",
                      hintStyle: const TextStyle(fontSize: 13.0, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search, size: 18.0, color: Color(0xFF64748B)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16.0, color: Color(0xFF64748B)),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 11.0),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 12.0),
            child: LocationSpotFilterChips(
              activeFilter: _activeFilter,
              onFilterChanged: (filterId) {
                setState(() => _activeFilter = filterId);
              },
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Spot List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56.0,
                          height: 56.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: const Icon(Icons.location_off_outlined, size: 28.0, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 12.0),
                        const Text(
                          "Tidak ada spot COD yang sesuai",
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        const Text(
                          "Coba ubah kata kunci atau ganti filter kategori.",
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12.0),
                    itemBuilder: (context, index) {
                      final spot = filtered[index];
                      final isSelected = spot.id == _selectedSpotId;

                      return LocationSpotCard(
                        spot: spot,
                        isSelected: isSelected,
                        onSelect: () => _handleSelectSpot(spot),
                        onDetailTap: () {
                          LocationSpotDetailSheet.show(
                            context,
                            spot,
                            () => _handleSelectSpot(spot),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
