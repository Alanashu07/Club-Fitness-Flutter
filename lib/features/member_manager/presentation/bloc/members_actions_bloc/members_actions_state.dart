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

final class UpdateMemberLoadingState extends MembersActionsState {
  @override
  List<Object> get props => [];
}

final class UpdateMemberSuccessState extends MembersActionsState {
  final MemberListEntity member;

  const UpdateMemberSuccessState(this.member);
  @override
  List<Object> get props => [member];
}

final class UpdateMemberFailureState extends MembersActionsState {
  final Failure failure;

  const UpdateMemberFailureState(this.failure);
  @override
  List<Object> get props => [failure];
}

final class SuspendMemberLoadingState extends MembersActionsState {
  @override
  List<Object> get props => [];
}

final class SuspendMemberSuccessState extends MembersActionsState {
  final String id;
  final String message;

  const SuspendMemberSuccessState(this.id, this.message);

  @override
  List<Object> get props => [id, message];
}

final class SuspendMemberFailureState extends MembersActionsState {
  final Failure failure;

  const SuspendMemberFailureState(this.failure);

  @override
  List<Object> get props => [failure];
}

final class ReactivateMemberLoadingState extends MembersActionsState {
  @override
  List<Object> get props => [];
}

final class ReactivateMemberSuccessState extends MembersActionsState {
  final String id;
  final String message;

  const ReactivateMemberSuccessState(this.id, this.message);

  @override
  List<Object> get props => [id, message];
}

final class ReactivateMemberFailureState extends MembersActionsState {
  final Failure failure;

  const ReactivateMemberFailureState(this.failure);

  @override
  List<Object> get props => [failure];
}

final class DeleteMemberLoadingState extends MembersActionsState {
  @override
  List<Object> get props => [];
}

final class DeleteMemberSuccessState extends MembersActionsState {
  final String id;
  final String message;

  const DeleteMemberSuccessState({required this.id, required this.message});

  @override
  List<Object> get props => [id, message];
}

final class DeleteMemberFailureState extends MembersActionsState {
  final Failure failure;

  const DeleteMemberFailureState(this.failure);

  @override
  List<Object> get props => [failure];
}

final class RenewMembershipLoadingState extends MembersActionsState {
  @override
  List<Object> get props => [];
}

final class RenewMembershipSuccessState extends MembersActionsState {
  final RenewMemberEntity renew;

  const RenewMembershipSuccessState(this.renew);

  @override
  List<Object> get props => [renew];
}

final class RenewMembershipFailureState extends MembersActionsState {
  final Failure failure;

  const RenewMembershipFailureState(this.failure);

  @override
  List<Object> get props => [failure];
}
