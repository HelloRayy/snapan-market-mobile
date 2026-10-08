import 'package:flutter_test/flutter_test.dart';
import 'package:snapan_market/core/services/student_registry_service.dart';
import 'package:snapan_market/features/auth/models/auth_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StudentRegistryService Tests', () {
    test('JSON parsing and RegisteredStudent model mapping normalizes class_group to Roman', () {
      final jsonSample = {
        'nis': '11816',
        'name': 'AIDA DWI RIANA PUTRI',
        'class_group': '11 PPLG 2',
      };

      final student = RegisteredStudent.fromJson(jsonSample);
      expect(student.nis, '11816');
      expect(student.name, 'AIDA DWI RIANA PUTRI');
      expect(student.classGroup, 'XI PPLG 2');
    });

    test('Student lookup and search functionality', () async {
      await StudentRegistryService.instance.init();

      final student = StudentRegistryService.instance.findByNis('11816');
      expect(student, isNotNull);
      expect(student!.name, 'AIDA DWI RIANA PUTRI');
      expect(student.classGroup, 'XI PPLG 2');

      final notFound = StudentRegistryService.instance.findByNis('99999');
      expect(notFound, isNull);

      final searchResults = StudentRegistryService.instance.searchStudents('AIDA');
      expect(searchResults.isNotEmpty, isTrue);
      expect(searchResults.first.nis, '11816');

      // Test findClassByNis
      expect(StudentRegistryService.instance.findClassByNis('11816'), 'XI PPLG 2');
      expect(StudentRegistryService.instance.findClassByNis('99999'), isNull);
      expect(StudentRegistryService.instance.findClassByNis(null), isNull);
      expect(StudentRegistryService.instance.findClassByNis(''), isNull);
    });

    test('registerStudent manually adds student to local registry and preserves Roman format', () {
      StudentRegistryService.instance.registerStudent(const RegisteredStudent(
        nis: '12345',
        name: 'Siswa Percobaan',
        classGroup: 'X PPLG 1',
      ));

      expect(StudentRegistryService.instance.findClassByNis('12345'), 'X PPLG 1');
      expect(StudentRegistryService.instance.findByNis('12345')?.name, 'Siswa Percobaan');
    });

    test('AuthConstants.normalizeClassGroup normalizes various inputs to Roman format', () {
      expect(AuthConstants.normalizeClassGroup('11 pplg 2'), 'XI PPLG 2');
      expect(AuthConstants.normalizeClassGroup('11 PPLG 2'), 'XI PPLG 2');
      expect(AuthConstants.normalizeClassGroup('XI PPLG 2'), 'XI PPLG 2');
      expect(AuthConstants.normalizeClassGroup('10 dkv 1'), 'X DKV 1');
      expect(AuthConstants.normalizeClassGroup('12 tjkt 3'), 'XII TJKT 3');
    });

    test('generateSuggestedUsername creates first+middle name clean handle', () {
      final username1 = StudentRegistryService.generateSuggestedUsername('Raditya Rayhan Yogiswara');
      expect(username1, 'radityarayhan');

      final username2 = StudentRegistryService.generateSuggestedUsername('AIDA DWI RIANA PUTRI');
      expect(username2, 'aidadwi');

      final usernameWithSuffix = StudentRegistryService.generateSuggestedUsername('Raditya Rayhan Yogiswara', suffix: '_88');
      expect(usernameWithSuffix, 'radityarayhan_88');
    });
  });
}
