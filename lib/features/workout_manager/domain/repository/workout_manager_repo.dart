import 'package:club_fitness/core/entities/pagination_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';

import '../entities/workout_manager_entities.dart';

abstract interface class WorkoutManagerRepo {
  Future<Either<ResponseEntity<WorkoutTemplateMiniEntity>, Failure>> getWorkoutTemplates({
    String? search,
    num? page,
    num? limit,
    String? type,
  });
  Future<Either<TemplateDetailsEntity, Failure>> getTemplateDetails(String id);
  Future<Either<ExerciseResponseEntity, Failure>> getExercises({
    String? category,
    String? difficulty,
    String? search,
    num? page,
    num? limit,
  });
  Future<Either<TemplateDetailsEntity, Failure>> saveTemplate({required String planId});
  Future<Either<void, Failure>> deleteTemplate(String id, {bool hardDelete = false});
  Future<Either<ExerciseEntity, Failure>> getExerciseDetails(String id);
  Future<Either<ExerciseEntity, Failure>> createExercise({
    required String name,
    required String category,
    required String muscle,
    String? difficulty,
    String? description,
    String? videoUrl,
    String? imageUrl,
  });
  Future<Either<ExerciseEntity, Failure>> updateExercise(String id, {
    String? name,
    String? category,
    String? muscle,
    String? difficulty,
    String? description,
    String? videoUrl,
    String? imageUrl,
    bool? isActive,
  });
  Future<Either<AssignWorkoutResponseEntity, Failure>> assignWorkout({
    required String planId,
    required List<String> memberIds,
    required String startDate,
    required String endDate,
    bool notifyMembers = true,
  });
  Future<Either<ResponseEntity<PlanListingEntity>, Failure>> getAllPlans({
    String? search,
    String? type,
    bool? isTemplate,
    num? page,
    num? limit,
  });
  Future<Either<TemplateDetailsEntity, Failure>> getPlanDetails(String id);
  Future<Either<TemplateDetailsEntity, Failure>> createWorkoutPlan({
    required String name,
    String type = 'WEEKLY',
    required String startDate,
    required String endDate,
    bool isTemplate = false,
    List<WorkoutDayInputEntity> days = const [],
  });
  Future<Either<void, Failure>> deleteWorkoutPlan(String id);
  // Future<Either<MyWorkoutsResponseEntity, Failure>> getMyWorkouts();
  // Future<Either<WorkoutWeekEntity, Failure>> getWeek({String? weekStart, String? memberId});
  // Future<Either<ToggleExerciseResponseEntity, Failure>> toggleExercise({
  //   required String date,
  //   required String planExerciseId,
  //   String? memberId,
  // });
}
