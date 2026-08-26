// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

/// Run with:
/// dart run tools/generate_single_file.dart <json_file> <ClassName> [feature_name]
///
/// This version generates ALL related Entities in ONE file and ALL related Models in ONE file.

final generatedClasses = <String>{};
final skippedFiles = <String>[];

// Global buffers to hold content for the single files
final StringBuffer allEntitiesContent = StringBuffer();
final StringBuffer allModelsContent = StringBuffer();

void main(List<String> args) {
  if (args.length < 2) {
    print(
      'Usage: dart run tools/generate_single_file.dart <json_file> <ClassName> [feature_name or path]',
    );
    return;
  }

  String filePath = args[0].contains('/')
      ? args[0]
      : 'lib/core/json/${args[0]}';
  final file = File(filePath);
  if (!file.existsSync()) {
    print('❌ JSON file not found: ${args[0]}');
    return;
  }

  final jsonStr = file.readAsStringSync();
  final dynamic data = jsonDecode(jsonStr);

  if (data is! Map<String, dynamic>) {
    print('❌ JSON root must be an object');
    return;
  }

  final className = args[1];
  final featureName = args.length > 2 ? args[2] : null;
  final featurePath = featureName == null
      ? null
      : featureName.contains('/')
      ? featureName
      : 'lib/features/$featureName';

  // Start generation
  _generateClassRecursive(data, className);

  print('\n✅ Done. Generated classes in memory:');
  for (final c in generatedClasses) {
    print(' - $c');
  }

  // ---------------- FINAL WRITE ----------------
  final entityDir = featurePath != null
      ? '$featurePath/domain/entities'
      : 'lib/core/entities';
  final modelDir = featurePath != null
      ? '$featurePath/data/models'
      : 'lib/core/models';

  final entityFileName = '${className.snake}_entity.dart';
  final modelFileName = '${className.snake}_model.dart';

  final entityFile = File('$entityDir/$entityFileName');
  final modelFile = File('$modelDir/$modelFileName');

  entityFile.parent.createSync(recursive: true);
  modelFile.parent.createSync(recursive: true);

  // Prepare final content with headers/imports
  final finalEntityContent = StringBuffer();
  // finalEntityContent.writeln("// ignore_for_file: invalid_annotation_target\n");
  finalEntityContent.write(allEntitiesContent.toString());

  final finalModelContent = StringBuffer();

  // Import the entity file relative to the model file
  // Assuming standard clean architecture structure:
  // domain/entities/file.dart
  // data/models/file.dart
  // The import path from model to entity is usually ../../domain/entities/file.dart

  final entityImportPath = featurePath != null
      ? '../../domain/entities/$entityFileName'
      : '../entities/$entityFileName';

  finalModelContent.writeln("import '$entityImportPath';\n");
  finalModelContent.write(allModelsContent.toString());

  _writeFile(entityFile, finalEntityContent.toString());
  _writeFile(modelFile, finalModelContent.toString());
}

