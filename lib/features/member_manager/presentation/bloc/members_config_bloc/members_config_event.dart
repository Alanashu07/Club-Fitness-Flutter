part of 'members_config_bloc.dart';

sealed class MembersConfigEvent extends Equatable {
  const MembersConfigEvent();
}

final class GetMembershipPlansEvent extends MembersConfigEvent {
  final bool continueLoading;
  final bool includeInactive;
  const GetMembershipPlansEvent([this.continueLoading = false, this.includeInactive = false]);

  @override
  List<Object?> get props => [continueLoading];
}

final class GetTrainersEvent extends MembersConfigEvent {
  final bool continueLoading;
  const GetTrainersEvent([this.continueLoading = false]);

  @override
  List<Object?> get props => [continueLoading];
}
