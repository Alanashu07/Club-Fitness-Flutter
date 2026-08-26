//ignore_for_file: avoid_print

import 'dart:io';

void main() async {
  // 🔴 Set your folder path here
  const String folderPath = 'lib/core/json';

  final directory = Directory(folderPath);

  if (!await directory.exists()) {
    print('Folder does not exist.');
    return;
  }

  final entities = directory.listSync(recursive: false);

  for (var entity in entities) {
    if (entity is File) {
      try {
        entity.deleteSync();
        print('Deleted file: ${entity.path}');
      } catch (e) {
        print('Failed to delete ${entity.path}: $e');
      }
    }
  }

  print('Done deleting files.');
}
