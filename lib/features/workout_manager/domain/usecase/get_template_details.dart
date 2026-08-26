import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/workout_manager_entities.dart';
import '../repository/workout_manager_repo.dart';

class GetTemplateDetails implements UseCase<TemplateDetailsEntity, String> {
  final WorkoutManagerRepo repo;

  const GetTemplateDetails(this.repo);

  @override
  Future<Either<TemplateDetailsEntity, Failure>> call(String params) async {
    return await repo.getTemplateDetails(params);
  }
}
