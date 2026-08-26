part of 'members_config_bloc.dart';

sealed class MembersConfigState extends Equatable {
  final List<MembershipPlanMiniEntity> membershipPlans;
  final List<TrainerMiniEntity> trainers;
  const MembersConfigState({
    required this.membershipPlans,
    required this.trainers,
  });

  @override
  List<Object> get props => [membershipPlans, trainers];
}

final class MembersConfigInitial extends MembersConfigState {
  const MembersConfigInitial({
    required super.membershipPlans,
    required super.trainers,
  });
}

final class MembersConfigLoading extends MembersConfigState {
  const MembersConfigLoading({
    required super.membershipPlans,
    required super.trainers,
  });
}

final class MembersConfigSuccess extends MembersConfigState {
  const MembersConfigSuccess({
    required super.membershipPlans,
    required super.trainers,
  });
}

final class MembersConfigFailure extends MembersConfigState {
  final Failure failure;
  const MembersConfigFailure({
    required super.membershipPlans,
    required super.trainers,
    required this.failure,
  });

  @override
  List<Object> get props => [...super.props, failure];
}
