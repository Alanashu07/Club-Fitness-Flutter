import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/workout_manager_entities.dart';
import '../repository/workout_manager_repo.dart';

class SaveTemplate implements UseCase<TemplateDetailsEntity, SaveTemplateParams> {
  final WorkoutManagerRepo repo;

  const SaveTemplate(this.repo);

  @override
  Future<Either<TemplateDetailsEntity, Failure>> call(SaveTemplateParams params) async {
    return await repo.saveTemplate(
      planId: params.planId,
    );
  }
}

class SaveTemplateParams {
  final String planId;

  const SaveTemplateParams({
    required this.planId,
  });
}
