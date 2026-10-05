part of 'member_detail_bloc.dart';

sealed class MemberDetailState extends Equatable {
  const MemberDetailState();
}

final class MemberDetailInitial extends MemberDetailState {
  @override
  List<Object> get props => [];
}

final class MemberDetailLoading extends MemberDetailState {
  const MemberDetailLoading();
  @override
  List<Object?> get props => [];
}

final class MemberDetailSuccess extends MemberDetailState {
  final MemberDetailEntity detail;
  const MemberDetailSuccess(this.detail);
  @override
  List<Object?> get props => [detail];
}

final class MemberDetailFailure extends MemberDetailState {
  final Failure failure;
  const MemberDetailFailure(this.failure);
  @override
  List<Object?> get props => [failure];
}
