import "package:flutter/material.dart";
import "package:snapan_market/features/map/models/campus_map_models.dart";

class Campus2DBlueprintPainter extends CustomPainter {
  final List<CampusRoom> rooms;
  final CampusRoom selectedRoom;
  final int floor;

  Campus2DBlueprintPainter({
    required this.rooms,
    required this.selectedRoom,
    required this.floor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 1150.0;
    final scaleY = size.height / 880.0;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    canvas.save();
    canvas.scale(scale);

    // 1. Background Grass/Courtyard
    final grassPaint = Paint()..color = const Color(0xFFDCFCE7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(290, 240, 370, 340), const Radius.circular(16)),
      grassPaint,
    );

    final innerGrassPaint = Paint()..color = const Color(0xFFD1FAE5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(330, 270, 290, 180), const Radius.circular(8)),
      innerGrassPaint,
    );

    // 2. Roads
    final roadPaint = Paint()..color = const Color(0xFFE2E8F0);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 85, 880), roadPaint);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 1150, 65), roadPaint);

    // 3. Buildings Outlines
    final bldgFill = Paint()..color = Colors.white;
    final bldgStroke = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Building 1: Main L-Wing
    final path1 = Path()
      ..moveTo(112, 85)
      ..lineTo(910, 25)
      ..lineTo(910, 162)
      ..lineTo(272, 208)
      ..lineTo(274, 620)
      ..lineTo(132, 630)
      ..close();
    canvas.drawPath(path1, bldgFill);
    canvas.drawPath(path1, bldgStroke);

    // Building 2: Aula Tengah
    final path2 = Path()
      ..moveTo(324, 435)
      ..lineTo(658, 418)
      ..lineTo(660, 522)
      ..lineTo(328, 540)
      ..close();
    canvas.drawPath(path2, bldgFill);
    canvas.drawPath(path2, bldgStroke);

    // Building 3: Gedung Vokasi (RPL/DKV)
    final path3 = Path()
      ..moveTo(678, 395)
      ..lineTo(870, 375)
      ..lineTo(884, 582)
      ..lineTo(688, 604)
      ..close();
    canvas.drawPath(path3, bldgFill);
    canvas.drawPath(path3, bldgStroke);

    // Building 4: Kantin
    final path4 = Path()
      ..moveTo(560, 690)
      ..lineTo(630, 630)
      ..lineTo(760, 720)
      ..lineTo(690, 780)
      ..close();
    canvas.drawPath(path4, bldgFill);
    canvas.drawPath(path4, bldgStroke);

    // Building 5: Gazebo
    final path5 = Path()
      ..moveTo(755, 640)
      ..lineTo(825, 580)
      ..lineTo(915, 635)
      ..lineTo(845, 700)
      ..close();
    canvas.drawPath(path5, bldgFill);
    canvas.drawPath(path5, bldgStroke);

    // 4. Room Pins
    for (final room in rooms) {
      if (room.floor != floor) continue;
      final isSelected = room.id == selectedRoom.id;

      final pinCenter = room.pinPosition;

      if (isSelected) {
        // Outer Radar Glow
        final glowPaint = Paint()
          ..color = const Color(0xFF3D38F5).withValues(alpha: 0.25)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pinCenter, 24.0, glowPaint);

        // Outer Ring
        final ringPaint = Paint()
          ..color = const Color(0xFF3D38F5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;
        canvas.drawCircle(pinCenter, 24.0, ringPaint);

        // Core Selected Pin
        final corePaint = Paint()..color = const Color(0xFF3D38F5);
        final whiteRing = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5;
        canvas.drawCircle(pinCenter, 10.0, corePaint);
        canvas.drawCircle(pinCenter, 10.0, whiteRing);
      } else {
        // Normal Spot Pin
        final dotPaint = Paint()..color = const Color(0xFF64748B);
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(pinCenter, 7.0, dotPaint);
        canvas.drawCircle(pinCenter, 7.0, borderPaint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant Campus2DBlueprintPainter oldDelegate) {
    return oldDelegate.selectedRoom.id != selectedRoom.id ||
        oldDelegate.floor != floor ||
        oldDelegate.rooms.length != rooms.length;
  }
}
