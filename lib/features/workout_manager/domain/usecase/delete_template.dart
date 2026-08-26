import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/workout_manager_repo.dart';

class DeleteTemplate implements UseCase<void, DeleteTemplateParams> {
  final WorkoutManagerRepo repo;

  const DeleteTemplate(this.repo);

  @override
  Future<Either<void, Failure>> call(DeleteTemplateParams params) async {
    return await repo.deleteTemplate(params.id, hardDelete: params.hardDelete);
  }
}

class DeleteTemplateParams {
  final String id;
  final bool hardDelete;

  const DeleteTemplateParams(this.id, {this.hardDelete = false});
}
