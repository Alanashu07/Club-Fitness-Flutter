import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/workout_manager_entities.dart';
import '../repository/workout_manager_repo.dart';

class GetExercises implements UseCase<ExerciseResponseEntity, GetExercisesParams> {
  final WorkoutManagerRepo repo;

  const GetExercises(this.repo);

  @override
  Future<Either<ExerciseResponseEntity, Failure>> call(GetExercisesParams params) async {
    return await repo.getExercises(
      category: params.category,
      difficulty: params.difficulty,
      search: params.search,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetExercisesParams {
  final String? category;
  final String? difficulty;
  final String? search;
  final num? page;
  final num? limit;

  const GetExercisesParams({
    this.category,
    this.difficulty,
    this.search,
    this.page,
    this.limit,
  });
}
