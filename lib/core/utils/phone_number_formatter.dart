import 'package:flutter/services.dart';

/// Formatter untuk nomor HP Indonesia (xxx-xxxx-xxxx)
/// Secara otomatis membuang awalan 0 atau 62 dan membatasi maksimal 12 digit lokal.
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. Ambil hanya angka (digits)
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // 2. Hapus awalan 0 atau 62 jika diketik atau di-paste
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    } else if (digits.startsWith('62')) {
      digits = digits.substring(2);
    }

    // 3. Batasi maksimal 12 digit
    if (digits.length > 12) {
      digits = digits.substring(0, 12);
    }

    // 4. Format dengan tanda strip: xxx-xxxx-xxxx
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 7) {
        buffer.write('-');
      }
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
