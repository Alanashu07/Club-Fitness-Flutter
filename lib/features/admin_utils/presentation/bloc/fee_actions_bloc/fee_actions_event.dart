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
  const RejectFeesEvent(this.id);
  @override
  List<Object> get props => [id];
}