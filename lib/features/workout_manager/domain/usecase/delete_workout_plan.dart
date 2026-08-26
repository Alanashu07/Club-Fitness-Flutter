import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/workout_manager_repo.dart';

class DeleteWorkoutPlan implements UseCase<void, String> {
  final WorkoutManagerRepo repo;

  const DeleteWorkoutPlan(this.repo);

  @override
  Future<Either<void, Failure>> call(String params) async {
    return await repo.deleteWorkoutPlan(params);
  }
}
