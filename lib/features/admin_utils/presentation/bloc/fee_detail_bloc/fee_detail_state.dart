part of 'fee_detail_bloc.dart';

sealed class FeeDetailState extends Equatable {
  const FeeDetailState();
}

final class FeeDetailInitial extends FeeDetailState {

  @override
  List<Object> get props => [];
}

final class FeeDetailLoadingState extends FeeDetailState {
  @override
  List<Object> get props => [];
}

final class FeeDetailSuccessState extends FeeDetailState {
  final FeeDetailEntity detail;
  const FeeDetailSuccessState(this.detail);
  @override
  List<Object> get props => [detail];
}

final class FeeDetailFailureState extends FeeDetailState {
  final Failure failure;
  const FeeDetailFailureState(this.failure);
  @override
  List<Object> get props => [failure];
}