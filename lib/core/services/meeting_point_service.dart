import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snapan_market/features/map/models/campus_map_models.dart';

class MeetingPointService {
  final SupabaseClient _client;

  MeetingPointService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  /// Fetches active school meeting points from Supabase `school_meeting_points`.
  /// Falls back to static `kCampusRooms` if the database is offline or empty.
  Future<List<CampusRoom>> fetchMeetingPoints() async {
    try {
      final response = await _client
          .from('school_meeting_points')
          .select()
          .eq('is_active', true)
          .order('floor', ascending: true)
          .order('name', ascending: true);

      final List<dynamic> rows = response as List<dynamic>;
      if (rows.isEmpty) {
        return kCampusRooms;
      }

      return rows.map<CampusRoom>((row) {
        final map = row as Map<String, dynamic>;
        final String id = map['id']?.toString() ?? UniqueKey().toString();
        final String name = map['name']?.toString() ?? 'Titik Temu COD';
        final int floor = (map['floor'] as num?)?.toInt() ?? 1;
        final String areaCategory = map['area_category']?.toString() ?? 'Lainnya';
        final String description = map['description']?.toString() ?? '';
        final double rawX = (map['coordinates_x'] as num?)?.toDouble() ?? 50.0;
        final double rawY = (map['coordinates_y'] as num?)?.toDouble() ?? 50.0;

        // Coordinates in admin dashboard are percentages (0 - 100)
        // Blueprint canvas dimensions: width 1150, height 880
        final double canvasX = (rawX > 100 ? rawX : (rawX / 100.0) * 1150.0).clamp(50.0, 1100.0);
        final double canvasY = (rawY > 100 ? rawY : (rawY / 100.0) * 880.0).clamp(50.0, 830.0);

        // Normalize category key for filtering and icons
        final String catKey = _normalizeCategoryKey(areaCategory);
        final String catLabel = _normalizeCategoryLabel(areaCategory);

        return CampusRoom(
          id: id,
          name: name,
          code: _generateCode(name),
          buildingName: 'Lantai $floor • Area SMKN 8',
          floor: floor,
          category: catKey,
          categoryLabel: catLabel,
          description: description.isNotEmpty
              ? description
              : 'Titik temu resmi COD SMKN 8 Semarang yang dikelola oleh admin sekolah.',
          hint: 'Lokasi di Lantai $floor, koordinat area terverifikasi.',
          pinPosition: Offset(canvasX, canvasY),
          isPopularCodSpot: catKey == 'canteen' || name.toLowerCase().contains('kantin'),
        );
      }).toList();
    } catch (e) {
      debugPrint('Warning: Gagal memuat titik temu COD dari database: $e. Menggunakan fallback offline.');
      return kCampusRooms;
    }
  }

  String _normalizeCategoryKey(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('kantin') || lower.contains('canteen') || lower.contains('makan')) {
      return 'canteen';
    }
    if (lower.contains('lab') || lower.contains('bengkel') || lower.contains('rpl') || lower.contains('dkv')) {
      return 'lab';
    }
    if (lower.contains('lobi') || lower.contains('lobby') || lower.contains('depan') || lower.contains('satpam')) {
      return 'lobby';
    }
    if (lower.contains('lapangan') || lower.contains('gazebo') || lower.contains('taman') || lower.contains('outdoor') || lower.contains('selasar')) {
      return 'outdoor';
    }
    if (lower.contains('aula') || lower.contains('perpus') || lower.contains('facility')) {
      return 'facility';
    }
    return 'outdoor';
  }

  String _normalizeCategoryLabel(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('kantin') || lower.contains('canteen')) return 'Kantin & Makanan';
    if (lower.contains('lab') || lower.contains('bengkel')) return 'Laboratorium / Bengkel';
    if (lower.contains('lobi') || lower.contains('lobby')) return 'Lobi & Informasi';
    if (lower.contains('outdoor') || lower.contains('lapangan') || lower.contains('gazebo') || lower.contains('selasar')) return 'Area Terbuka & Selasar';
    if (lower.contains('aula')) return 'Aula & Pertemuan';
    if (lower.contains('perpus')) return 'Perpustakaan';
    return raw;
  }

  String _generateCode(String name) {
    final clean = name.trim().toUpperCase();
    if (clean.length <= 10) return clean;
    final words = clean.split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return words.take(3).map((w) => w.isNotEmpty ? w[0] : '').join();
    }
    return clean.substring(0, 10);
  }
}
