import 'package:club_fitness/core/entities/pagination_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/workout_manager_entities.dart';
import '../repository/workout_manager_repo.dart';

class GetWorkoutTemplates implements UseCase<ResponseEntity<WorkoutTemplateMiniEntity>, GetWorkoutTemplatesParams> {
  final WorkoutManagerRepo repo;

  const GetWorkoutTemplates(this.repo);

  @override
  Future<Either<ResponseEntity<WorkoutTemplateMiniEntity>, Failure>> call(GetWorkoutTemplatesParams params) async {
    return await repo.getWorkoutTemplates(
      search: params.search,
      page: params.page,
      limit: params.limit,
      type: params.type,
    );
  }
}

class GetWorkoutTemplatesParams {
  final String? search;
  final num? page;
  final num? limit;
  final String? type;

  const GetWorkoutTemplatesParams({
    this.search,
    this.page,
    this.limit,
    this.type,
  });
}
