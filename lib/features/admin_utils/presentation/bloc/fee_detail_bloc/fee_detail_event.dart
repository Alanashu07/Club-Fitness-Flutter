part of 'fee_detail_bloc.dart';

sealed class FeeDetailEvent extends Equatable {
  const FeeDetailEvent();
}

final class GetFeeDetailEvent extends FeeDetailEvent {
  final String id;
  const GetFeeDetailEvent(this.id);
  @override
  List<Object?> get props => [id];
}