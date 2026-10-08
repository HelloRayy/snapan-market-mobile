import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:snapan_market/features/auth/models/auth_constants.dart';

class RegisteredStudent {
  final String nis;
  final String name;
  final String classGroup;

  const RegisteredStudent({
    required this.nis,
    required this.name,
    required this.classGroup,
  });

  factory RegisteredStudent.fromJson(Map<String, dynamic> json) {
    final rawClass = json['class_group']?.toString() ?? '';
    return RegisteredStudent(
      nis: json['nis']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      classGroup: AuthConstants.normalizeClassGroup(rawClass),
    );
  }

  Map<String, dynamic> toJson() => {
        'nis': nis,
        'name': name,
        'class_group': classGroup,
      };
}

/// Service to handle local lookup and offline demo verification of student NIS records
class StudentRegistryService {
  StudentRegistryService._();
  static final StudentRegistryService instance = StudentRegistryService._();

  List<RegisteredStudent> _students = [];
  bool _isLoaded = false;

  /// Ensure students dataset is loaded into memory
  Future<void> init() async {
    if (_isLoaded) return;
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/students_demo_11_pplg_2.json');
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is List) {
        _students = decoded
            .whereType<Map<String, dynamic>>()
            .map(RegisteredStudent.fromJson)
            .toList();
      }
      _isLoaded = true;
    } catch (_) {
      _students = [];
    }
  }

  /// Instant lookup by NIS
  RegisteredStudent? findByNis(String rawNis) {
    final clean = rawNis.trim();
    if (clean.isEmpty) return null;
    try {
      return _students.firstWhere(
        (s) => s.nis == clean,
      );
    } catch (_) {
      return null;
    }
  }

  /// Generates clean username from [first name + middle name], e.g.
  /// "Raditya Rayhan Yogiswara" -> "radityarayhan"
  static String generateSuggestedUsername(String fullName, {String? suffix}) {
    final parts = fullName
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();

    String base;
    if (parts.isEmpty) {
      base = 'user';
    } else if (parts.length == 1) {
      base = parts.first.replaceAll(RegExp(r'[^a-z0-9]'), '');
    } else {
      // First name + Middle name
      final first = parts[0].replaceAll(RegExp(r'[^a-z0-9]'), '');
      final middle = parts[1].replaceAll(RegExp(r'[^a-z0-9]'), '');
      base = '$first$middle';
    }

    if (base.isEmpty) base = 'user';
    if (suffix != null && suffix.isNotEmpty) {
      base = '$base$suffix';
    }
    return base;
  }

  /// Search matching students by query (NIS or Name)
  List<RegisteredStudent> searchStudents(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return [];
    return _students.where((s) {
      return s.nis.contains(clean) || s.name.toLowerCase().contains(clean);
    }).toList();
  }

  /// Find class group by NIS. Returns null if NIS is not found or empty.
  String? findClassByNis(String? rawNis) {
    if (rawNis == null) return null;
    final clean = rawNis.trim();
    if (clean.isEmpty) return null;
    final student = findByNis(clean);
    if (student != null && student.classGroup.trim().isNotEmpty) {
      return student.classGroup.trim();
    }
    return null;
  }

  /// Manually add or update a student in the in-memory cache
  void registerStudent(RegisteredStudent student) {
    final idx = _students.indexWhere((s) => s.nis == student.nis);
    if (idx >= 0) {
      _students[idx] = student;
    } else {
      _students.add(student);
    }
  }
}

