part of 'members_actions_bloc.dart';

sealed class MembersActionsEvent extends Equatable {
  const MembersActionsEvent();
}

final class CreateMemberEvent extends MembersActionsEvent {
  final String name;
  final String phone;
  final String email;
  final String plan;
  final String trainer;
  final String dob;
  final String startDate;

  const CreateMemberEvent({
    required this.name,
    required this.phone,
    required this.email,
    required this.plan,
    required this.trainer,
    required this.dob,
    required this.startDate,
  });
  @override
  List<Object?> get props => [name, phone, email, plan, trainer, dob, startDate];
}
