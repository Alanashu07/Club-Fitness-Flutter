import 'dart:developer' as dev_log;
import 'package:club_fitness/core/models/pagination_model.dart';
import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import '../../domain/entities/workout_day_input_entity.dart';
import '../data_source/workout_manager_network_data_source.dart';
import '../../domain/repository/workout_manager_repo.dart';
import '../models/workout_manager_models.dart';

class WorkoutManagerRepoImpl implements WorkoutManagerRepo {
  final WorkoutManagerNetworkDataSource dataSource;
  const WorkoutManagerRepoImpl(this.dataSource);

  @override
  Future<Either<ResponseModel<WorkoutTemplateMiniModel>, Failure>>
  getWorkoutTemplates({
    String? search,
    num? page,
    num? limit,
    String? type,
  }) async {
    try {
      final result = await dataSource.getWorkoutTemplates(
        type: type,
        limit: limit,
        page: page,
        search: search,
      );
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'getWorkoutTemplates in WorkoutManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<TemplateDetailsModel, Failure>> getTemplateDetails(
    String id,
  ) async {
    try {
      final result = await dataSource.getTemplateDetails(id);
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'getTemplateDetails in WorkoutManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<ExerciseResponseModel, Failure>> getExercises({
    String? category,
    String? difficulty,
    String? search,
    num? page,
    num? limit,
  }) async {
    try {
      final result = await dataSource.getExercises(
        limit: limit,
        page: page,
        category: category,
        difficulty: difficulty,
        search: search,
      );
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'getExercises in WorkoutManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<TemplateDetailsModel, Failure>> saveTemplate({
    required String planId,
  }) async {
    try {
      final result = await dataSource.saveTemplate(planId: planId);
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'saveTemplate in WorkoutManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<void, Failure>> deleteTemplate(
    String id, {
    bool hardDelete = false,
  }) async {
    try {
      final result = await dataSource.deleteTemplate(
        id,
        hardDelete: hardDelete,
      );
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'deleteTemplate in WorkoutManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<ExerciseModel, Failure>> getExerciseDetails(String id) async {
    try {
      final result = await dataSource.getExerciseDetails(id);
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'getExerciseDetails in WorkoutManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<ExerciseModel, Failure>> createExercise({
    required String name,
    required String category,
    required String muscle,
    String? difficulty,
    String? description,
    String? videoUrl,
    String? imageUrl,
  }) async {
    try {
      final result = await dataSource.createExercise(
        imageUrl: imageUrl,
        videoUrl: videoUrl,
        description: description,
        difficulty: difficulty,
        muscle: muscle,
        category: category,
        name: name,
      );
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'createExercise in WorkoutManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<ExerciseModel, Failure>> updateExercise(
    String id, {
    String? name,
    String? category,
    String? muscle,
    String? difficulty,
    String? description,
    String? videoUrl,
    String? imageUrl,
    bool? isActive,
  }) async {
    try {
      final result = await dataSource.updateExercise(
        id,
        isActive: isActive,
        imageUrl: imageUrl,
        videoUrl: videoUrl,
        description: description,
        difficulty: difficulty,
        muscle: muscle,
        category: category,
        name: name,
      );
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'updateExercise in WorkoutManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<AssignWorkoutResponseModel, Failure>> assignWorkout({
    required String planId,
    required List<String> memberIds,
    required String startDate,
    required String endDate,
    bool notifyMembers = true,
  }) async {
    try {
      final result = await dataSource.assignWorkout(
        planId: planId,
        memberIds: memberIds,
        startDate: startDate,
        endDate: endDate,
        notifyMembers: notifyMembers,
      );
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'assignWorkout in WorkoutManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<ResponseModel<PlanListingModel>, Failure>> getAllPlans({
    String? search,
    String? type,
    bool? isTemplate,
    num? page,
    num? limit,
  }) async {
    try {
      final result = await dataSource.getAllPlans(limit: limit);
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'getAllPlans in WorkoutManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<TemplateDetailsModel, Failure>> getPlanDetails(
    String id,
  ) async {
    try {
      final result = await dataSource.getPlanDetails(id);
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'getPlanDetails in WorkoutManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<TemplateDetailsModel, Failure>> createWorkoutPlan({
    required String name,
    String type = 'WEEKLY',
    required String startDate,
    required String endDate,
    bool isTemplate = false,
    List<WorkoutDayInputEntity> days = const [],
  }) async {
    try {
      final daysModel = days
          .map((e) => WorkoutDayInputModel.fromEntity(e))
          .toList();
      final result = await dataSource.createWorkoutPlan(
        name: name,
        type: type,
        startDate: startDate,
        endDate: endDate,
        isTemplate: isTemplate,
        days: daysModel,
      );
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'createWorkoutPlan in WorkoutManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<void, Failure>> deleteWorkoutPlan(String id) async {
    try {
      final result = await dataSource.deleteWorkoutPlan(id);
      return Left(result);
    } catch (e, s) {
      dev_log.log(
        e.toString(),
        name: 'deleteWorkoutPlan in WorkoutManagerRepoImpl',
        stackTrace: s,
        error: e,
      );
      return Right(Failure.fromException(e));
    }
  }

  // @override
  // Future<Either<MyWorkoutsResponseModel, Failure>> getMyWorkouts() async {
  //   try {
  //     final result = await dataSource.getMyWorkouts();
  //     return Left(result);
  //   } catch (e, s) {
  //     dev_log.log(e.toString(), name: 'getMyWorkouts in WorkoutManagerRepoImpl', stackTrace: s, error: e);
  //     return Right(Failure.fromException(e));
  //   }
  // }

  // @override
  // Future<Either<WorkoutWeekModel, Failure>> getWeek({String? weekStart, String? memberId}) async {
  //   try {
  //     final result = await dataSource.getWeek(memberId: memberId);
  //     return Left(result);
  //   } catch (e, s) {
  //     dev_log.log(e.toString(), name: 'getWeek in WorkoutManagerRepoImpl', stackTrace: s, error: e);
  //     return Right(Failure.fromException(e));
  //   }
  // }

  // @override
  // Future<Either<ToggleExerciseResponseModel, Failure>> toggleExercise({
  //   required String date,
  //   required String planExerciseId,
  //   String? memberId,
  // }) async {
  //   try {
  //     final result = await dataSource.toggleExercise(//: //);
  //     return Left(result);
  //   } catch (e, s) {
  //     dev_log.log(e.toString(), name: 'toggleExercise in WorkoutManagerRepoImpl', stackTrace: s, error: e);
  //     return Right(Failure.fromException(e));
  //   }
  // }
}
