import 'package:flutter_test/flutter_test.dart';
import 'package:snapan_market/core/services/student_registry_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StudentRegistryService Tests', () {
    test('JSON parsing and RegisteredStudent model mapping', () {
      final jsonSample = {
        'nis': '11816',
        'name': 'AIDA DWI RIANA PUTRI',
        'class_group': '11 PPLG 2',
      };

      final student = RegisteredStudent.fromJson(jsonSample);
      expect(student.nis, '11816');
      expect(student.name, 'AIDA DWI RIANA PUTRI');
      expect(student.classGroup, '11 PPLG 2');
    });

    test('Student lookup and search functionality', () async {
      await StudentRegistryService.instance.init();

      final student = StudentRegistryService.instance.findByNis('11816');
      expect(student, isNotNull);
      expect(student!.name, 'AIDA DWI RIANA PUTRI');
      expect(student.classGroup, '11 PPLG 2');

      final notFound = StudentRegistryService.instance.findByNis('99999');
      expect(notFound, isNull);

      final searchResults = StudentRegistryService.instance.searchStudents('AIDA');
      expect(searchResults.isNotEmpty, isTrue);
      expect(searchResults.first.nis, '11816');

      // Test findClassByNis
      expect(StudentRegistryService.instance.findClassByNis('11816'), '11 PPLG 2');
      expect(StudentRegistryService.instance.findClassByNis('99999'), isNull);
      expect(StudentRegistryService.instance.findClassByNis(null), isNull);
      expect(StudentRegistryService.instance.findClassByNis(''), isNull);
    });

    test('registerStudent manually adds student to local registry', () {
      StudentRegistryService.instance.registerStudent(const RegisteredStudent(
        nis: '12345',
        name: 'Siswa Percobaan',
        classGroup: '10 PPLG 1',
      ));

      expect(StudentRegistryService.instance.findClassByNis('12345'), '10 PPLG 1');
      expect(StudentRegistryService.instance.findByNis('12345')?.name, 'Siswa Percobaan');
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
