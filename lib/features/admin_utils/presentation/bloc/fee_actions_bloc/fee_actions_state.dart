// fee_actions_state.dart
part of 'fee_actions_bloc.dart';

sealed class FeeActionsState extends Equatable {
  final String id;
  final FeeActions action;
  const FeeActionsState({required this.id, required this.action});

  @override
  List<Object?> get props => [id, action];
}

final class FeeActionsInitial extends FeeActionsState {
  const FeeActionsInitial({required super.id, required super.action});
}

final class FeeActionsLoading extends FeeActionsState {
  const FeeActionsLoading({required super.id, required super.action});
}

/// Only the field relevant to the [action] is populated:
/// - fee      → approve, reject, create, update, markPaid, waive, receipt
/// - reminder → remind
/// - message  → delete
/// - pdfBytes → exportPdf
final class FeeActionsSuccess extends FeeActionsState {
  final FeesEntity? fee;
  final String? message;
  final List<int>? pdfBytes;

  const FeeActionsSuccess({
    required super.id,
    required super.action,
    this.fee,
    this.message,
    this.pdfBytes,
  });

  @override
  List<Object?> get props => [...super.props, fee, message, pdfBytes];
}

final class FeeActionsFailure extends FeeActionsState {
  final Failure failure;
  const FeeActionsFailure({
    required super.id,
    required super.action,
    required this.failure,
  });

  @override
  List<Object?> get props => [...super.props, failure];
}