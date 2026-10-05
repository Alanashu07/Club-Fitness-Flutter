part of 'fee_actions_bloc.dart';

sealed class FeeActionsState extends Equatable {
  final String id;
  final FeeActions action;
  const FeeActionsState({required this.id, required this.action});

  @override
  List<Object> get props => [id, action];
}

final class FeeActionsInitial extends FeeActionsState {
  const FeeActionsInitial({required super.id, required super.action});
}

final class FeeActionsLoading extends FeeActionsState {
  const FeeActionsLoading({required super.id, required super.action});
}

final class FeeActionsSuccess extends FeeActionsState {
  final FeesEntity fee;
  const FeeActionsSuccess({required super.id, required super.action, required this.fee});

  @override
  List<Object> get props => [...super.props, fee];
}

final class FeeActionsFailure extends FeeActionsState {
  final Failure failure;
  const FeeActionsFailure({
    required super.id,
    required super.action,
    required this.failure,
  });

  @override
  List<Object> get props => [...super.props, failure];
}
