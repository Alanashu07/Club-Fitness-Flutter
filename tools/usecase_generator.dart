// ignore_for_file: avoid_print

import 'dart:io';

final skippedFiles = <String>[];

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run usecase_generator.dart <repo_path> <output_path>');
    return;
  }
  String repoPath;
  String outputPath;

  if (args.length == 1) {
    repoPath = "lib/features/${args[0]}/domain/repository/${args[0]}_repo.dart";
    outputPath = "lib/features/${args[0]}/domain/usecase";
  } else {
    repoPath = args[0];
    outputPath = args[1];
  }

  final repoFile = File(repoPath);
  if (!await repoFile.exists()) {
    print('Repo file not found: $repoPath');
    return;
  }

  final content = await repoFile.readAsString();

  // Extract repo class name
  final repoClassMatch = RegExp(
    r'abstract interface class (\w+)',
  ).firstMatch(content);
  if (repoClassMatch == null) {
    print('Could not find repository class in $repoPath');
    return;
  }

  final repoClass = repoClassMatch.group(1)!;

  // Extract methods
  final methodRegex = RegExp(
    r'Future<Either<(.+?),\s*Failure>>\s+(\w+)\(([\s\S]*?)\);',
    multiLine: true,
  );
  final matches = methodRegex.allMatches(content);

  if (matches.isEmpty) {
    print('No methods found in $repoPath');
    return;
  }

  for (final match in matches) {
    final returnType = match.group(1)!.trim();
    final methodName = match.group(2)!;
    final paramsRaw = match.group(3)!.trim();

    final className = _toPascalCase(methodName);
    final fileName = _toSnakeCase(methodName);

    final hasParams = paramsRaw.isNotEmpty && paramsRaw != '{}';
    String paramsType;

    if (!hasParams) {
      paramsType = 'NoParam';
    } else if (paramsRaw.contains('{')) {
      paramsType = '${className}Params';
    } else {
      final parts = paramsRaw
          .split(RegExp(r'\s+'))
          .where((e) => e.isNotEmpty)
          .toList();
      paramsType = parts.first;
    }

    // Generate code
    final buffer = StringBuffer();

    buffer.writeln("import 'package:dartz/dartz.dart';");
    buffer.writeln(
      "import 'package:club_fitness/core/exceptions/failure.dart';",
    );
    buffer.writeln("import 'package:club_fitness/core/usecases/usecase.dart';");
    buffer.writeln("import '../repository/${_toSnakeCase(repoClass)}.dart';");
    if (!hasParams) {
      buffer.writeln("import '../../../../core/parameters/no_param.dart';");
    }
    buffer.writeln();

    // Class
    buffer.writeln(
      'class $className implements UseCase<$returnType, $paramsType> {',
    );
    buffer.writeln('  final $repoClass repo;');
    buffer.writeln();
    buffer.writeln('  const $className(this.repo);');
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln(
      '  Future<Either<$returnType, Failure>> call($paramsType params) async {',
    );

    if (!hasParams) {
      buffer.writeln('    return await repo.$methodName();');
    } else if (paramsRaw.contains('{')) {
      buffer.writeln('    return await repo.$methodName(');
      final namedParams = _extractParams(paramsRaw);
      for (final param in namedParams) {
        buffer.writeln('      ${param['name']}: params.${param['name']},');
      }
      buffer.writeln('    );');
    } else {
      buffer.writeln('    return await repo.$methodName(params);');
    }

    buffer.writeln('  }');
    buffer.writeln('}');

    // Add Params class if needed
    if (paramsRaw.contains('{')) {
      buffer.writeln();
      buffer.writeln('class ${className}Params {');
      final namedParams = _extractParams(paramsRaw);

      for (final param in namedParams) {
        buffer.writeln('  final ${param['type']} ${param['name']};');
      }
      buffer.writeln();
      buffer.writeln('  const ${className}Params({');
      for (final param in namedParams) {
        buffer.writeln('    required this.${param['name']},');
      }
      buffer.writeln('  });');
      buffer.writeln('}');
    }

    // Write file (skip if already exists)
    final outputFile = File('$outputPath/$fileName.dart');
    await outputFile.parent.create(recursive: true);
    if (await outputFile.exists()) {
      skippedFiles.add(outputFile.path);
      continue;
    }
    await outputFile.writeAsString(buffer.toString());

    print('✅ Generated usecase: $fileName.dart');
  }

  if (skippedFiles.isNotEmpty) {
    print('\n⚠️ Skipped existing files:');
    for (final f in skippedFiles) {
      print(' - $f');
    }
  }
}

String _toPascalCase(String input) {
  return input.splitMapJoin(
    RegExp(r'[A-Za-z0-9]+'),
    onMatch: (m) => m[0]![0].toUpperCase() + m[0]!.substring(1),
  );
}

String _toSnakeCase(String input) {
  return input
      .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}')
      .toLowerCase();
}

/// Extracts named parameters into a list of maps: { 'type': ..., 'name': ... }
List<Map<String, String>> _extractParams(String paramsRaw) {
  // Remove braces and the 'required' keyword
  final cleaned = paramsRaw
      .replaceAll(RegExp(r'[{}]'), '')
      .replaceAll('required', '')
      .trim();

  final params = <Map<String, String>>[];
  final paramList = _splitParameters(cleaned);

  for (final param in paramList) {
    final trimmed = param.trim();
    if (trimmed.isEmpty) continue;

    // Find the last identifier as the parameter name
    final nameMatch = RegExp(r'(\w+)$').firstMatch(trimmed);
    if (nameMatch == null) continue;

    final name = nameMatch.group(1)!;
    final type = trimmed.substring(0, nameMatch.start).trim();

    params.add({'type': type, 'name': name});
  }

  return params;
}

/// Splits parameters by comma, but respects angle brackets (generics)
List<String> _splitParameters(String params) {
  final result = <String>[];
  final buffer = StringBuffer();
  var bracketDepth = 0;

  for (var i = 0; i < params.length; i++) {
    final char = params[i];

    if (char == '<') {
      bracketDepth++;
      buffer.write(char);
    } else if (char == '>') {
      bracketDepth--;
      buffer.write(char);
    } else if (char == ',' && bracketDepth == 0) {
      result.add(buffer.toString());
      buffer.clear();
    } else {
      buffer.write(char);
    }
  }

  if (buffer.isNotEmpty) {
    result.add(buffer.toString());
  }

  return result;
}
