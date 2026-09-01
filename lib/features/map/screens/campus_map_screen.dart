import "package:flutter/material.dart";
import "package:snapan_market/core/components/kumo_button.dart";
import "package:snapan_market/core/theme/app_colors.dart";
import "package:snapan_market/features/map/components/campus_2d_blueprint_painter.dart";
import "package:snapan_market/features/map/models/campus_map_models.dart";

class CampusMapScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final void Function(String roomName, int floor, String category)? onSelectLocation;

  const CampusMapScreen({
    super.key,
    this.onBack,
    this.onSelectLocation,
  });

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  int _currentFloor = 1;
  late CampusRoom _selectedRoom;
  String _selectedCategory = "all";

  @override
  void initState() {
    super.initState();
    _selectedRoom = kCampusRooms[0];
  }

  List<CampusRoom> get _filteredRooms {
    return kCampusRooms.where((room) {
      if (_selectedCategory == "all") return true;
      return room.category == _selectedCategory;
    }).toList();
  }

  void _handleSelectRoom(CampusRoom room) {
    setState(() {
      _selectedRoom = room;
      _currentFloor = room.floor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          // 1. Interactive 2D Blueprint Interactive Canvas
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 3.0,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1150 / 880,
                  child: CustomPaint(
                    painter: Campus2DBlueprintPainter(
                      rooms: _filteredRooms,
                      selectedRoom: _selectedRoom,
                      floor: _currentFloor,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Floating Top Header (Back Button, Title, Floor Switcher)
          Positioned(
            top: topPadding > 0 ? topPadding + 10.0 : 16.0,
            left: 14.0,
            right: 14.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button & Label
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                            boxShadow: const [
                              BoxShadow(color: Color(0x0F000000), blurRadius: 10.0),
                            ],
                          ),
                          child: IconButton(
                            onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
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
                              BoxShadow(color: Color(0x0F000000), blurRadius: 10.0),
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

                    // Floor Switcher Pills (Lt 1 / Lt 2)
                    Container(
                      padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                        boxShadow: const [
                          BoxShadow(color: Color(0x0F000000), blurRadius: 10.0),
                        ],
                      ),
                      child: Row(
                        children: [
                          _FloorButton(
                            label: "Lt 1",
                            isActive: _currentFloor == 1,
                            onTap: () => setState(() => _currentFloor = 1),
                          ),
                          _FloorButton(
                            label: "Lt 2",
                            isActive: _currentFloor == 2,
                            onTap: () => setState(() => _currentFloor = 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),

                // Category Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _CategoryChip(
                        label: "Semua Spot",
                        isActive: _selectedCategory == "all",
                        onTap: () => setState(() => _selectedCategory = "all"),
                      ),
                      _CategoryChip(
                        label: "Kantin",
                        isActive: _selectedCategory == "canteen",
                        onTap: () => setState(() => _selectedCategory = "canteen"),
                      ),
                      _CategoryChip(
                        label: "Lab Komputer",
                        isActive: _selectedCategory == "lab",
                        onTap: () => setState(() => _selectedCategory = "lab"),
                      ),
                      _CategoryChip(
                        label: "Lobi",
                        isActive: _selectedCategory == "lobby",
                        onTap: () => setState(() => _selectedCategory = "lobby"),
                      ),
                      _CategoryChip(
                        label: "Gazebo",
                        isActive: _selectedCategory == "outdoor",
                        onTap: () => setState(() => _selectedCategory = "outdoor"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Floating Bottom Detail Card of Selected Spot
          Positioned(
            left: 14.0,
            right: 14.0,
            bottom: bottomPadding > 0 ? bottomPadding + 10.0 : 16.0,
            child: Container(
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
                              "Lantai ${_selectedRoom.floor}",
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            _selectedRoom.categoryLabel,
                            style: const TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3D38F5),
                            ),
                          ),
                        ],
                      ),
                      if (_selectedRoom.isPopularCodSpot)
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
                    _selectedRoom.name,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    _selectedRoom.hint,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF64748B),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14.0),

                  // Action Button: Select Location
                  KumoButton(
                    text: "Pilih Titik COD Ini",
                    icon: Icons.check_circle_outline_rounded,
                    onTap: () {
                      if (widget.onSelectLocation != null) {
                        widget.onSelectLocation!(
                          _selectedRoom.name,
                          _selectedRoom.floor,
                          _selectedRoom.categoryLabel,
                        );
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
