import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/workout_manager_entities.dart';
import '../../../domain/usecase/workout_manager_usecases.dart';

part 'assign_workout_actions_event.dart';
part 'assign_workout_actions_state.dart';

class AssignWorkoutActionsBloc
    extends Bloc<AssignWorkoutActionsEvent, AssignWorkoutActionsState> {
  final CreateWorkoutPlan _createWorkoutPlan;
  final SaveTemplate _saveTemplate;
  final AssignWorkout _assignWorkout;
  final CreateExercise _createExercise;
  AssignWorkoutActionsBloc(
    this._assignWorkout,
    this._createWorkoutPlan,
    this._saveTemplate,
    this._createExercise,
  ) : super(const AssignWorkoutActionsInitial()) {
    on<SubmitWorkoutAssignmentEvent>(_onSubmit);
    on<ResetAssignWorkoutActionsEvent>(
      (event, emit) => emit(const AssignWorkoutActionsInitial()),
    );
    on<CreateExerciseEvent>(_onCreateExercise);
  }

  Future<void> _onSubmit(
    SubmitWorkoutAssignmentEvent event,
    Emitter<AssignWorkoutActionsState> emit,
  ) async {
    emit(const AssignWorkoutActionsInProgress(AssignWorkoutStage.creatingPlan));
    final planParams = CreateWorkoutPlanParams(
      name: event.name,
      startDate: event.startDate.toIso8601String(),
      endDate: event.endDate.toIso8601String(),
      isTemplate: false,
      type: event.type,
      days: event.days,
    );
    final planResult = await _createWorkoutPlan(planParams);
    bool planSuccess = false;
    TemplateDetailsEntity? plan;
    planResult.fold(
      (l) {
        planSuccess = true;
        plan = l;
      },
      (failure) {
        planSuccess = false;
        emit(AssignWorkoutActionsFailure(failure));
        return;
      },
    );
    if (!planSuccess || plan == null) return;
    if (event.saveAsNewTemplate) {
      emit(
        const AssignWorkoutActionsInProgress(AssignWorkoutStage.savingTemplate),
      );
      // saveTemplate flips isTemplate=true on an *existing* plan id.
      final saveParams = SaveTemplateParams(planId: plan!.id);

      await _saveTemplate(saveParams);
    }
    emit(const AssignWorkoutActionsInProgress(AssignWorkoutStage.assigning));
    final params = AssignWorkoutParams(
      planId: plan!.id,
      memberIds: event.memberIds,
      startDate: event.startDate.toIso8601String(),
      endDate: event.endDate.toIso8601String(),
      notifyMembers: event.notifyMembers,
    );
    final result = await _assignWorkout(params);
    result.fold(
      (l) => emit(AssignWorkoutActionsSuccess(l)),
      (r) => emit(AssignWorkoutActionsFailure(r)),
    );
  }

  Future<void> _onCreateExercise(
    CreateExerciseEvent event,
    Emitter<AssignWorkoutActionsState> emit,
  ) async {
    emit(
      const AssignWorkoutActionsInProgress(AssignWorkoutStage.creatingExercise),
    );
    final params = CreateExerciseParams(
      category: event.category,
      difficulty: event.difficulty,
      name: event.name,
      muscle: event.muscle,
      description: event.description,
      videoUrl: event.videoUrl,
      imageUrl: event.imageUrl,
    );
    final result = await _createExercise(params);
    result.fold(
      (l) => emit(ExerciseCreatedState(l)),
      (r) => emit(AssignWorkoutActionsFailure(r)),
    );
  }
}
