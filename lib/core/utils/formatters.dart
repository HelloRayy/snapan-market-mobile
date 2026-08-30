/// Core Formatter Utilities for Snapan Market
/// Aligned 100% with Web TypeScript Formatters (src/utils/formatters.ts)
library;

const List<String> kShortMonthsId = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

const List<String> kFullMonthsId = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

/// Data class holding both concise display string and full detailed timestamp
class SmartTimestampResult {
  final String display;
  final String full;

  const SmartTimestampResult({
    required this.display,
    required this.full,
  });

  @override
  String toString() => display;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmartTimestampResult &&
          runtimeType == other.runtimeType &&
          display == other.display &&
          full == other.full;

  @override
  int get hashCode => display.hashCode ^ full.hashCode;
}

/// Format timestamp adaptif bertingkat standar Threads & Twitter (Concise format):
/// - Legacy relative strings: "15m lalu" -> "15m", "2j lalu" -> "2j", "3h lalu" -> "3h"
/// - < 1 menit: "Baru saja"
/// - < 1 jam: "{m}m" (contoh: "15m")
/// - < 24 jam: "{j}j" (contoh: "2j")
/// - < 7 hari: "{h}h" (contoh: "3h")
/// - Tahun yang sama: "{tgl} {blnSingkat}" (contoh: "22 Agu", "6 Jul")
/// - Beda tahun: "{tgl} {blnSingkat} {yy}" (contoh: "22 Agu 25")
String formatSmartTimestamp(dynamic dateInput) {
  return formatSmartTimestampDetailed(dateInput).display;
}

/// Detailed smart timestamp calculation returning both concise [display] and [full] timestamp
SmartTimestampResult formatSmartTimestampDetailed(dynamic dateInput) {
  if (dateInput == null) {
    return const SmartTimestampResult(
      display: 'Baru saja',
      full: 'Baru saja',
    );
  }

  // 1. Handle String input (relative strings or ISO dates)
  if (dateInput is String) {
    final trimmed = dateInput.trim();
    if (trimmed.isEmpty ||
        trimmed.toLowerCase() == 'baru saja' ||
        trimmed.toLowerCase() == 'baru_saja') {
      return const SmartTimestampResult(
        display: 'Baru saja',
        full: 'Baru saja',
      );
    }

    // Clean legacy relative string formats like "15m lalu" -> "15m", "1j lalu" -> "1j", "2h lalu" -> "2h"
    final isRelative = trimmed.toLowerCase().endsWith('lalu') ||
        RegExp(r'^\d+\s*([mjhd]|menit|jam|hari)\s*(lalu)?$', caseSensitive: false)
            .hasMatch(trimmed);

    if (isRelative) {
      final cleaned = trimmed
          .replaceAll(RegExp(r'\s*lalu\s*', caseSensitive: false), '')
          .replaceAllMapped(
            RegExp(r'(\d+)\s*menit', caseSensitive: false),
            (match) => '${match[1]}m',
          )
          .replaceAllMapped(
            RegExp(r'(\d+)\s*jam', caseSensitive: false),
            (match) => '${match[1]}j',
          )
          .replaceAllMapped(
            RegExp(r'(\d+)\s*hari', caseSensitive: false),
            (match) => '${match[1]}h',
          )
          .replaceAllMapped(
            RegExp(r'(\d+)\s*d\b', caseSensitive: false),
            (match) => '${match[1]}h',
          )
          .replaceAll(RegExp(r'\s+'), '')
          .trim();

      if (cleaned.isNotEmpty) {
        return SmartTimestampResult(display: cleaned, full: trimmed);
      }
    }

    // Try parsing ISO date string
    final parsedDate = DateTime.tryParse(trimmed);
    if (parsedDate == null) {
      return SmartTimestampResult(display: trimmed, full: trimmed);
    }

    return _formatDateTime(parsedDate.toLocal());
  }

  // 2. Handle DateTime input
  if (dateInput is DateTime) {
    return _formatDateTime(dateInput.toLocal());
  }

  // 3. Handle integer timestamp input (milliseconds or seconds)
  if (dateInput is int) {
    final ms = dateInput < 10000000000 ? dateInput * 1000 : dateInput;
    return _formatDateTime(
      DateTime.fromMillisecondsSinceEpoch(ms).toLocal(),
    );
  }

  return SmartTimestampResult(
    display: dateInput.toString(),
    full: dateInput.toString(),
  );
}

