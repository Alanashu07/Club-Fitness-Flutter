part of 'members_actions_bloc.dart';

sealed class MembersActionsState extends Equatable {
  const MembersActionsState();
}

final class MembersActionsInitial extends MembersActionsState {
  @override
  List<Object> get props => [];
}

final class CreateMemberLoadingState extends MembersActionsState {
  @override
  List<Object> get props => [];
}

final class CreateMemberSuccessState extends MembersActionsState {
  final MemberListEntity member;

  const CreateMemberSuccessState(this.member);
  @override
  List<Object> get props => [member];
}

final class CreateMemberFailureState extends MembersActionsState {
  final Failure failure;

  const CreateMemberFailureState(this.failure);
  @override
  List<Object> get props => [failure];
}
