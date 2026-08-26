import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/workout_manager_entities.dart';
import '../repository/workout_manager_repo.dart';

class AssignWorkout implements UseCase<AssignWorkoutResponseEntity, AssignWorkoutParams> {
  final WorkoutManagerRepo repo;

  const AssignWorkout(this.repo);

  @override
  Future<Either<AssignWorkoutResponseEntity, Failure>> call(AssignWorkoutParams params) async {
    return await repo.assignWorkout(
      planId: params.planId,
      memberIds: params.memberIds,
      startDate: params.startDate,
      endDate: params.endDate,
      notifyMembers: params.notifyMembers,
    );
  }
}

class AssignWorkoutParams {
  final String planId;
  final List<String> memberIds;
  final String startDate;
  final String endDate;
  final bool notifyMembers;

  const AssignWorkoutParams({
    required this.planId,
    required this.memberIds,
    required this.startDate,
    required this.endDate,
    this.notifyMembers = true,
  });
}
