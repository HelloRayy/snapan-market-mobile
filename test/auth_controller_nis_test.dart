import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Auth Login & NIS Resolution Logic Tests', () {
    test('Resolves NIS and username formats properly', () {
      String resolveLoginEmail(String username, {String? registeredUsername}) {
        final cleanInput = username.trim().toLowerCase().replaceAll('@', '');
        if (username.contains('@') && username.contains('.')) {
          return username.trim().toLowerCase();
        } else if (RegExp(r'^\d+$').hasMatch(cleanInput)) {
          if (registeredUsername != null && registeredUsername.isNotEmpty) {
            return '$registeredUsername@snapan.id';
          }
          return '$cleanInput@snapan.id';
        } else {
          return '$cleanInput@snapan.id';
        }
      }

      // Test Case 1: Standard Username
      expect(resolveLoginEmail('rayhan'), 'rayhan@snapan.id');
      expect(resolveLoginEmail('@rayhan'), 'rayhan@snapan.id');

      // Test Case 2: Direct Full Email
      expect(resolveLoginEmail('rayhan@gmail.com'), 'rayhan@gmail.com');

      // Test Case 3: 5-digit NIS with matched registered username
      expect(resolveLoginEmail('11816', registeredUsername: 'aida_putri'), 'aida_putri@snapan.id');

      // Test Case 4: 5-digit NIS without profile found (fallback to NIS email)
      expect(resolveLoginEmail('11816'), '11816@snapan.id');
    });

    test('Validates NIS format correctly', () {
      bool isNisFormat(String input) {
        final clean = input.trim().toLowerCase().replaceAll('@', '');
        return RegExp(r'^\d{4,8}$').hasMatch(clean);
      }

      expect(isNisFormat('11816'), isTrue);
      expect(isNisFormat('10293'), isTrue);
      expect(isNisFormat('user123'), isFalse);
      expect(isNisFormat('rayhan'), isFalse);
    });
  });
}
