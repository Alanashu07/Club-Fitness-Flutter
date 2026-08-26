// ignore_for_file: avoid_print

import 'dart:io';
import 'package:path/path.dart' as p;

void main(List<String> args) {
  if (args.isEmpty) {
    print('❌ Please provide a feature name. Example:');
    print('dart run tools/bloc_generator.dart compare_property');
    return;
  }

  final feature = args.first;
  final pascalCase =
      feature.split('_').map((e) => e[0].toUpperCase() + e.substring(1)).join();
  final classPrefix = pascalCase;

  // Ensure we always generate inside project root/lib/features
  final projectRoot = Directory.current.path;
  final blocDir =
      p.join(projectRoot, 'lib', 'features', feature, 'presentation', 'bloc');

  Directory(blocDir).createSync(recursive: true);

  // Bloc file
  File(p.join(blocDir, '${feature}_bloc.dart')).writeAsStringSync('''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part '${feature}_event.dart';
part '${feature}_state.dart';

class ${classPrefix}Bloc extends Bloc<${classPrefix}Event, ${classPrefix}State> {
  ${classPrefix}Bloc() : super(${classPrefix}Initial()) {
    on<${classPrefix}Event>((event, emit) {
      // TODO: implement event handler
    });
  }
}
''');

  // Event file
  File(p.join(blocDir, '${feature}_event.dart')).writeAsStringSync('''
part of '${feature}_bloc.dart';

sealed class ${classPrefix}Event extends Equatable {
  const ${classPrefix}Event();
}
''');

  // State file
  File(p.join(blocDir, '${feature}_state.dart')).writeAsStringSync('''
part of '${feature}_bloc.dart';

sealed class ${classPrefix}State extends Equatable {
  const ${classPrefix}State();
}

final class ${classPrefix}Initial extends ${classPrefix}State {

  @override
  List<Object> get props => [];
}
''');

  print('✅ Bloc for "$feature" generated successfully at $blocDir');
}
