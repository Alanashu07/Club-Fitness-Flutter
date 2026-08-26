// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

const featuresDir = "lib/features";

void main() {
  print("👀 Watching for file creation inside lib/features …");

  final watcher = Directory(featuresDir).watch(recursive: true);

  Timer? debounce;

  watcher.listen((event) {
    if (event.type != FileSystemEvent.create &&
        event.type != FileSystemEvent.delete) {
      return;
    }
    if (!event.path.endsWith(".dart")) return;

    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 100), () {
      final featurePath = _getFeatureRoot(event.path);
      if (featurePath == null) return;

      print("⚡ File created: ${event.path}");
      print("📦 Updating export files for feature: ${p.basename(featurePath)}");
      processFeature(featurePath);
    });
  });
}

String? _getFeatureRoot(String filePath) {
  final parts = p.normalize(filePath).split(Platform.pathSeparator);

  final i = parts.indexOf("features");
  if (i == -1 || i + 1 >= parts.length) return null;

  return p.joinAll(parts.sublist(0, i + 2)); // lib/features/<feature>
}

Future<void> processFeature(String featurePath) async {
  final featureName = p.basename(featurePath);

  final folders = {
    "models": p.join(featurePath, "data", "models"),
    "entities": p.join(featurePath, "domain", "entities"),
    "usecases": p.join(featurePath, "domain", "usecase"),
    "screens": p.join(featurePath, "presentation", "screens"),
    "widgets": p.join(featurePath, "presentation", "widgets"),
  };

  final List<String> createdExports = [];

  for (final entry in folders.entries) {
    if (Directory(entry.value).existsSync()) {
      final fileName = "${featureName}_${entry.key}.dart";
      final fullPath = p.join(entry.value, fileName);

      await _createGroupedExports(
        folder: entry.value,
        exportFilePath: fullPath,
        featureName: featureName,
      );

      createdExports.add(fullPath);
    }
  }

  final baseExportPath = await _createBaseExport(featurePath, featureName);
  createdExports.add(baseExportPath);

  print("✅ Updated ${createdExports.length} export file(s):");
  for (final path in createdExports) {
    print("   📄 $path");
  }
  print("");
}

Future<void> _createGroupedExports({
  required String folder,
  required String exportFilePath,
  required String featureName,
}) async {
  final dir = Directory(folder);

  // Check if there are any subdirectories
  final hasSubfolders = dir.listSync().any((entity) => entity is Directory);

  // Get all dart files recursively (includes subfolders)
  final allFiles = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith(".dart"))
      .where((f) => f.path != exportFilePath) // Exclude self
      .toList();

  // Get relative paths from the export file's directory
  final relativeFiles = allFiles
      .map((f) => p.relative(f.path, from: folder).replaceAll("\\", "/"))
      .toList();

  // Only skip event/state if no subfolders and bloc exists in root
  final rootFiles = dir
      .listSync()
      .whereType<File>()
      .map((e) => p.basename(e.path))
      .where((e) => e.endsWith(".dart"))
      .where((e) => e != p.basename(exportFilePath))
      .toList();

  final hasBloc =
      !hasSubfolders && rootFiles.any((f) => f.endsWith("bloc.dart"));

  final filtered = relativeFiles.where((path) {
    if (!hasBloc) return true;

    // Only skip event/state files in the root directory
    final fileName = p.basename(path);
    final isInRoot = !path.contains('/') && !path.contains('\\');

    if (isInRoot &&
        (fileName.endsWith("event.dart") || fileName.endsWith("state.dart"))) {
      return false;
    }

    return true;
  }).toList();

  final lines = filtered.map((f) => "export '$f';").toList()..sort();

  await _writeFile(exportFilePath, lines);
}

