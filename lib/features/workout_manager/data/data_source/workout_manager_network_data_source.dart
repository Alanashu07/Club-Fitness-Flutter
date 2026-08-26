import 'package:club_fitness/config/network/api.dart';
import 'package:club_fitness/core/models/pagination_model.dart';
import 'package:club_fitness/core/utils/utils.dart';

import '../models/workout_manager_models.dart';

abstract interface class WorkoutManagerNetworkDataSource {
  Future<ResponseModel<WorkoutTemplateMiniModel>> getWorkoutTemplates({
    String? search,
    num? page,
    num? limit,
    String? type,
  });
  Future<TemplateDetailsModel> getTemplateDetails(String id);
  Future<ExerciseResponseModel> getExercises({
    String? category,
    String? difficulty,
    String? search,
    num? page,
    num? limit,
  });

  // ---- Templates ----
  Future<TemplateDetailsModel> saveTemplate({required String planId});
  Future<void> deleteTemplate(String id, {bool hardDelete = false});

  // ---- Exercises ----
  Future<ExerciseModel> getExerciseDetails(String id);
  Future<ExerciseModel> createExercise({
    required String name,
    required String category,
    required String muscle,
    String? difficulty,
    String? description,
    String? videoUrl,
    String? imageUrl,
  });
  Future<ExerciseModel> updateExercise(
    String id, {
    String? name,
    String? category,
    String? muscle,
    String? difficulty,
    String? description,
    String? videoUrl,
    String? imageUrl,
    bool? isActive,
  });

  // ---- Assign workout ----
  Future<AssignWorkoutResponseModel> assignWorkout({
    required String planId,
    required List<String> memberIds,
    required String startDate,
    required String endDate,
    bool notifyMembers = true,
  });

  // ---- Plans ----
  Future<ResponseModel<PlanListingModel>> getAllPlans({
    String? search,
    String? type,
    bool? isTemplate,
    num? page,
    num? limit,
  });
  Future<TemplateDetailsModel> getPlanDetails(String id);
  Future<TemplateDetailsModel> createWorkoutPlan({
    required String name,
    String type = 'WEEKLY',
    required String startDate,
    required String endDate,
    bool isTemplate = false,
    List<WorkoutDayInputModel> days = const [],
  });
  Future<void> deleteWorkoutPlan(String id);

  // ---- Member workouts ----
  // Future<MyWorkoutsResponseModel> getMyWorkouts();
  // Future<WorkoutWeekModel> getWeek({String? weekStart, String? memberId});
  // Future<ToggleExerciseResponseModel> toggleExercise({
  //   required String date,
  //   required String planExerciseId,
  //   String? memberId,
  // });
}

