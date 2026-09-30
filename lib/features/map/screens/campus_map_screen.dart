import 'package:flutter/material.dart';
import 'package:snapan-market/features/map/components/campus_2d_blueprint_painter.dart';
import 'package:snapan-market/features/map/components/campus_map_header.dart';
import 'package:snapan-market/features/map/components/campus_map_room_card.dart';
import 'package:snapan-market/features/map/models/campus_map_models.dart';

/// Interactive 2D Campus Map blueprint screen for selecting meeting points.
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

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
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
          Positioned(
            top: topPadding > 0 ? topPadding + 10.0 : 16.0,
            left: 14.0,
            right: 14.0,
            child: CampusMapHeader(
              onBack: widget.onBack ?? () => Navigator.of(context).pop(),
              currentFloor: _currentFloor,
              onFloorChanged: (f) => setState(() => _currentFloor = f),
              selectedCategory: _selectedCategory,
              onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
            ),
          ),
          Positioned(
            left: 14.0,
            right: 14.0,
            bottom: bottomPadding > 0 ? bottomPadding + 10.0 : 16.0,
            child: CampusMapRoomCard(
              room: _selectedRoom,
              onSelectLocation: () {
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
          ),
        ],
      ),
    );
  }
}
