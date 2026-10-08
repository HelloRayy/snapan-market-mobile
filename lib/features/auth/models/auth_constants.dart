class AuthConstants {
  // Pilihan Kelas SMKN 8
  static const List<String> gradeOptions = ['X', 'XI', 'XII'];

  // Pilihan Jurusan SMKN 8 (Urut Abjad)
  static const List<String> majorOptions = [
    'DKV',
    'LK',
    'PPLG',
    'PS',
    'TJKT',
  ];

  // Pilihan Nomor Kelas SMKN 8
  static const List<String> classNumOptions = ['1', '2', '3'];

  /// Normalizes any raw class string to standard Roman format (e.g. "11 pplg 2" -> "XI PPLG 2")
  static String normalizeClassGroup(String rawClassGroup) {
    final parsed = parseClassGroup(rawClassGroup);
    if (parsed.grade != null && parsed.major != null && parsed.classNum != null) {
      return '${parsed.grade} ${parsed.major} ${parsed.classNum}';
    }
    return rawClassGroup.trim();
  }

  /// Parses raw class string (e.g. "X PPLG 1", "11 pplg 2", "x-pplg-1") into components (grade, major, classNum)
  static ({String? grade, String? major, String? classNum}) parseClassGroup(String rawClassGroup) {
    String? grade;
    String? major;
    String? classNum;

    final tokens = rawClassGroup
        .trim()
        .split(RegExp(r'[\s\-_/]+'))
        .where((t) => t.isNotEmpty);

    for (final token in tokens) {
      final upper = token.toUpperCase();

      // Support both Roman ('X', 'XI', 'XII') and Arabic numbers ('10', '11', '12')
      if (upper == '10' || upper == 'X') {
        grade = 'X';
      } else if (upper == '11' || upper == 'XI') {
        grade = 'XI';
      } else if (upper == '12' || upper == 'XII') {
        grade = 'XII';
      }

      for (final m in majorOptions) {
        if (upper == m.toUpperCase()) major = m;
      }
      for (final num in classNumOptions) {
        if (token == num) classNum = num;
      }
    }

    return (grade: grade, major: major, classNum: classNum);
  }
}
