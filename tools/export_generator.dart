// ignore_for_file: avoid_print
import 'dart:io';

import 'package:path/path.dart' as p;

Future<void> generateExportFile(
    String folderPath, String exportFileName) async {
  final dir = Directory(folderPath);

  if (!await dir.exists()) {
    print('❌ Folder does not exist: $folderPath');
    return;
  }

  final buffer = StringBuffer();
  buffer.writeln('// GENERATED EXPORT FILE');
  buffer.writeln('// Exports from $folderPath\n');

  /// Collects files in the current directory, then recurses into subfolders
  void processDirectory(Directory currentDir) {
    final entities = currentDir.listSync(recursive: false);

    // 1. Handle files first
    final files = entities
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();

    for (var file in files) {
      final relativePath = p.relative(file.path, from: folderPath);
      final normalizedPath =
          relativePath.replaceAll(r'\', '/'); // ✅ Fix for Windows
      if (p.basename(file.path) == exportFileName) continue; // skip itself
      buffer.writeln("export '$normalizedPath';");
    }

    // 2. Handle subfolders
    final dirs = entities.whereType<Directory>().toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    for (var subDir in dirs) {
      processDirectory(subDir);
    }
  }

  processDirectory(dir);

  final exportFilePath = p.join(folderPath, exportFileName);
  final exportFile = File(exportFilePath);
  await exportFile.writeAsString(buffer.toString());

  print('✅ Export file created: ${p.normalize(exportFilePath)}');
}

void main(List<String> args) async {
  if (args.length < 2) {
    print(
        'Usage: dart tools/export_generator.dart <folder_path> <export_file_name.dart>');
    return;
  }

  final folderPath = args[0];
  final exportFileName =
      args[1].endsWith('.dart') ? args[1] : '${args[1]}.dart';

  await generateExportFile(folderPath, exportFileName);
}
