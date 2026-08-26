// ignore_for_file: avoid_print

import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print(
      'Usage: dart run repo_generator.dart <data_source_path.dart> <feature_base_name>',
    );
    exit(1);
  }
  String dataSourcePath;
  String featureBaseName;
  String featureBase;
  if (args.length == 1) {
    dataSourcePath =
        'lib/features/${args[0]}/data/data_source/${args[0]}_network_data_source.dart';
    featureBaseName = args[0];
    featureBase = 'lib/features/$featureBaseName';
  } else {
    dataSourcePath = args[0];
    featureBaseName = args[1];
    featureBase = 'lib/features/$featureBaseName';
  }

  final dataSourceFile = File(dataSourcePath);
  if (!dataSourceFile.existsSync()) {
    print('❌ DataSource file not found: $dataSourcePath');
    exit(1);
  }

  final source = dataSourceFile.readAsStringSync();

  print("➡️ File loaded, length: ${source.length}");

  final classMatch = RegExp(
    r'abstract interface class (\w+)',
  ).firstMatch(source);
  if (classMatch == null) {
    print('❌ Could not find DataSource class name.');
    exit(1);
  }
  final dataSourceClass = classMatch.group(1)!;
  final featureName = dataSourceClass.replaceAll('DataSource', '');
  final cleanFeatureName = featureName.endsWith('Network')
      ? featureName.replaceAll('Network', '')
      : featureName;

  final repoName = '${cleanFeatureName}Repo';
  final repoImplName = '${cleanFeatureName}RepoImpl';
  final featureFileName = _toSnakeCase(cleanFeatureName);

  // Extract methods from the abstract interface class
  final methods = _extractMethods(source);

  if (methods.isEmpty) {
    print('❌ Could not find any methods in the DataSource class.');
    print(
      'Ensure methods are defined like: Future<ReturnType> methodName(parameters);',
    );
    exit(1);
  }
  print('Found ${methods.length} methods in $dataSourceClass.');

  // Generate Domain Repository
  final repoContent = StringBuffer('''
import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
// TODO: Import necessary models based on actual return types

abstract interface class $repoName {
''');

  for (var m in methods) {
    repoContent.writeln(
      '  Future<Either<${m['returnType']}, Failure>> ${m['name']}(${m['paramsDefinition']});',
    );
  }
  repoContent.writeln('}');

  final repoPath =
      '$featureBase/domain/repository/${featureFileName.toLowerCase()}_repo.dart';
  File(repoPath).createSync(recursive: true);
  File(repoPath).writeAsStringSync(repoContent.toString());
  print('✅ Generated Domain Repo: $repoPath');

  // Generate Repository Implementation
  final repoImplContent = StringBuffer('''
import 'dart:developer' as dev_log;
import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
// TODO: Import necessary models used in parameters or return types
import '../data_source/${featureFileName.toLowerCase()}_network_data_source.dart';
import '../../domain/repository/${featureFileName.toLowerCase()}_repo.dart';

class $repoImplName implements $repoName {
  final $dataSourceClass dataSource;
  const $repoImplName(this.dataSource);

''');

  for (var m in methods) {
    repoImplContent.writeln('''
  @override
  Future<Either<${m['returnType']}, Failure>> ${m['name']}(${m['paramsDefinition']}) async {
    try {
      final result = await dataSource.${m['name']}(${m['paramsForCall']});
      return Left(result);
    } catch (e, s) {
      dev_log.log(e.toString(), name: '${m['name']} in $repoImplName', stackTrace: s, error: e);
      return Right(Failure.fromException(e));
    }
  }
''');
  }

  repoImplContent.writeln('}');

  final repoImplPath =
      '$featureBase/data/repository/${featureFileName.toLowerCase()}_repo_impl.dart';
  File(repoImplPath).createSync(recursive: true);
  File(repoImplPath).writeAsStringSync(repoImplContent.toString());
  print('✅ Generated Data RepoImpl: $repoImplPath');

  print(
    '✅ Generated $repoName and $repoImplName successfully with ${methods.length} methods!',
  );
}

