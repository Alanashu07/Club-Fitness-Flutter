import 'package:club_fitness/core/models/name_count_model.dart';
import 'package:club_fitness/core/models/pagination_model.dart';

import '../../domain/entities/workout_manager_entities.dart';
import 'workout_manager_models.dart';

class ExerciseResponseModel extends ExerciseResponseEntity {
  const ExerciseResponseModel({
    super.categories,
    super.exercises,
    super.pagination,
  });

  factory ExerciseResponseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseResponseModel(
      categories:
          (json['categories'] as List?)
              ?.map((e) => NameCountModel.fromJson(e))
              .toList() ??
          [],
      exercises:
          (json['exercises'] as List?)
              ?.map((e) => ExerciseModel.fromJson(e))
              .toList() ??
          [],
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }

  factory ExerciseResponseModel.fromEntity(ExerciseResponseEntity entity) {
    return ExerciseResponseModel(
      categories: entity.categories
          .map((e) => NameCountModel.fromEntity(e))
          .toList(),
      exercises: entity.exercises
          .map((e) => ExerciseModel.fromEntity(e))
          .toList(),
      pagination: PaginationModel.fromEntity(entity.pagination),
    );
  }

  Map<String, dynamic> toJson() => {
    'categories': categories
        .map((e) => NameCountModel.fromEntity(e).toJson())
        .toList(),
    'exercises': exercises
        .map((e) => ExerciseModel.fromEntity(e).toJson())
        .toList(),
    'pagination': PaginationModel.fromEntity(pagination).toJson(),
  };
}
