import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/workout_manager_entities.dart';
import '../repository/workout_manager_repo.dart';

class CreateExercise implements UseCase<ExerciseEntity, CreateExerciseParams> {
  final WorkoutManagerRepo repo;

  const CreateExercise(this.repo);

  @override
  Future<Either<ExerciseEntity, Failure>> call(CreateExerciseParams params) async {
    return await repo.createExercise(
      name: params.name,
      category: params.category,
      muscle: params.muscle,
      difficulty: params.difficulty,
      description: params.description,
      videoUrl: params.videoUrl,
      imageUrl: params.imageUrl,
    );
  }
}

class CreateExerciseParams {
  final String name;
  final String category;
  final String muscle;
  final String? difficulty;
  final String? description;
  final String? videoUrl;
  final String? imageUrl;

  const CreateExerciseParams({
    required this.name,
    required this.category,
    required this.muscle,
    required this.difficulty,
    required this.description,
    required this.videoUrl,
    required this.imageUrl,
  });
}
