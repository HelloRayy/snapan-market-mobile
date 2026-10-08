import 'package:flutter/material.dart';
import 'package:snapan_market/core/services/meeting_point_service.dart';
import 'package:snapan_market/features/map/components/campus_2d_blueprint_painter.dart';
import 'package:snapan_market/features/map/components/campus_map_header.dart';
import 'package:snapan_market/features/map/components/campus_map_room_card.dart';
import 'package:snapan_market/features/map/models/campus_map_models.dart';

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
  final MeetingPointService _meetingPointService = MeetingPointService();
  int _currentFloor = 1;
  late CampusRoom _selectedRoom;
  String _selectedCategory = "all";
  List<CampusRoom> _allRooms = kCampusRooms;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedRoom = kCampusRooms[0];
    _loadMeetingPoints();
  }

  Future<void> _loadMeetingPoints() async {
    final spots = await _meetingPointService.fetchMeetingPoints();
    if (!mounted) return;
    setState(() {
      _allRooms = spots;
      _isLoading = false;
      // Match current selected room or default to first of the floor
      final floorRooms = spots.where((r) => r.floor == _currentFloor).toList();
      if (floorRooms.isNotEmpty) {
        _selectedRoom = floorRooms.first;
      } else if (spots.isNotEmpty) {
        _selectedRoom = spots.first;
        _currentFloor = _selectedRoom.floor;
      }
    });
  }

  List<CampusRoom> get _filteredRooms {
    return _allRooms.where((room) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CampusMapHeader(
                  onBack: widget.onBack ?? () => Navigator.of(context).pop(),
                  currentFloor: _currentFloor,
                  onFloorChanged: (f) {
                    setState(() {
                      _currentFloor = f;
                      final floorRooms = _filteredRooms.where((r) => r.floor == f).toList();
                      if (floorRooms.isNotEmpty && _selectedRoom.floor != f) {
                        _selectedRoom = floorRooms.first;
                      }
                    });
                  },
                  selectedCategory: _selectedCategory,
                  onCategoryChanged: (cat) {
                    setState(() {
                      _selectedCategory = cat;
                      final catRooms = _filteredRooms.where((r) => r.floor == _currentFloor).toList();
                      if (catRooms.isNotEmpty && !_filteredRooms.contains(_selectedRoom)) {
                        _selectedRoom = catRooms.first;
                      }
                    });
                  },
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 6.0),
                    child: LinearProgressIndicator(
                      minHeight: 2.0,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3D38F5)),
                    ),
                  ),
              ],
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
