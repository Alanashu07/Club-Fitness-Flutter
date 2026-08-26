import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/workout_manager_entities.dart';
import '../repository/workout_manager_repo.dart';

class GetPlanDetails implements UseCase<TemplateDetailsEntity, String> {
  final WorkoutManagerRepo repo;

  const GetPlanDetails(this.repo);

  @override
  Future<Either<TemplateDetailsEntity, Failure>> call(String params) async {
    return await repo.getPlanDetails(params);
  }
}