class WorkoutManagerNetworkDataSourceImpl
    implements WorkoutManagerNetworkDataSource {
  final DioConfig _dio;

  const WorkoutManagerNetworkDataSourceImpl(this._dio);

  @override
  Future<TemplateDetailsModel> getTemplateDetails(String id) async {
    DioResponse response = await _dio.dioGetCall(
      EndPoints.workoutTemplateDetails(id),
    );
    if (response.hasError) return response.handleError();
    return TemplateDetailsModel.fromJson(response.response!.data);
  }

  @override
  Future<ResponseModel<WorkoutTemplateMiniModel>> getWorkoutTemplates({
    String? search,
    num? page,
    num? limit,
    String? type,
  }) async {
    final queryParams = {
      'search': search,
      'page': page,
      'limit': limit,
      'type': type,
    }.clean();
    String url = EndPoints.workoutTemplates;
    if (queryParams.isNotEmpty) {
      url += '?${queryParams.filterQueryParams}';
    }
    DioResponse response = await _dio.dioGetCall(url);
    if (response.hasError) return response.handleError();
    return ResponseModel.fromJson(
      response.response!.data,
      key: 'templates',
      fromJson: WorkoutTemplateMiniModel.fromJson,
    );
  }

  @override
  Future<ExerciseResponseModel> getExercises({
    String? category,
    String? difficulty,
    String? search,
    num? page,
    num? limit,
  }) async {
    final queryParams = {
      'category': category,
      'difficulty': difficulty,
      'search': search,
      'page': page,
      'limit': limit,
    }.clean();
    String url = EndPoints.exercises;
    if (queryParams.isNotEmpty) {
      url += '?${queryParams.filterQueryParams}';
    }
    DioResponse response = await _dio.dioGetCall(url);
    if (response.hasError) return response.handleError();
    return ExerciseResponseModel.fromJson(response.response!.data);
  }

  // ---- Templates ----

  @override
  Future<TemplateDetailsModel> saveTemplate({required String planId}) async {
    DioResponse response = await _dio.dioPostCall(EndPoints.workoutTemplates, {
      'planId': planId,
    });
    if (response.hasError) return response.handleError();
    return TemplateDetailsModel.fromJson(response.response!.data['plan'] ?? {});
  }

  @override
  Future<void> deleteTemplate(String id, {bool hardDelete = false}) async {
    String url = EndPoints.workoutTemplateDetails(id);
    if (hardDelete) {
      url += '?hardDelete=true';
    }
    DioResponse response = await _dio.dioDeleteCall(url);
    if (response.hasError) return response.handleError();
  }

  // ---- Exercises ----

  @override
  Future<ExerciseModel> getExerciseDetails(String id) async {
    DioResponse response = await _dio.dioGetCall(EndPoints.exerciseDetails(id));
    if (response.hasError) return response.handleError();
    return ExerciseModel.fromJson(response.response!.data);
  }

  @override
  Future<ExerciseModel> createExercise({
    required String name,
    required String category,
    required String muscle,
    String? difficulty,
    String? description,
    String? videoUrl,
    String? imageUrl,
  }) async {
    final body = {
      'name': name,
      'category': category,
      'muscle': muscle,
      'difficulty': difficulty,
      'description': description,
      'videoUrl': videoUrl,
      'imageUrl': imageUrl,
    }.clean();
    DioResponse response = await _dio.dioPostCall(
      EndPoints.exercises,
      body,
    );
    if (response.hasError) return response.handleError();
    return ExerciseModel.fromJson(response.response!.data);
  }

  @override
  Future<ExerciseModel> updateExercise(
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
    final body = {
      'name': name,
      'category': category,
      'muscle': muscle,
      'difficulty': difficulty,
      'description': description,
      'videoUrl': videoUrl,
      'imageUrl': imageUrl,
      'isActive': isActive,
    }.clean();
    DioResponse response = await _dio.dioPutCall(
      EndPoints.exerciseDetails(id),
      body,
    );
    if (response.hasError) return response.handleError();
    return ExerciseModel.fromJson(response.response!.data);
  }

  // ---- Assign workout ----

  @override
  Future<AssignWorkoutResponseModel> assignWorkout({
    required String planId,
    required List<String> memberIds,
    required String startDate,
    required String endDate,
    bool notifyMembers = true,
  }) async {
    DioResponse response = await _dio.dioPostCall(
      EndPoints.assignWorkout,
      {
        'planId': planId,
        'memberIds': memberIds,
        'startDate': startDate,
        'endDate': endDate,
        'notifyMembers': notifyMembers,
      },
    );
    if (response.hasError) return response.handleError();
    return AssignWorkoutResponseModel.fromJson(response.response!.data);
  }

  // ---- Plans ----

  @override
  Future<ResponseModel<PlanListingModel>> getAllPlans({
    String? search,
    String? type,
    bool? isTemplate,
    num? page,
    num? limit,
  }) async {
    final queryParams = {
      'search': search,
      'type': type,
      'isTemplate': isTemplate,
      'page': page,
      'limit': limit,
    }.clean();
    String url = EndPoints.workoutPlans;
    if (queryParams.isNotEmpty) {
      url += '?${queryParams.filterQueryParams}';
    }
    DioResponse response = await _dio.dioGetCall(url);
    if (response.hasError) return response.handleError();
    return ResponseModel.fromJson(response.response!.data, key: 'plans', fromJson: PlanListingModel.fromJson);
  }

  @override
  Future<TemplateDetailsModel> getPlanDetails(String id) async {
    DioResponse response = await _dio.dioGetCall(
      EndPoints.workoutPlanDetails(id),
    );
    if (response.hasError) return response.handleError();
    return TemplateDetailsModel.fromJson(response.response!.data);
  }

  @override
  Future<TemplateDetailsModel> createWorkoutPlan({
    required String name,
    String type = 'WEEKLY',
    required String startDate,
    required String endDate,
    bool isTemplate = false,
    List<WorkoutDayInputModel> days = const [],
  }) async {
    DioResponse response = await _dio.dioPostCall(
      EndPoints.workoutPlans,
      {
        'name': name,
        'type': type,
        'startDate': startDate,
        'endDate': endDate,
        'isTemplate': isTemplate,
        'days': days.map((d) => d.toJson()).toList(),
      },
    );
    if (response.hasError) return response.handleError();
    return TemplateDetailsModel.fromJson(response.response!.data);
  }

  @override
  Future<void> deleteWorkoutPlan(String id) async {
    DioResponse response = await _dio.dioDeleteCall(
      EndPoints.workoutPlanDetails(id),
    );
    if (response.hasError) return response.handleError();
  }

  // ---- Member workouts ----

  // @override
  // Future<MyWorkoutsResponseModel> getMyWorkouts() async {
  //   DioResponse response = await _dio.dioGetCall(EndPoints.myWorkouts);
  //   if (response.hasError) return response.handleError();
  //   return MyWorkoutsResponseModel.fromJson(response.response!.data);
  // }

  // @override
  // Future<WorkoutWeekModel> getWeek({String? weekStart, String? memberId}) async {
  //   final queryParams = {
  //     'weekStart': weekStart,
  //     'memberId': memberId,
  //   }.clean();
  //   String url = EndPoints.workoutWeek;
  //   if (queryParams.isNotEmpty) {
  //     url += '?${queryParams.filterQueryParams}';
  //   }
  //   DioResponse response = await _dio.dioGetCall(url);
  //   if (response.hasError) return response.handleError();
  //   return WorkoutWeekModel.fromJson(response.response!.data);
  // }

  // @override
  // Future<ToggleExerciseResponseModel> toggleExercise({
  //   required String date,
  //   required String planExerciseId,
  //   String? memberId,
  // }) async {
  //   DioResponse response = await _dio.dioPostCall(
  //     EndPoints.toggleExercise(date, planExerciseId),
  //     data: {'memberId': memberId}.clean(),
  //   );
  //   if (response.hasError) return response.handleError();
  //   return ToggleExerciseResponseModel.fromJson(response.response!.data);
  // }
}