Future<String> _createBaseExport(String featurePath, String featureName) async {
  final path = p.join(featurePath, "$featureName.dart");

  final Set<String> exports = {};

  // Process all directories under the feature
  await _processDirectory(
    directory: featurePath,
    featurePath: featurePath,
    featureName: featureName,
    exports: exports,
    isRoot: true,
  );

  final sortedExports = exports.toList()..sort();

  await _writeFile(path, sortedExports);

  return path;
}

Future<void> _processDirectory({
  required String directory,
  required String featurePath,
  required String featureName,
  required Set<String> exports,
  required bool isRoot,
}) async {
  final dir = Directory(directory);
  if (!dir.existsSync()) return;

  final dirName = p.basename(directory);

  // Determine if this directory has an export file
  final exportFileName = _getExportFileName(directory, featureName);
  final exportFilePath =
      exportFileName != null ? p.join(directory, exportFileName) : null;

  final hasExportFile =
      exportFilePath != null && File(exportFilePath).existsSync();

  // Check if there are subdirectories
  final subdirs = dir.listSync().whereType<Directory>().toList();

  final hasSubfolders = subdirs.isNotEmpty;

  // Decision logic for this directory
  if (hasExportFile && !hasSubfolders) {
    // Case 1: Has export file and no subfolders → export only the export file
    final relative =
        p.relative(exportFilePath, from: featurePath).replaceAll("\\", "/");
    exports.add("export '$relative';");
  } else {
    // Case 2: No export file OR has subfolders → export all files

    // Get all dart files in current directory (non-recursive)
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith(".dart"))
        .where((f) =>
            !isRoot ||
            p.basename(f.path) !=
                "$featureName.dart") // Skip base export in root
        .toList();

    // Handle bloc directories specially
    final isBlocDir = dirName == "bloc";

    for (final file in files) {
      final fileName = p.basename(file.path);

      // Skip export files (they'll be replaced by their contents or handled separately)
      if (exportFileName != null && fileName == exportFileName) continue;

      // Skip event/state files in non-bloc directories if bloc exists
      if (!isBlocDir && !hasSubfolders) {
        final hasBlocFile =
            files.any((f) => p.basename(f.path).endsWith("bloc.dart"));
        if (hasBlocFile &&
            (fileName.endsWith("event.dart") ||
                fileName.endsWith("state.dart"))) {
          continue;
        }
      }

      final relative =
          p.relative(file.path, from: featurePath).replaceAll("\\", "/");
      exports.add("export '$relative';");
    }

    // Process subdirectories
    for (final subdir in subdirs) {
      // Special handling for bloc folder: only export bloc files from each subfolder
      if (isBlocDir) {
        await _processBlocSubfolder(
          subfolder: subdir.path,
          featurePath: featurePath,
          exports: exports,
        );
      } else {
        await _processDirectory(
          directory: subdir.path,
          featurePath: featurePath,
          featureName: featureName,
          exports: exports,
          isRoot: false,
        );
      }
    }
  }
}

Future<void> _processBlocSubfolder({
  required String subfolder,
  required String featurePath,
  required Set<String> exports,
}) async {
  final dir = Directory(subfolder);
  if (!dir.existsSync()) return;

  // Only export bloc files from bloc subfolders
  final blocFiles = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith("bloc.dart"))
      .toList();

  for (final file in blocFiles) {
    final relative =
        p.relative(file.path, from: featurePath).replaceAll("\\", "/");
    exports.add("export '$relative';");
  }
}

String? _getExportFileName(String directory, String featureName) {
  final dirName = p.basename(directory);

  // Map directory names to their export file names
  final exportMap = {
    "models": "${featureName}_models.dart",
    "entities": "${featureName}_entities.dart",
    "usecase": "${featureName}_usecases.dart",
    "screens": "${featureName}_screens.dart",
    "widgets": "${featureName}_widgets.dart",
  };

  return exportMap[dirName];
}

Future<void> _writeFile(String path, List<String> lines) async {
  final file = File(path);
  await file.create(recursive: true);
  await file.writeAsString("${lines.join("\n")}\n");
}
