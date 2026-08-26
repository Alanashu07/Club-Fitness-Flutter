part of 'assign_workout_actions_bloc.dart';

sealed class AssignWorkoutActionsEvent extends Equatable {
  const AssignWorkoutActionsEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once, from the wizard's final "Assign Workout" tap.
/// [days] should already be fully built (see `_buildDaysPayload` on the
/// screen) — this bloc doesn't know about `_WorkoutDay`/`_PlanExercise`.
class SubmitWorkoutAssignmentEvent extends AssignWorkoutActionsEvent {
  final String name;
  final String type; // 'DAILY' | 'WEEKLY'
  final DateTime startDate;
  final DateTime endDate;
  final List<WorkoutDayInputEntity> days;
  final List<String> memberIds;
  final bool notifyMembers;
  final bool saveAsNewTemplate;

  const SubmitWorkoutAssignmentEvent({
    required this.name,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.memberIds,
    this.notifyMembers = true,
    this.saveAsNewTemplate = false,
  });

  @override
  List<Object?> get props => [
    name,
    type,
    startDate,
    endDate,
    days,
    memberIds,
    notifyMembers,
    saveAsNewTemplate,
  ];
}

/// Clears a terminal (success/failure) state, e.g. after the screen has
/// shown its dialog/snackbar and popped, or if the user wants to retry
/// from a clean slate.
class ResetAssignWorkoutActionsEvent extends AssignWorkoutActionsEvent {
  const ResetAssignWorkoutActionsEvent();
}

class CreateExerciseEvent extends AssignWorkoutActionsEvent {
  final String name;
  final String category;
  final String muscle;
  final String? difficulty;
  final String? description;
  final String? videoUrl;
  final String? imageUrl;

  const CreateExerciseEvent({
    required this.name,
    required this.category,
    required this.muscle,
    this.difficulty,
    this.description,
    this.videoUrl,
    this.imageUrl,
  });
}