void _generateClassRecursive(Map<String, dynamic> data, String className) {
  if (generatedClasses.contains(className)) return;
  generatedClasses.add(className);

  final entityName = '${className}Entity';
  final modelName = '${className}Model';

  final entityBuffer = StringBuffer();
  final modelBuffer = StringBuffer();

  // ---------------- ENTITY ----------------
  entityBuffer.writeln('class $entityName {');
  data.forEach((key, value) {
    final type = _mapType(key, value, className, nullable: false);
    entityBuffer.writeln('  final $type ${_camelCase(key)};');
  });

  entityBuffer.writeln('\n  const $entityName({');
  data.forEach((key, value) {
    final field = _camelCase(key);
    entityBuffer.writeln('    this.$field = ${_defaultValue(value, key)},');
  });
  entityBuffer.writeln('  });');

  // toString
  entityBuffer.writeln('\n  @override');
  entityBuffer.writeln('  String toString() {');
  entityBuffer.writeln("    return '$entityName('");
  data.forEach((key, _) {
    final field = _camelCase(key);
    entityBuffer.writeln("      '$field: \$$field, '");
  });
  entityBuffer.writeln("    ')';");
  entityBuffer.writeln('  }');

  final hasSlug = data.keys.contains('slug');
  final hasId = data.keys.contains('id');
  final eqField = hasSlug
      ? 'slug'
      : hasId
      ? 'id'
      : null;

  if (eqField != null) {
    entityBuffer.writeln('\n  @override');
    entityBuffer.writeln('  bool operator ==(Object other) {');
    entityBuffer.writeln(
      '    return identical(this, other) || (other is $entityName && other.${_camelCase(eqField)} == ${_camelCase(eqField)});',
    );
    entityBuffer.writeln('  }');

    entityBuffer.writeln('\n  @override');
    entityBuffer.writeln(
      '  int get hashCode => ${_camelCase(eqField)}.hashCode;',
    );
  }

  entityBuffer.writeln('}');
  entityBuffer.writeln(''); // New line between classes

  // ---------------- MODEL ----------------
  modelBuffer.writeln('class $modelName extends $entityName {');
  modelBuffer.writeln('  const $modelName({');
  data.forEach((key, value) {
    modelBuffer.writeln('    super.${_camelCase(key)},');
  });
  modelBuffer.writeln('  });');

  // fromJson
  modelBuffer.writeln(
    '\n  factory $modelName.fromJson(Map<String, dynamic> json) {',
  );
  modelBuffer.writeln('    return $modelName(');
  data.forEach((key, value) {
    final field = _camelCase(key);

    if (value is Map<String, dynamic>) {
      final subClass = _pascalCase(key);
      modelBuffer.writeln(
        "      $field: json['$key'] != null ? ${subClass}Model.fromJson(json['$key']) : const ${subClass}Model(),",
      );
      // RECURSION HERE: Generate the child class content
      _generateClassRecursive(value, subClass);
    } else if (value is List && value.isNotEmpty && value.first is Map) {
      final subClass = _pascalCase(key.substring(0, key.length - 1));
      modelBuffer.writeln(
        "      $field: (json['$key'] as List?)?.map((e) => ${subClass}Model.fromJson(e)).toList() ?? const [],",
      );
      // RECURSION HERE: Generate the child class content
      _generateClassRecursive(value.first as Map<String, dynamic>, subClass);
    } else {
      final type = _mapType(
        key,
        value,
        className,
        nullable: false,
        isEntity: false,
      );
      modelBuffer.writeln(
        "      $field: json['$key'] as $type? ?? ${_defaultValue(value, key, false)},",
      );
    }
  });
  modelBuffer.writeln('    );');
  modelBuffer.writeln('  }');

  // fromEntity
  modelBuffer.writeln(
    '\n  factory $modelName.fromEntity($entityName entity) {',
  );
  modelBuffer.writeln('    return $modelName(');
  data.forEach((key, _) {
    final field = _camelCase(key);
    modelBuffer.writeln('      $field: entity.$field,');
  });
  modelBuffer.writeln('    );');
  modelBuffer.writeln('  }');

  // copyWith
  modelBuffer.writeln('\n  $modelName copyWith({');
  data.forEach((key, value) {
    modelBuffer.writeln(
      '    ${_mapType(key, value, className, nullable: false, isEntity: false)}? ${_camelCase(key)},',
    );
  });
  modelBuffer.writeln('  }) => $modelName(');
  data.forEach((key, _) {
    final field = _camelCase(key);
    modelBuffer.writeln('      $field: $field ?? this.$field,');
  });
  modelBuffer.writeln('  );');

  // toJson
  modelBuffer.writeln('\n  Map<String, dynamic> toJson() => {');
  data.forEach((key, value) {
    final field = _camelCase(key);
    if (value is Map) {
      modelBuffer.writeln(
        "        '$key': ${_pascalCase(key)}Model.fromEntity($field).toJson(),",
      );
    } else if (value is List && value.isNotEmpty && value.first is Map) {
      final subClass = _pascalCase(key.substring(0, key.length - 1));
      modelBuffer.writeln(
        "        '$key': $field.map((e) => ${subClass}Model.fromEntity(e).toJson()).toList(),",
      );
    } else {
      modelBuffer.writeln("        '$key': $field,");
    }
  });
  modelBuffer.writeln(
    '      }..removeWhere((key, value) => _removeEmpty(value));',
  );

  // toString
  modelBuffer.writeln('\n  @override');
  modelBuffer.writeln('  String toString() {');
  modelBuffer.writeln("    return '$modelName('");
  data.forEach((key, _) {
    final field = _camelCase(key);
    modelBuffer.writeln("      '$field: \$$field, '");
  });
  modelBuffer.writeln("    ')';");
  modelBuffer.writeln('  }');

  if (eqField != null) {
    modelBuffer.writeln('\n  @override');
    modelBuffer.writeln('  bool operator ==(Object other) {');
    modelBuffer.writeln(
      '    return identical(this, other) || (other is $modelName && other.${_camelCase(eqField)} == ${_camelCase(eqField)});',
    );
    modelBuffer.writeln('  }');

    modelBuffer.writeln('\n  @override');
    modelBuffer.writeln(
      '  int get hashCode => ${_camelCase(eqField)}.hashCode;',
    );
  }

  // Add helper only once per class, or better, once per file.
  // Since we are combining files, we'll put the helper inside the class to avoid collision
  // or we can rely on standard library.
  // To match previous logic, we keep it local.
  modelBuffer.writeln('\n  // Helper function to remove empty values');
  modelBuffer.writeln('  bool _removeEmpty(dynamic value) {');
  modelBuffer.writeln('    if (value == null) return true;');
  modelBuffer.writeln('    if (value is num) return value == 0;');
  modelBuffer.writeln('    if (value is String) return value.isEmpty;');
  modelBuffer.writeln('    if (value is List) return value.isEmpty;');
  modelBuffer.writeln('    if (value is bool) return !value;');
  modelBuffer.writeln(
    '    if (value is Map) {return (value..removeWhere((key, value) => _removeEmpty(value),)).isEmpty;}',
  );
  modelBuffer.writeln('    return false;');
  modelBuffer.writeln('  }');

  modelBuffer.writeln('}');
  modelBuffer.writeln(''); // New line between classes

  // APPEND TO GLOBAL BUFFERS
  // We append at the top or bottom? Usually dependencies (children) should be defined.
  // Dart classes in same file don't care about order.
  allEntitiesContent.write(entityBuffer.toString());
  allModelsContent.write(modelBuffer.toString());
}

