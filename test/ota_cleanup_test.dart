import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OTA Cleanup Unit Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('ota_cleanup_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Identifies and deletes only .apk files while preserving other files', () async {
      final apk1 = File('${tempDir.path}/Snaps-v1.0.11.apk');
      final apk2 = File('${tempDir.path}/snaps_app_update.apk');
      final otherFile = File('${tempDir.path}/user_data.json');
      final nestedDir = Directory('${tempDir.path}/images');

      await apk1.writeAsString('fake apk binary content 1');
      await apk2.writeAsString('fake apk binary content 2');
      await otherFile.writeAsString('{"theme": "dark"}');
      await nestedDir.create();
      final innerPhoto = File('${nestedDir.path}/avatar.png');
      await innerPhoto.writeAsString('photo bytes');

      expect(await apk1.exists(), isTrue);
      expect(await apk2.exists(), isTrue);
      expect(await otherFile.exists(), isTrue);
      expect(await innerPhoto.exists(), isTrue);

      // Simulate cleanup logic on the directory
      final entities = tempDir.listSync();
      int deleted = 0;
      for (final entity in entities) {
        if (entity is File && entity.path.toLowerCase().endsWith('.apk')) {
          await entity.delete();
          deleted++;
        }
      }

      expect(deleted, 2);
      expect(await apk1.exists(), isFalse);
      expect(await apk2.exists(), isFalse);
      expect(await otherFile.exists(), isTrue);
      expect(await innerPhoto.exists(), isTrue);
    });
  });
}