SmartTimestampResult _formatDateTime(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  final diffSec = diff.inSeconds;
  final diffMin = diff.inMinutes;
  final diffHours = diff.inHours;
  final diffDays = diff.inDays;

  final day = date.day;
  final monthIdx = date.month - 1;
  final year = date.year;
  final currentYear = now.year;

  final safeMonthIdx = monthIdx.clamp(0, 11);
  final hoursStr = date.hour.toString().padLeft(2, '0');
  final minutesStr = date.minute.toString().padLeft(2, '0');
  final full =
      '$day ${kFullMonthsId[safeMonthIdx]} $year pukul $hoursStr:$minutesStr WIB';

  // 1. Kurang dari 1 menit
  if (diffSec < 60 && diffSec >= 0) {
    return SmartTimestampResult(display: 'Baru saja', full: full);
  }

  // 2. Kurang dari 1 jam -> "15m"
  if (diffMin < 60 && diffMin > 0) {
    return SmartTimestampResult(display: '${diffMin}m', full: full);
  }

  // 3. Kurang dari 24 jam -> "2j"
  if (diffHours < 24 && diffHours > 0) {
    return SmartTimestampResult(display: '${diffHours}j', full: full);
  }

  // 4. Kurang dari 7 hari -> "3h"
  if (diffDays < 7 && diffDays > 0) {
    return SmartTimestampResult(display: '${diffDays}h', full: full);
  }

  // 5. Tahun yang sama -> "22 Agu"
  if (year == currentYear) {
    return SmartTimestampResult(
      display: '$day ${kShortMonthsId[safeMonthIdx]}',
      full: full,
    );
  }

  // 6. Beda tahun -> "22 Agu 25"
  final shortYear = (year % 100).toString().padLeft(2, '0');
  return SmartTimestampResult(
    display: '$day ${kShortMonthsId[safeMonthIdx]} $shortYear',
    full: full,
  );
}

/// Format Angka ke Mata Uang Rupiah (IDR)
/// Example: 150000 -> "Rp 150.000"
String formatRupiah(num amount) {
  final intVal = amount.round();
  final isNegative = intVal < 0;
  final digits = intVal.abs().toString();

  final StringBuffer buffer = StringBuffer();
  final int len = digits.length;

  for (int i = 0; i < len; i++) {
    if (i > 0 && (len - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[i]);
  }

  final prefix = isNegative ? '-Rp ' : 'Rp ';
  return '$prefix$buffer';
}

/// Format Angka Besar menjadi Singkatan (misal: 1200 -> "1.2k", 1500000 -> "1.5M")
String formatCompactNumber(num number) {
  final double val = number.toDouble();
  if (val.abs() >= 1000000) {
    final formatted = (val / 1000000).toStringAsFixed(1);
    return '${formatted.replaceAll('.0', '')}M';
  } else if (val.abs() >= 1000) {
    final formatted = (val / 1000).toStringAsFixed(1);
    return '${formatted.replaceAll('.0', '')}k';
  }
  return number.toString();
}

/// Membersihkan emoji unicode dari string teks (misal judul produk/caption)
String stripEmojis(String? text) {
  if (text == null || text.isEmpty) return '';
  final emojiRegex = RegExp(
    r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
    unicode: true,
  );
  return text.replaceAll(emojiRegex, '').trim();
}

/// Mengubah nama lengkap menjadi username slug yang valid (lowercase, tanpa spasi)
/// Example: "Raditya Rayhan" -> "radityarayhan"
String toUsernameSlug(String? name, [String fallback = 'user']) {
  if (name == null || name.trim().isEmpty) return fallback;
  final clean = name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9_]'), '')
      .trim();
  return clean.isEmpty ? fallback : clean;
}

/// Static namespace wrapper for all formatter utilities
abstract final class AppFormatters {
  static String formatRupiah(num amount) => snapan_formatRupiah(amount);
  static String formatSmartTimestamp(dynamic dateInput) => snapan_formatSmartTimestamp(dateInput);
  static SmartTimestampResult formatSmartTimestampDetailed(dynamic dateInput) => snapan_formatSmartTimestampDetailed(dateInput);
  static String formatCompactNumber(num number) => snapan_formatCompactNumber(number);
  static String stripEmojis(String? text) => snapan_stripEmojis(text);
  static String toUsernameSlug(String? name, [String fallback = 'user']) => snapan_toUsernameSlug(name, fallback);
}

String snapan_formatRupiah(num amount) => formatRupiah(amount);
String snapan_formatSmartTimestamp(dynamic dateInput) => formatSmartTimestamp(dateInput);
SmartTimestampResult snapan_formatSmartTimestampDetailed(dynamic dateInput) => formatSmartTimestampDetailed(dateInput);
String snapan_formatCompactNumber(num number) => formatCompactNumber(number);
String snapan_stripEmojis(String? text) => stripEmojis(text);
String snapan_toUsernameSlug(String? name, [String fallback = 'user']) => toUsernameSlug(name, fallback);

