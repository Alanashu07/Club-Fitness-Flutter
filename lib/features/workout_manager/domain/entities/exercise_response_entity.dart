import 'package:club_fitness/core/entities/name_count_entity.dart';
import 'package:club_fitness/core/entities/pagination_entity.dart';

import 'workout_manager_entities.dart';

class ExerciseResponseEntity {
  final List<ExerciseEntity> exercises;
  final List<NameCountEntity> categories;
  final PaginationEntity pagination;

  const ExerciseResponseEntity({
    this.exercises = const [],
    this.categories = const [],
    this.pagination = const PaginationEntity(),
  });

    ExerciseResponseEntity copyWith({
    List<NameCountEntity>? categories,
    List<ExerciseEntity>? exercises,
    PaginationEntity? pagination,
  }) {
    return ExerciseResponseEntity(
      categories: categories ?? this.categories,
      exercises: exercises ?? this.exercises,
      pagination: pagination ?? this.pagination,
    );
  }

  @override
  String toString() {
    return 'Page: ${pagination.page}, ${exercises.length} exercises, ${categories.length} categories';
  }
}
