// fee_actions_event.dart
part of 'fee_actions_bloc.dart';

sealed class FeeActionsEvent extends Equatable {
  const FeeActionsEvent();
}

final class ApproveFeesEvent extends FeeActionsEvent {
  final String id;
  const ApproveFeesEvent(this.id);
  @override
  List<Object> get props => [id];
}

final class RejectFeesEvent extends FeeActionsEvent {
  final String id;
  final String? reason;
  const RejectFeesEvent(this.id, {this.reason});
  @override
  List<Object?> get props => [id, reason];
}

final class CreateFeeEvent extends FeeActionsEvent {
  final String memberId;
  final String dueDate;
  final String? planId;
  final double? amount;
  final String? status;
  final double? paidAmount;
  final String? paymentMethod;
  final String? notes;
  const CreateFeeEvent({
    required this.memberId,
    required this.dueDate,
    this.planId,
    this.amount,
    this.status,
    this.paidAmount,
    this.paymentMethod,
    this.notes,
  });
  @override
  List<Object?> get props => [
    memberId,
    dueDate,
    planId,
    amount,
    status,
    paidAmount,
    paymentMethod,
    notes,
  ];
}

final class UpdateFeeEvent extends FeeActionsEvent {
  final String id;
  final double? amount;
  final String? dueDate;
  final String? planId;
  final String? notes;
  const UpdateFeeEvent(
    this.id, {
    this.amount,
    this.dueDate,
    this.planId,
    this.notes,
  });
  @override
  List<Object?> get props => [id, amount, dueDate, planId, notes];
}

final class MarkFeePaidEvent extends FeeActionsEvent {
  final String id;
  final double amountReceived;
  final String method;
  final String? notes;
  const MarkFeePaidEvent(
    this.id, {
    required this.amountReceived,
    required this.method,
    this.notes,
  });
  @override
  List<Object?> get props => [id, amountReceived, method, notes];
}

final class WaiveFeeEvent extends FeeActionsEvent {
  final String id;
  final String? reason;
  const WaiveFeeEvent(this.id, {this.reason});
  @override
  List<Object?> get props => [id, reason];
}

final class AttachReceiptEvent extends FeeActionsEvent {
  final String id;
  final String? receiptFilePath;
  final String? receiptUrl;
  const AttachReceiptEvent(this.id, {this.receiptFilePath, this.receiptUrl});
  @override
  List<Object?> get props => [id, receiptFilePath, receiptUrl];
}

final class DeleteFeeEvent extends FeeActionsEvent {
  final String id;
  const DeleteFeeEvent(this.id);
  @override
  List<Object> get props => [id];
}

final class ExportFeesPdfEvent extends FeeActionsEvent {
  final String? search;
  final String? status;
  final String? memberId;
  final String? planId;
  final String? sortBy;
  const ExportFeesPdfEvent({
    this.search,
    this.status,
    this.memberId,
    this.planId,
    this.sortBy,
  });
  @override
  List<Object?> get props => [search, status, memberId, planId, sortBy];
}

final class ResetFeeActionsEvent extends FeeActionsEvent {
  const ResetFeeActionsEvent();
  @override
  List<Object> get props => [];
}