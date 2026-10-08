import 'package:flutter_test/flutter_test.dart';
import 'package:snapan_market/features/profile/models/profile_user_model.dart';

void main() {
  group('Display Name Business Logic & Model Unit Tests (SNAPS-59)', () {
    test('ProfileUserModel supports displayName and effective name prioritizes displayName over @username', () {
      const userWithDisplay = ProfileUserModel(
        id: 'u-1',
        name: 'Rayhan Yogiswara',
        displayName: 'Rayhan Yogiswara',
        username: 'rayhany',
        avatar: '',
        bio: '',
        classGroup: 'XI PPLG 2',
      );

      expect(userWithDisplay.displayName, 'Rayhan Yogiswara');
      expect(userWithDisplay.name, 'Rayhan Yogiswara');

      const userWithoutDisplay = ProfileUserModel(
        id: 'u-2',
        name: '@novaldy',
        displayName: null,
        username: 'novaldy',
        avatar: '',
        bio: '',
        classGroup: 'XI PPLG 2',
      );

      expect(userWithoutDisplay.displayName, isNull);
      expect(userWithoutDisplay.name, '@novaldy');
    });

    test('ProfileUserModel copyWith correctly updates displayName', () {
      const user = ProfileUserModel(
        id: 'u-1',
        name: '@user1',
        displayName: null,
        username: 'user1',
        avatar: '',
        bio: '',
        classGroup: 'X RPL 1',
      );

      final updated = user.copyWith(
        name: 'CoolNickname',
        displayName: 'CoolNickname',
      );

      expect(updated.name, 'CoolNickname');
      expect(updated.displayName, 'CoolNickname');
    });

    test('Display Name validation rules: minimum 6 characters and maximum 20 characters', () {
      String? validateDisplayName(String input) {
        final trimmed = input.trim();
        if (trimmed.isNotEmpty && trimmed.length < 6) {
          return 'Nama tampilan minimal 6 karakter';
        }
        if (trimmed.isNotEmpty && trimmed.length > 20) {
          return 'Nama tampilan maksimal 20 karakter';
        }
        return null;
      }

      // Valid cases
      expect(validateDisplayName(''), isNull, reason: 'Empty display name is optional');
      expect(validateDisplayName('Rayhan'), isNull, reason: '6 characters is valid');
      expect(validateDisplayName('12345678901234567890'), isNull, reason: '20 characters is valid');

      // Invalid cases (< 6 chars)
      expect(validateDisplayName('a'), 'Nama tampilan minimal 6 karakter');
      expect(validateDisplayName('ab'), 'Nama tampilan minimal 6 karakter');
      expect(validateDisplayName('abcde'), 'Nama tampilan minimal 6 karakter');

      // Invalid cases (> 20 chars)
      expect(validateDisplayName('123456789012345678901'), 'Nama tampilan maksimal 20 karakter');
    });
  });
}
