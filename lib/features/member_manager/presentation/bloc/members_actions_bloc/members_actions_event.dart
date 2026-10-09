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
  final String userRole;
  final String? profileImagePath; // multipart file
  final String? offerId;
  final String? offerCode;

  const CreateMemberEvent({
    required this.name,
    required this.phone,
    required this.email,
    required this.plan,
    required this.trainer,
    required this.dob,
    required this.startDate,
    required this.userRole,
    this.profileImagePath,
    this.offerId,
    this.offerCode,
  });
  @override
  List<Object?> get props => [
    name,
    phone,
    email,
    plan,
    trainer,
    dob,
    startDate,
    userRole,
    profileImagePath,
    offerId,
    offerCode,
  ];
}

final class UpdateMemberEvent extends MembersActionsEvent {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String plan;
  final String trainer;
  final String dob;
  final String startDate;
  final String? profileImagePath;
  final bool removeProfileImage;

  const UpdateMemberEvent({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.plan,
    required this.trainer,
    required this.dob,
    required this.startDate,
    this.profileImagePath,
    this.removeProfileImage = false,
  });
  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    email,
    plan,
    trainer,
    dob,
    startDate,
    profileImagePath,
    removeProfileImage,
  ];
}

final class SuspendMemberEvent extends MembersActionsEvent {
  final String id;
  const SuspendMemberEvent({required this.id});
  @override
  List<Object?> get props => [id];
}

final class ReactivateMemberEvent extends MembersActionsEvent {
  final String id;
  const ReactivateMemberEvent({required this.id});
  @override
  List<Object?> get props => [id];
}

final class DeleteMemberEvent extends MembersActionsEvent {
  final String id;
  final bool force;
  const DeleteMemberEvent({required this.id, this.force = false});
  @override
  List<Object?> get props => [id, force];
}

final class RenewMembershipEvent extends MembersActionsEvent {
  final String id;
  final String planId;
  final num paidAmount;
  final String paymentMethod;
  final String notes;
  final String? startOverride;
  final String? receiptPath;
  final bool waiveRemaining;
  final String? offerId;
  final String? offerCode;
  const RenewMembershipEvent({
    required this.id,
    required this.planId,
    required this.paidAmount,
    required this.paymentMethod,
    required this.notes,
    this.startOverride,
    this.receiptPath,
    this.waiveRemaining = false,
    this.offerId,
    this.offerCode,
  });
  @override
  List<Object?> get props => [
    id,
    planId,
    paidAmount,
    paymentMethod,
    notes,
    startOverride,
    receiptPath,
    waiveRemaining,
    offerId,
    offerCode,
  ];
}

class RevertLastRenewalEvent extends MembersActionsEvent {
  final String id;
  const RevertLastRenewalEvent({required this.id});

  @override
  List<Object?> get props => [id];
}
