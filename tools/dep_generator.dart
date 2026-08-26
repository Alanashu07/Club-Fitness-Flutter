// ignore_for_file: avoid_print

import 'dart:io';

import 'package:path/path.dart' as p;

// --- Configuration ---
const String dependencyInjectionFilePath = 'lib/di.dart';
// Folders within a feature to specifically include for DI
const Map<String, List<String>> foldersToScan = {
  'data': ['data_source', 'repository'],
  'domain': ['repository', 'usecase', 'usecases'], // 'usecases' as alternative
};
const List<String> excludedSubFolders = ['models', 'entities', 'presentation'];

// --- End Configuration ---

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart run tools/dep_generator.dart <feature_name>');
    print('Example: dart run tools/dep_generator.dart auth');
    exit(1);
  }

  final featureName = args[0];
  final featurePath = 'lib/features/$featureName';
  final featureDir = Directory(featurePath);

  if (!featureDir.existsSync()) {
    print('❌ Feature directory not found: $featurePath');
    exit(1);
  }

  // Extract a feature name from the path for the function name
  // e.g., lib/features/interior_design -> InteriorDesign
  String featureNameForFunc = p.basename(featurePath);
  if (featureNameForFunc == 'lib' || featureNameForFunc == 'features') {
    // a bit more robust if they pass a deeper part of the path by mistake
    List<String> pathSegments = p.split(featurePath);
    if (pathSegments.length > 2 &&
        pathSegments[pathSegments.length - 2] == 'features') {
      featureNameForFunc = pathSegments.last;
    } else {
      featureNameForFunc = "UnknownFeature"; // Fallback
    }
  }
  featureNameForFunc = _capitalizeFirstLetter(_toCamelCase(featureNameForFunc));

  print(
    '🔍 Analyzing feature at: $featurePath (Function Prefix: $featureNameForFunc)',
  );

  final diFile = File(dependencyInjectionFilePath);
  if (!diFile.existsSync()) {
    print(
      '❌ Dependency injection file not found: $dependencyInjectionFilePath',
    );
    exit(1);
  }

  final List<Map<String, String>> discoveredClasses = [];

  // Traverse data, domain folders
  for (var layer in ['data', 'domain']) {
    final layerPath = p.join(featurePath, layer);
    final layerDir = Directory(layerPath);

    if (layerDir.existsSync() && foldersToScan.containsKey(layer)) {
      for (var subFolderName in foldersToScan[layer]!) {
        final subFolderPath = p.join(layerPath, subFolderName);
        final subFolderDir = Directory(subFolderPath);
        if (subFolderDir.existsSync()) {
          print('  📂 Scanning: $subFolderPath');
          _scanDirectoryForClasses(subFolderDir, discoveredClasses);
        } else {
          // It's okay if 'usecase' or 'usecases' doesn't exist, for example.
          if (subFolderName == 'usecases' &&
              !Directory(p.join(layerPath, 'usecase')).existsSync()) {
            // only print if both usecase and usecases are missing
          } else if (subFolderName != 'usecases') {
            print('  ⚠️ Subfolder not found, skipping: $subFolderPath');
          }
        }
      }
    }
  }

  if (discoveredClasses.isEmpty) {
    print('🤷 No classes found to register for feature path "$featurePath".');
    print('   Make sure your files are in the expected subfolders:');
    foldersToScan.forEach((layer, subfolders) {
      for (var sub in subfolders) {
        print('     - $layer/$sub/');
      }
    });
    exit(0);
  }

  print('\n✅ Found ${discoveredClasses.length} classes:');
  final allClassNames = discoveredClasses.map((c) => c['className']!).toList();
  for (var c in discoveredClasses) {
    print(
      '  - ${c['className']} (from ${c['importPath']}) - type: ${c['type']}',
    );
  }

  final diFunctionContent = _generateDiFunction(
    featureNameForFunc,
    discoveredClasses,
    allClassNames,
  );
  final diFunctionName =
      '_init${_capitalizeFirstLetter(featureNameForFunc)}Dep';

  String currentDiFileContent = diFile.readAsStringSync();

  if (currentDiFileContent.contains('void $diFunctionName() {')) {
    print(
      '\n⚠️ Function $diFunctionName already exists. Replacing its content.',
    );
    final startTag = '// START OF $diFunctionName';
    final endTag = '// END OF $diFunctionName';
    final startIndex = currentDiFileContent.indexOf(startTag);
    final endIndex = currentDiFileContent.indexOf(endTag);

    if (startIndex != -1 && endIndex != -1 && startIndex < endIndex) {
      currentDiFileContent =
          currentDiFileContent.substring(0, startIndex) +
          diFunctionContent +
          currentDiFileContent.substring(endIndex + endTag.length);
    } else {
      print(
        '   Could not find start/end tags for $diFunctionName. Appending new function instead.',
      );
      currentDiFileContent = _appendFunctionToDiFile(
        currentDiFileContent,
        diFunctionContent,
      );
    }
  } else {
    print(
      '\n✨ Adding new function $diFunctionName to $dependencyInjectionFilePath.',
    );
    currentDiFileContent = _appendFunctionToDiFile(
      currentDiFileContent,
      diFunctionContent,
    );
  }

  try {
    diFile.writeAsStringSync(currentDiFileContent);
    print('\n✅ Successfully updated $dependencyInjectionFilePath!');
    print(
      '   Don\'t forget to call $diFunctionName(); in your main initDep() function.',
    );
  } catch (e) {
    print('❌ Error writing to $dependencyInjectionFilePath: $e');
  }
}

