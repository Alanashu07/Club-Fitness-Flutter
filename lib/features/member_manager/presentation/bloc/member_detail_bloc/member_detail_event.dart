part of 'member_detail_bloc.dart';

sealed class MemberDetailEvent extends Equatable {
  const MemberDetailEvent();
}

final class GetMemberDetailsEvent extends MemberDetailEvent {
  final String memberId;
  const GetMemberDetailsEvent(this.memberId);
  @override
  List<Object?> get props => [memberId];
}