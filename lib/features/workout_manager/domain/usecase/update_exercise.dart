import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/workout_manager_entities.dart';
import '../repository/workout_manager_repo.dart';

class UpdateExercise implements UseCase<ExerciseEntity, UpdateExerciseParams> {
  final WorkoutManagerRepo repo;

  const UpdateExercise(this.repo);

  @override
  Future<Either<ExerciseEntity, Failure>> call(UpdateExerciseParams params) async {
    return await repo.updateExercise(
      params.id,
      name: params.name,
      category: params.category,
      muscle: params.muscle,
      difficulty: params.difficulty,
      description: params.description,
      videoUrl: params.videoUrl,
      imageUrl: params.imageUrl,
      isActive: params.isActive,
    );
  }
}

class UpdateExerciseParams {
  final String id;
  final String? name;
  final String? category;
  final String? muscle;
  final String? difficulty;
  final String? description;
  final String? videoUrl;
  final String? imageUrl;
  final bool? isActive;

  const UpdateExerciseParams(this.id, {
    
    required this.name,
    required this.category,
    required this.muscle,
    required this.difficulty,
    required this.description,
    required this.videoUrl,
    required this.imageUrl,
    required this.isActive,
  });
}
