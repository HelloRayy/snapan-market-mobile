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

    test('Validates username constraints for username update', () {
      bool isValidUsername(String input) {
        final clean = input.trim().toLowerCase().replaceFirst(RegExp(r'^@'), '');
        if (clean.length < 3 || clean.length > 20) return false;
        return RegExp(r'^[a-z0-9_]+$').hasMatch(clean);
      }

      expect(isValidUsername('radityaray'), isTrue);
      expect(isValidUsername('aida_putri'), isTrue);
      expect(isValidUsername('user_123'), isTrue);
      expect(isValidUsername('ab'), isFalse); // Too short (< 3)
      expect(isValidUsername('very_long_username_exceeding_twenty'), isFalse); // Too long (> 20)
      expect(isValidUsername('user name'), isFalse); // Has space
      expect(isValidUsername('user@name'), isFalse); // Has invalid char
    });

    test('Generates complete login candidates for NIS and changed username', () {
      List<String> getCandidateEmails(String input, {String? registeredUsername, String? registeredNis}) {
        final clean = input.trim().toLowerCase().replaceAll('@', '');
        final candidates = <String>[];
        if (input.contains('@') && input.contains('.')) {
          candidates.add(input.trim().toLowerCase());
        } else if (RegExp(r'^\d+$').hasMatch(clean)) {
          if (registeredUsername != null && registeredUsername.isNotEmpty) {
            candidates.add('$registeredUsername@snapan.id');
          }
          if (!candidates.contains('$clean@snapan.id')) {
            candidates.add('$clean@snapan.id');
          }
        } else {
          candidates.add('$clean@snapan.id');
          if (registeredNis != null && registeredNis.isNotEmpty) {
            final nisEmail = '$registeredNis@snapan.id';
            if (!candidates.contains(nisEmail)) {
              candidates.add(nisEmail);
            }
          }
        }
        return candidates;
      }

      // NIS login with registered username
      final nisCandidates = getCandidateEmails('11840', registeredUsername: 'radityaray');
      expect(nisCandidates, contains('radityaray@snapan.id'));
      expect(nisCandidates, contains('11840@snapan.id'));

      // Username login with known NIS fallback
      final usernameCandidates = getCandidateEmails('radityaray', registeredNis: '11840');
      expect(usernameCandidates, contains('radityaray@snapan.id'));
      expect(usernameCandidates, contains('11840@snapan.id'));
    });
  });
}
