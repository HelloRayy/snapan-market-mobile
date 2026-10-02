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

  /// Parses raw class string (e.g. "X PPLG 1", "x-pplg-1") into components (grade, major, classNum)
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
      for (final g in gradeOptions) {
        if (upper == g.toUpperCase()) grade = g;
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
