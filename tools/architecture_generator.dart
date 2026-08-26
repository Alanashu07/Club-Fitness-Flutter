// ignore_for_file: avoid_print

import 'dart:io';

/// Run with: dart run tools/architecture_generator.dart compare_property
/// This will create the flutter clean architecture folder and files.
/// Use generate.dart to generate classes from json file that follows clean architecture.
/// Make sure to include path to the file as well.
/// Example: dart run tools/generate.dart show_case_video.json ShowCaseVideo

void main(List<String> args) {
  if (args.isEmpty) {
    print('❌ Please provide a feature name. Example:');
    print('dart run architecture_generator.dart compare_property');
    return;
  }

  final feature = args.first;
  final pascalCase = feature
      .split('_')
      .map((e) => e[0].toUpperCase() + e.substring(1))
      .join();
  final classPrefix = pascalCase;

  final baseDir = 'lib/features/$feature';
  if (Directory(baseDir).existsSync()) {
    print('⚠️ Feature "$feature" already exists. Skipping generation.');
    return;
  }

  final dirs = [
    '$baseDir/data/data_source',
    '$baseDir/data/models',
    '$baseDir/data/repository',
    '$baseDir/domain/entities',
    '$baseDir/domain/repository',
    '$baseDir/domain/usecase',
    '$baseDir/presentation/bloc',
    '$baseDir/presentation/screens',
    '$baseDir/presentation/widgets',
  ];

  for (final dir in dirs) {
    Directory(dir).createSync(recursive: true);
  }

  // Data Source
  File(
    '$baseDir/data/data_source/${feature}_network_data_source.dart',
  ).writeAsStringSync('''
abstract interface class ${classPrefix}NetworkDataSource {}

class ${classPrefix}NetworkDataSourceImpl
    implements ${classPrefix}NetworkDataSource {}
''');

  // Domain Repository
  File('$baseDir/domain/repository/${feature}_repo.dart').writeAsStringSync('''
abstract interface class ${classPrefix}Repo {}
''');

  // Data Repository Impl
  File('$baseDir/data/repository/${feature}_repo_impl.dart').writeAsStringSync(
    '''
import '../../domain/repository/${feature}_repo.dart';

class ${classPrefix}RepoImpl implements ${classPrefix}Repo {}
''',
  );

  // Presentation Screen
  File(
    '$baseDir/presentation/screens/${feature}_screen.dart',
  ).writeAsStringSync('''
import 'package:flutter/material.dart';
import '${feature}_view.dart';

class ${classPrefix}Screen extends StatelessWidget {
  const ${classPrefix}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ${classPrefix}View();
  }
}
''');

  // Presentation View
  File('$baseDir/presentation/screens/${feature}_view.dart').writeAsStringSync(
    '''
import 'package:flutter/material.dart';

class ${classPrefix}View extends StatelessWidget {
  const ${classPrefix}View({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('$classPrefix View')),
    );
  }
}
''',
  );

  print('✅ Feature "$feature" generated successfully!');
}
