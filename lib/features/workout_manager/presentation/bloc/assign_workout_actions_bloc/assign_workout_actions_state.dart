part of 'assign_workout_actions_bloc.dart';

enum AssignWorkoutStage { creatingPlan, savingTemplate, assigning, creatingExercise }

sealed class AssignWorkoutActionsState extends Equatable {
  const AssignWorkoutActionsState();

  @override
  List<Object?> get props => [];
}

class AssignWorkoutActionsInitial extends AssignWorkoutActionsState {
  const AssignWorkoutActionsInitial();
}

/// Lets the screen show a stage-specific label ("Creating plan…",
/// "Saving template…", "Assigning…") instead of a generic spinner.
class AssignWorkoutActionsInProgress extends AssignWorkoutActionsState {
  final AssignWorkoutStage stage;
  const AssignWorkoutActionsInProgress(this.stage);

  @override
  List<Object?> get props => [stage];
}

class AssignWorkoutActionsSuccess extends AssignWorkoutActionsState {
  final AssignWorkoutResponseEntity response;
  const AssignWorkoutActionsSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class ExerciseCreatedState extends AssignWorkoutActionsState {
  final ExerciseEntity exercise;
  const ExerciseCreatedState(this.exercise);

  @override
  List<Object?> get props => [exercise];
}

class AssignWorkoutActionsFailure extends AssignWorkoutActionsState {
  final Failure failure;
  const AssignWorkoutActionsFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}