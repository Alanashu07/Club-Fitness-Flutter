import 'package:club_fitness/core/entities/pagination_entity.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/features/workout_manager/workout_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'assign_workout_event.dart';
part 'assign_workout_state.dart';

class AssignWorkoutBloc extends Bloc<AssignWorkoutEvent, AssignWorkoutState> {
  final GetExercises _getExercises;
  final GetTemplateDetails _getTemplateDetails;
  final GetWorkoutTemplates _getWorkoutTemplates;
  AssignWorkoutBloc(
    GetExercises getExercises,
    GetTemplateDetails getTemplateDetails,
    GetWorkoutTemplates getWorkoutTemplates,
  ) : _getExercises = getExercises,
      _getTemplateDetails = getTemplateDetails,
      _getWorkoutTemplates = getWorkoutTemplates,
      super(
        const AssignWorkoutInitial(
          exercise: ExerciseResponseEntity(),
          templates: [],
        ),
      ) {
    on<AssignWorkoutEvent>((event, emit) {});
    on<GetAllExercisesEvent>(_onGetAllExercises);
    on<GetWorkoutTemplatesEvent>(_onGetWorkoutTemplates);
    on<GetTemplateDetailsEvent>(_onGetTemplateDetails);
  }

  PaginationEntity? _exercisePagination;
  PaginationEntity? _templatePagination;

  Future<void> _onGetAllExercises(
    GetAllExercisesEvent event,
    Emitter<AssignWorkoutState> emit,
  ) async {
    if (event.isLoadMore) {
      bool skip = BlocLoadMoreSkipper.skipLoadMore(
        hasMore: _exercisePagination?.hasNextPage ?? false,
        isFailureState: state is ExerciseLoadMoreFailureState,
        isAlreadyLoadingState: state is ExerciseLoadingState,
        onResultEnded: () => emit(
          ExerciseLoadMoreFailureState(
            exercise: state.exercise,
            templates: state.templates,
            selectedTemplate: state.selectedTemplate,
            failure: Failure.endOfResult,
          ),
        ),
      );
      if (skip) return;
    }
    emit(
      ExerciseLoadingState(
        exercise: state.exercise,
        templates: state.templates,
        selectedTemplate: state.selectedTemplate,
      ),
    );
    final params = GetExercisesParams(
      category: event.category,
      difficulty: event.difficulty,
      page: event.isLoadMore ? _exercisePagination?.nextPage : null,
      limit: event.limit,
      search: event.search,
    );
    final result = await _getExercises(params);
    result.fold(
      (r) {
        _exercisePagination = r.pagination;
        ExerciseResponseEntity exercise;
        if (event.isLoadMore) {
          exercise = state.exercise;
          exercise.exercises.addAll(r.exercises);
        } else {
          exercise = r;
        }
        emit(
          AssignWorkoutLoadedState(
            exercise: exercise,
            templates: state.templates,
            selectedTemplate: state.selectedTemplate,
          ),
        );
      },
      (l) => emit(
        AssignWorkoutFailureState(
          exercise: state.exercise,
          templates: state.templates,
          selectedTemplate: state.selectedTemplate,
          failure: l,
        ),
      ),
    );
  }

  Future<void> _onGetWorkoutTemplates(
    GetWorkoutTemplatesEvent event,
    Emitter<AssignWorkoutState> emit,
  ) async {
    emit(
      WorkoutTemplateLoadingState(
        exercise: state.exercise,
        templates: state.templates,
        selectedTemplate: state.selectedTemplate,
      ),
    );
    final params = GetWorkoutTemplatesParams(
      page: event.isLoadMore ? _templatePagination?.nextPage : null,
      limit: event.limit,
      search: event.search,
      type: event.type,
    );
    final result = await _getWorkoutTemplates(params);
    result.fold(
      (r) {
        _templatePagination = r.pagination;
        List<WorkoutTemplateMiniEntity> templates;
        if (event.isLoadMore) {
          templates = state.templates;
          templates.addAll(r.data);
        } else {
          templates = r.data;
        }
        emit(
          AssignWorkoutLoadedState(
            exercise: state.exercise,
            templates: templates,
            selectedTemplate: state.selectedTemplate,
          ),
        );
      },
      (l) => emit(
        AssignWorkoutFailureState(
          exercise: state.exercise,
          templates: state.templates,
          selectedTemplate: state.selectedTemplate,
          failure: l,
        ),
      ),
    );
  }

  Future<void> _onGetTemplateDetails(
    GetTemplateDetailsEvent event,
    Emitter<AssignWorkoutState> emit,
  ) async {
    emit(
      SelectedTemplateLoadingState(
        exercise: state.exercise,
        templates: state.templates,
        selectedTemplate: state.selectedTemplate,
      ),
    );
    final result = await _getTemplateDetails(event.templateId);
    result.fold(
      (r) => emit(
        AssignWorkoutLoadedState(
          exercise: state.exercise,
          templates: state.templates,
          selectedTemplate: r,
        ),
      ),
      (l) => emit(
        AssignWorkoutFailureState(
          exercise: state.exercise,
          templates: state.templates,
          selectedTemplate: state.selectedTemplate,
          failure: l,
        ),
      ),
    );
  }
}
