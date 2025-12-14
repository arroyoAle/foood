import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Storage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> getLocalFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName.json');
  }

  Future<Object> read(String fileName) async {
    try {
      final file = await getLocalFile(fileName);

      // Read the file
      final fileContents = await file.readAsString();

      return jsonDecode(fileContents) as Map<String, dynamic>;
    } catch (e) {
      // If encountering an error, return 0
      return <String, dynamic>{};
    }
  }

  Future<File> write(String fileName, Map<String, dynamic> data) async {
    final file = await getLocalFile(fileName);

    // Write the file
    String jsonStr = jsonEncode(data);
    return file.writeAsString(jsonStr);
  }

}