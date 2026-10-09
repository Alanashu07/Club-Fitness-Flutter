// fee_actions_bloc.dart
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
  final CreateFee _createFee;
  final UpdateFee _updateFee;
  final MarkFeePaid _markFeePaid;
  final WaiveFee _waiveFee;
  final AttachReceipt _attachReceipt;
  final DeleteFee _deleteFee;
  final ExportFeesPdf _exportFeesPdf;

  FeeActionsBloc(
    ApproveFees approveFees,
    RejectFees rejectFees,
    CreateFee createFee,
    UpdateFee updateFee,
    MarkFeePaid markFeePaid,
    WaiveFee waiveFee,
    AttachReceipt attachReceipt,
    DeleteFee deleteFee,
    ExportFeesPdf exportFeesPdf,
  ) : _approveFees = approveFees,
      _rejectFees = rejectFees,
      _createFee = createFee,
      _updateFee = updateFee,
      _markFeePaid = markFeePaid,
      _waiveFee = waiveFee,
      _attachReceipt = attachReceipt,
      _deleteFee = deleteFee,
      _exportFeesPdf = exportFeesPdf,
      super(const FeeActionsInitial(id: '', action: FeeActions.approve)) {
    on<ApproveFeesEvent>(_onApproveFees);
    on<RejectFeesEvent>(_onRejectFees);
    on<CreateFeeEvent>(_onCreateFee);
    on<UpdateFeeEvent>(_onUpdateFee);
    on<MarkFeePaidEvent>(_onMarkFeePaid);
    on<WaiveFeeEvent>(_onWaiveFee);
    on<AttachReceiptEvent>(_onAttachReceipt);
    on<DeleteFeeEvent>(_onDeleteFee);
    on<ExportFeesPdfEvent>(_onExportFeesPdf);
    on<ResetFeeActionsEvent>(
      (event, emit) =>
          emit(const FeeActionsInitial(id: '', action: FeeActions.approve)),
    );
  }

  // Either<Failure, T>: left = failure, right = success.
  // (The original fold had these two swapped.)
  void _emitFee(
    Emitter<FeeActionsState> emit,
    FeeActions action,
    String id,
    dynamic failureOrFee,
  ) {
    failureOrFee.fold(
      (fee) => emit(FeeActionsSuccess(action: action, id: id, fee: fee)),
      (f) => emit(FeeActionsFailure(action: action, id: id, failure: f)),
    );
  }

  Future<void> _onApproveFees(
    ApproveFeesEvent event,
    Emitter<FeeActionsState> emit,
  ) async {
    emit(FeeActionsLoading(action: FeeActions.approve, id: event.id));
    final result = await _approveFees(event.id);
    _emitFee(emit, FeeActions.approve, event.id, result);
  }

  Future<void> _onRejectFees(
    RejectFeesEvent event,
    Emitter<FeeActionsState> emit,
  ) async {
    emit(FeeActionsLoading(action: FeeActions.reject, id: event.id));
    final result = await _rejectFees(
      RejectFeesParams(id: event.id, reason: event.reason),
    );
    _emitFee(emit, FeeActions.reject, event.id, result);
  }

  Future<void> _onCreateFee(
    CreateFeeEvent event,
    Emitter<FeeActionsState> emit,
  ) async {
    emit(const FeeActionsLoading(action: FeeActions.create, id: ''));
    final result = await _createFee(
      CreateFeeParams(
        memberId: event.memberId,
        dueDate: event.dueDate,
        planId: event.planId,
        amount: event.amount,
        status: event.status,
        paidAmount: event.paidAmount,
        paymentMethod: event.paymentMethod,
        notes: event.notes,
      ),
    );
    _emitFee(emit, FeeActions.create, '', result);
  }

  Future<void> _onUpdateFee(
    UpdateFeeEvent event,
    Emitter<FeeActionsState> emit,
  ) async {
    emit(FeeActionsLoading(action: FeeActions.update, id: event.id));
    final result = await _updateFee(
      UpdateFeeParams(
        id: event.id,
        amount: event.amount,
        dueDate: event.dueDate,
        planId: event.planId,
        notes: event.notes,
      ),
    );
    _emitFee(emit, FeeActions.update, event.id, result);
  }

  Future<void> _onMarkFeePaid(
    MarkFeePaidEvent event,
    Emitter<FeeActionsState> emit,
  ) async {
    emit(FeeActionsLoading(action: FeeActions.markPaid, id: event.id));
    final result = await _markFeePaid(
      MarkFeePaidParams(
        id: event.id,
        amountReceived: event.amountReceived,
        method: event.method,
        notes: event.notes,
      ),
    );
    _emitFee(emit, FeeActions.markPaid, event.id, result);
  }

  Future<void> _onWaiveFee(
    WaiveFeeEvent event,
    Emitter<FeeActionsState> emit,
  ) async {
    emit(FeeActionsLoading(action: FeeActions.waive, id: event.id));
    final result = await _waiveFee(
      WaiveFeeParams(id: event.id, reason: event.reason),
    );
    _emitFee(emit, FeeActions.waive, event.id, result);
  }

  Future<void> _onAttachReceipt(
    AttachReceiptEvent event,
    Emitter<FeeActionsState> emit,
  ) async {
    emit(FeeActionsLoading(action: FeeActions.receipt, id: event.id));
    final result = await _attachReceipt(
      AttachReceiptParams(
        id: event.id,
        receiptFilePath: event.receiptFilePath,
        receiptUrl: event.receiptUrl,
      ),
    );
    _emitFee(emit, FeeActions.receipt, event.id, result);
  }

  Future<void> _onDeleteFee(
    DeleteFeeEvent event,
    Emitter<FeeActionsState> emit,
  ) async {
    emit(FeeActionsLoading(action: FeeActions.delete, id: event.id));
    final result = await _deleteFee(event.id);
    result.fold(
      (message) => emit(
        FeeActionsSuccess(
          action: FeeActions.delete,
          id: event.id,
          message: message,
        ),
      ),
      (f) => emit(
        FeeActionsFailure(action: FeeActions.delete, id: event.id, failure: f),
      ),
    );
  }

  Future<void> _onExportFeesPdf(
    ExportFeesPdfEvent event,
    Emitter<FeeActionsState> emit,
  ) async {
    emit(const FeeActionsLoading(action: FeeActions.export, id: ''));
    final result = await _exportFeesPdf(
      ExportFeesPdfParams(
        search: event.search,
        status: event.status,
        memberId: event.memberId,
        planId: event.planId,
        sortBy: event.sortBy,
      ),
    );
    result.fold(
      (bytes) => emit(
        FeeActionsSuccess(action: FeeActions.export, id: '', pdfBytes: bytes),
      ),
      (f) => emit(
        FeeActionsFailure(action: FeeActions.export, id: '', failure: f),
      ),
    );
  }
}
