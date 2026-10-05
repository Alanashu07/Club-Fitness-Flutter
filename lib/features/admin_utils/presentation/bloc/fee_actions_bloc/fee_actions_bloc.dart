import 'package:club_fitness/config/network/end_points.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/admin_utils_entities.dart';
import '../../../domain/usecase/admin_utils_usecases.dart';

part 'fee_actions_event.dart';
part 'fee_actions_state.dart';

class FeeActionsBloc extends Bloc<FeeActionsEvent, FeeActionsState> {
  final ApproveFees _approveFees;
  final RejectFees _rejectFees;
  FeeActionsBloc(ApproveFees approveFees, RejectFees rejectFees)
    : _approveFees = approveFees,
      _rejectFees = rejectFees,
      super(const FeeActionsInitial(id: '', action: FeeActions.approve)) {
    on<FeeActionsEvent>((event, emit) {});
    on<ApproveFeesEvent>(_onApproveFees);
    on<RejectFeesEvent>(_onRejectFees);
  }

  Future<void> _onApproveFees(
    ApproveFeesEvent event,
    Emitter<FeeActionsState> emit,
  ) async {
    emit(FeeActionsLoading(action: FeeActions.approve, id: event.id));
    final failureOrFees = await _approveFees(event.id);
    failureOrFees.fold(
      (f) => emit(
        FeeActionsSuccess(action: FeeActions.approve, id: event.id, fee: f),
      ),
      (f) => emit(
        FeeActionsFailure(action: FeeActions.approve, id: event.id, failure: f),
      ),
    );
  }

  Future<void> _onRejectFees(
    RejectFeesEvent event,
    Emitter<FeeActionsState> emit,
  ) async {
    emit(FeeActionsLoading(action: FeeActions.reject, id: event.id));
    final failureOrFees = await _rejectFees(event.id);
    failureOrFees.fold(
      (f) => emit(
        FeeActionsSuccess(action: FeeActions.reject, id: event.id, fee: f),
      ),
      (f) => emit(
        FeeActionsFailure(action: FeeActions.reject, id: event.id, failure: f),
      ),
    );
  }
}
