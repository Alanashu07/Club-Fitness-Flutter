part of 'assign_workout_bloc.dart';

sealed class AssignWorkoutState extends Equatable {
  final List<WorkoutTemplateMiniEntity> templates;
  final TemplateDetailsEntity? selectedTemplate;
  final ExerciseResponseEntity exercise;
  const AssignWorkoutState({
    required this.templates,
    this.selectedTemplate,
    required this.exercise,
  });

  @override
  List<Object?> get props => [templates, selectedTemplate, exercise];
}

final class AssignWorkoutInitial extends AssignWorkoutState {
  const AssignWorkoutInitial({
    required super.templates,
    super.selectedTemplate,
    required super.exercise,
  });
}

final class AssignWorkoutLoadingState extends AssignWorkoutState {
  const AssignWorkoutLoadingState({
    required super.templates,
    super.selectedTemplate,
    required super.exercise,
  });
}

final class WorkoutTemplateLoadingState extends AssignWorkoutState {
  const WorkoutTemplateLoadingState({
    required super.templates,
    super.selectedTemplate,
    required super.exercise,
  });
}

final class WorkoutTemplateLoadMoreFailureState extends AssignWorkoutState {
  final Failure failure;
  const WorkoutTemplateLoadMoreFailureState({
    required super.templates,
    super.selectedTemplate,
    required super.exercise,
    required this.failure,
  });

  @override
  List<Object?> get props => [...super.props, failure];
}

final class SelectedTemplateLoadingState extends AssignWorkoutState {
  const SelectedTemplateLoadingState({
    required super.templates,
    super.selectedTemplate,
    required super.exercise,
  });
}

final class ExerciseLoadingState extends AssignWorkoutState {
  const ExerciseLoadingState({
    required super.templates,
    super.selectedTemplate,
    required super.exercise,
  });
}

final class ExerciseLoadMoreFailureState extends AssignWorkoutState {
  final Failure failure;
  const ExerciseLoadMoreFailureState({
    required super.templates,
    super.selectedTemplate,
    required super.exercise,
    required this.failure,
  });

  @override
  List<Object?> get props => [...super.props, failure];
}

final class AssignWorkoutLoadedState extends AssignWorkoutState {
  const AssignWorkoutLoadedState({
    required super.templates,
    super.selectedTemplate,
    required super.exercise,
  });
}

final class AssignWorkoutFailureState extends AssignWorkoutState {
  final Failure failure;

  const AssignWorkoutFailureState({
    required super.templates,
    super.selectedTemplate,
    required super.exercise,
    required this.failure,
  });
  @override
  List<Object?> get props => [...super.props, failure];
}
