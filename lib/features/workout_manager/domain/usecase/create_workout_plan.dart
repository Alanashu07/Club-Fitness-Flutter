import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/workout_manager_entities.dart';
import '../repository/workout_manager_repo.dart';

class CreateWorkoutPlan implements UseCase<TemplateDetailsEntity, CreateWorkoutPlanParams> {
  final WorkoutManagerRepo repo;

  const CreateWorkoutPlan(this.repo);

  @override
  Future<Either<TemplateDetailsEntity, Failure>> call(CreateWorkoutPlanParams params) async {
    return await repo.createWorkoutPlan(
      name: params.name,
      startDate: params.startDate,
      endDate: params.endDate,
      isTemplate: params.isTemplate,
      type: params.type,
      days: params.days,
    );
  }
}

class CreateWorkoutPlanParams {
  final String name;
  final String startDate;
  final String endDate;
  final bool isTemplate;
  final String type;
  final List<WorkoutDayInputEntity> days;

  const CreateWorkoutPlanParams({
    required this.name,
    required this.startDate,
    required this.endDate,
    this.isTemplate = false,
    this.type = 'WEEKLY',
    this.days = const [],
  });
}