void _writeFile(File file, String content) {
  if (file.existsSync()) {
    skippedFiles.add(file.path);
    // Uncomment this if you want to overwrite:
    // file.writeAsStringSync(content);
    // return;
    // For now, we respect the original logic of skipping.
    // However, since we are merging files, if the main file exists we skip EVERYTHING.
    return;
  }
  file.writeAsStringSync(content);
}

String _defaultValue(dynamic value, String key, [bool isEntity = true]) {
  if (value is num) return '0';
  if (value is double) return '0.0';
  if (value is bool) return 'false';
  if (value is List) return 'const []';
  if (value is Map) {
    return 'const ${_pascalCase(key)}${isEntity ? 'Entity' : 'Model'}()';
  }
  return "''";
}

String _mapType(
  String key,
  dynamic value,
  String parent, {
  bool nullable = true,
  bool isEntity = true,
}) {
  if (value is num) return 'num';
  if (value is double) return 'double';
  if (value is bool) return 'bool';
  if (value is List && value.isNotEmpty) {
    final first = value.first;
    if (first is Map) {
      final subClass = _pascalCase(key.substring(0, key.length - 1));
      // No import needed as they are in the same file
      return 'List<$subClass${isEntity ? 'Entity' : 'Model'}>';
    }
    return 'List<${_mapType(key, first, parent, nullable: false, isEntity: isEntity)}>';
  }
  if (value is Map) {
    final subClass = _pascalCase(key);
    // No import needed as they are in the same file
    return '$subClass${isEntity ? 'Entity' : 'Model'}';
  }
  if (value is String) return 'String';
  return 'dynamic';
}

String _camelCase(String text) {
  return text.contains('_')
      ? text.split('_').asMap().entries.map((e) {
          if (e.key == 0) return e.value;
          return e.value[0].toUpperCase() + e.value.substring(1);
        }).join()
      : text;
}

String _pascalCase(String text) {
  final camel = _camelCase(text);
  return camel[0].toUpperCase() + camel.substring(1);
}

extension SnakeCase on String {
  String get snake => replaceAllMapped(
    RegExp(r'([a-z0-9])([A-Z])'),
    (m) => "${m.group(1)}_${m.group(2)}",
  ).toLowerCase();
}
