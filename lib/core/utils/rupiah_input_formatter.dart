import 'package:flutter/services.dart';

/// Formatter untuk input nominal harga Rupiah Indonesia (contoh: 123.123.123)
/// Otomatis memformat angka dengan titik pemisah ribuan saat pengguna mengetik.
class RupiahInputFormatter extends TextInputFormatter {
  final bool includePrefix;

  const RupiahInputFormatter({this.includePrefix = false});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. Ambil hanya angka (digits)
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // 2. Batasi maksimal 13 digit (sampai Triliun)
    final safeDigits = digits.length > 13 ? digits.substring(0, 13) : digits;

    // 3. Format ribuan dengan titik (contoh: 123.123.123)
    final StringBuffer buffer = StringBuffer();
    final int len = safeDigits.length;

    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(safeDigits[i]);
    }

    String formatted = buffer.toString();
    if (includePrefix) {
      formatted = 'Rp $formatted';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Helper untuk mengurai integer murni dari string harga terformat
  static int parsePrice(String text) {
    final clean = text.replaceAll(RegExp(r'\D'), '');
    return int.tryParse(clean) ?? 0;
  }
}
