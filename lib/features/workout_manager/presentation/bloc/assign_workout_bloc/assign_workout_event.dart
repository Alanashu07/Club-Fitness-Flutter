part of 'assign_workout_bloc.dart';

sealed class AssignWorkoutEvent extends Equatable {
  const AssignWorkoutEvent();
}

final class GetAllExercisesEvent extends AssignWorkoutEvent {
  final String? category;
  final String? difficulty;
  final String? search;
  final num? limit;
  final bool isLoadMore;
  const GetAllExercisesEvent({
    this.category,
    this.difficulty,
    this.search,
    this.limit,
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props => [category, difficulty, search, limit, isLoadMore];
}

final class GetWorkoutTemplatesEvent extends AssignWorkoutEvent {
  final String? search;
  final num? limit;
  final String? type;
  final bool isLoadMore;
  const GetWorkoutTemplatesEvent({this.search, this.limit, this.type, this.isLoadMore = false});

  @override
  List<Object?> get props => [search, limit, type, isLoadMore];
}

final class GetTemplateDetailsEvent extends AssignWorkoutEvent {
  final String templateId;
  const GetTemplateDetailsEvent(this.templateId);

  @override
  List<Object?> get props => [templateId];
}
