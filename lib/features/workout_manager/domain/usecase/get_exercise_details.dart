import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/workout_manager_repo.dart';
import '../entities/workout_manager_entities.dart';

class GetExerciseDetails implements UseCase<ExerciseEntity, String> {
  final WorkoutManagerRepo repo;

  const GetExerciseDetails(this.repo);

  @override
  Future<Either<ExerciseEntity, Failure>> call(String params) async {
    return await repo.getExerciseDetails(params);
  }
}
