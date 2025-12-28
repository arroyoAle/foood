import 'dart:io';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foood/helpers/storage.dart';

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String _tempPath;
  final String mockAppDocumentsPath = Directory.systemTemp.path;
  FakePathProviderPlatform(this._tempPath);

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return mockAppDocumentsPath;
  }

  Future<String?> getApplicationDocumentsDirectory() async {
    return _tempPath;
  }
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Storage', () {
    late Storage storage;
    late Directory tempDir;
    const testFileName = 'test_file.json';
    const Map<String, dynamic> testFileContents = {
      'name': 'Test Item',
      'quantity': 5,
      'isComplete': false,
    };

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('test_dir');
      PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);
      storage = Storage();
    });

    tearDownAll(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Test json file read and write', () async {
      await storage.write(testFileName, testFileContents);
      final Object fileContents = await storage.read(testFileName);

      expect(fileContents, isNotEmpty);
      expect(fileContents, testFileContents);
    });

    test('Test read cannot find file returns empty json', () async {
      final Object fileContents = await storage.read('wrong_file_name');

      expect(fileContents, isEmpty);
    });
  });
}