void _scanDirectoryForClasses(
  Directory dir,
  List<Map<String, String>> classes,
) {
  for (var entity in dir.listSync(recursive: true)) {
    // Scan all files recursively within the target folder
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = entity.readAsStringSync();
      final classNameMatches = RegExp(
        r'(abstract\s+)?class\s+([a-zA-Z0-9_]+)(?:\s*<[^>]*>)?\s*(?:implements|extends|\{)',
      ).allMatches(content);

      for (var match in classNameMatches) {
        final bool isAbstract =
            match.group(1) != null && match.group(1)!.contains('abstract');
        final className = match.group(2)!;
        final importPath = p
            .relative(entity.path, from: 'lib')
            .replaceAll(r'\', '/');
        final pathSegments = p.split(entity.path);

        String classType = "unknown";
        if (pathSegments.contains('usecase') ||
            pathSegments.contains('usecases')) {
          classType = "usecase";
        } else if (pathSegments.contains('data_source')) {
          classType = isAbstract ? "abstract_datasource" : "datasource_impl";
        } else if (pathSegments.contains('repository')) {
          if (pathSegments.contains('domain')) {
            classType = "abstract_repo";
          } else if (pathSegments.contains('data')) {
            classType = "repo_impl";
          }
        }

        classes.add({
          'className': className,
          'importPath': importPath,
          'isAbstract': isAbstract.toString(),
          'type': classType, // Helps in deciding how to register
          'fullPath': entity.path, // For context
        });
      }
    }
  }
}

String _generateDiFunction(
  String featureName,
  List<Map<String, String>> classes,
  List<String> allClassNames,
) {
  final funcName = '_init${_capitalizeFirstLetter(featureName)}Dep';
  final buffer = StringBuffer();

  final imports = <String>{};
  for (var c in classes) {
    imports.add(
      "import 'package:${p.basename(p.current)}/${c['importPath']}';",
    );
  }
  imports.add("import 'features/${featureName.toLowerCase()}/${featureName.toLowerCase()}.dart';");
  if (imports.isNotEmpty) {
    buffer.writeln(imports.join('\n'));
    buffer.writeln('');
  }

  buffer.writeln('// START OF $funcName');
  buffer.writeln('void $funcName() {');
  buffer.writeln('  ///* Service Locator Implementation for $featureName *///');
  buffer.writeln('  sl');

  List<String> registeredAbstracts =
      []; // Keep track of registered abstract classes

  for (var c in classes) {
    final className = c['className']!;
    final isAbstract = c['isAbstract'] == 'true';
    final classType = c['type']!;

    if (isAbstract) continue; // Skip direct registration of abstract classes

    if (classType == "repo_impl" || classType == "datasource_impl") {
      final interfaceNameGuess = className.replaceAll('Impl', '');
      // Check if a class with the interface name exists in the collected classes
      final abstractClassMatch = classes.firstWhere(
        (cls) =>
            cls['className'] == interfaceNameGuess &&
            (cls['type'] == 'abstract_repo' ||
                cls['type'] == 'abstract_datasource'),
        orElse: () => <String, String>{}, // Return an empty map if no match
      );

      if (abstractClassMatch.isNotEmpty &&
          !registeredAbstracts.contains(interfaceNameGuess)) {
        buffer.writeln(
          '    ..registerFactory<${abstractClassMatch['className']!}>(',
        );
        buffer.writeln('      () => $className(sl()),');
        buffer.writeln('    )');
        registeredAbstracts.add(interfaceNameGuess);
      } else if (!registeredAbstracts.contains(className)) {
        // Register concrete class if no abstract counterpart or abstract already handled
        buffer.writeln('    ..registerFactory<$className>(');
        buffer.writeln('      () => $className(sl()),');
        buffer.writeln('    )');
        registeredAbstracts.add(
          className,
        ); // Prevent re-registration if it was somehow listed twice
      }
    } else if (classType == "usecase" &&
        !registeredAbstracts.contains(className)) {
      buffer.writeln('    ..registerFactory<$className>(');
      buffer.writeln(
        '      () => $className(sl()),',
      ); // Assumes Usecase takes Repo/other deps from SL
      buffer.writeln('    )');
      registeredAbstracts.add(className);
    }
    // Other types like abstract_repo, abstract_datasource are not directly registered
  }
  buffer.writeln('  ;');
  buffer.writeln('}');
  buffer.writeln('// END OF $funcName\n');
  return buffer.toString();
}

String _appendFunctionToDiFile(String currentContent, String functionContent) {
  final buffer = StringBuffer(currentContent);
  if (!currentContent.endsWith('\n\n')) {
    if (!currentContent.endsWith('\n')) {
      buffer.writeln();
    }
    buffer.writeln();
  }
  buffer.write(functionContent);
  return buffer.toString();
}

String _capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

String _toCamelCase(String text) {
  if (text.isEmpty) return '';
  List<String> parts = text.split(RegExp(r'[_\-\s]'));
  if (parts.isEmpty) return '';
  String result = parts[0].toLowerCase();
  for (int i = 1; i < parts.length; i++) {
    result += _capitalizeFirstLetter(parts[i].toLowerCase());
  }
  return result;
}