/// Extracts all methods from the data source class
List<Map<String, String>> _extractMethods(String source) {
  final methods = <Map<String, String>>[];

  // Match Future<ReturnType> methodName(params);
  // This regex handles complex return types including tuples like (List<Model>, int)
  // final methodRegex = RegExp(
  //   r'Future<(.+?)>\s+(\w+)\s*\(((?:[^)(]+|\((?:[^)(]+|\([^)(]*\))*\))*)\)\s*;',
  //   multiLine: true,
  // );

  final methodRegex = RegExp(
    r'Future<((?:[^<>]|<[^<>]*>)+)>\s+(\w+)\s*\(([^)]*)\)\s*;',
    multiLine: true,
  );

  for (final match in methodRegex.allMatches(source)) {
    final returnType = match.group(1)!.trim();
    final methodName = match.group(2)!.trim();
    final paramsString = match.group(3)!.trim();

    methods.add({
      'returnType': returnType,
      'name': methodName,
      'paramsDefinition': paramsString,
      'paramsForCall': _extractParamsForCall(paramsString),
    });
  }

  return methods;
}

/// Extracts parameter names from a parameter string for use in a method call.
/// Handles positional, optional positional, and named parameters.
/// E.g., "String query, {required int limit, String? type}"
/// becomes "query, limit: limit, type: type"
String _extractParamsForCall(String paramsString) {
  if (paramsString.trim().isEmpty) return '';

  final callArgs = <String>[];
  final params = _splitParameters(paramsString);

  bool inNamedBlock = false;

  for (String param in params) {
    param = param.trim();
    if (param.isEmpty) continue;

    // Handle named parameters block
    if (param.startsWith('{')) {
      inNamedBlock = true;
      param = param.substring(1).trim();
    }
    if (param.endsWith('}')) {
      param = param.substring(0, param.length - 1).trim();
      if (param.isEmpty) {
        inNamedBlock = false;
        continue;
      }
    }

    // Handle optional positional parameters block
    if (param.startsWith('[')) {
      param = param.substring(1).trim();
    }
    if (param.endsWith(']')) {
      param = param.substring(0, param.length - 1).trim();
      if (param.isEmpty) continue;
    }

    // Extract parameter name
    final paramName = _extractParameterName(param);
    if (paramName.isEmpty) continue;

    // Format based on parameter type
    if (inNamedBlock) {
      callArgs.add('$paramName: $paramName');
    } else {
      callArgs.add(paramName);
    }
  }

  return callArgs.join(', ');
}

/// Splits parameters by comma while respecting nested structures
List<String> _splitParameters(String paramsString) {
  final params = <String>[];
  int depth = 0;
  int start = 0;

  for (int i = 0; i < paramsString.length; i++) {
    final char = paramsString[i];

    // Track nesting depth
    if (char == '<' || char == '(' || char == '{' || char == '[') {
      depth++;
    } else if (char == '>' || char == ')' || char == '}' || char == ']') {
      depth--;
    } else if (char == ',' && depth == 0) {
      // Found a parameter separator at top level
      params.add(paramsString.substring(start, i));
      start = i + 1;
    }
  }

  // Add the last parameter
  if (start < paramsString.length) {
    params.add(paramsString.substring(start));
  }

  return params;
}

/// Extracts the parameter name from a parameter declaration
/// E.g., "required String query" -> "query"
/// E.g., "int? limit" -> "limit"
/// E.g., "Map<String, dynamic> filters" -> "filters"
/// E.g., "void Function(String? nextUrl) hasMore" -> "hasMore"
String _extractParameterName(String param) {
  param = param.trim();

  // Remove 'required' and 'final' keywords
  param = param.replaceFirst(RegExp(r'^\s*(required|final)\s+'), '');

  // Handle function types: void Function(...) paramName
  final functionMatch = RegExp(r'.*\)\s+(\w+)$').firstMatch(param);
  if (functionMatch != null) {
    return functionMatch.group(1)!;
  }

  // Handle regular types: Type paramName or Type<Generic> paramName
  // Split by whitespace and take the last word
  final parts = param.split(RegExp(r'\s+'));
  if (parts.isEmpty) return '';

  // The last part is the parameter name (possibly with ? for nullable)
  String name = parts.last.replaceAll('?', '').replaceAll(',', '');

  // If name contains =, it's a default value, take the part before =
  if (name.contains('=')) {
    name = name.split('=').first.trim();
  }

  return name;
}

/// Converts PascalCase or camelCase to snake_case
String _toSnakeCase(String input) {
  return input
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (m) => '${m.group(1)}_${m.group(2)}',
      )
      .toLowerCase();
}
