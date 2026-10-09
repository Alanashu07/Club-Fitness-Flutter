import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/member_manager_entities.dart';
import '../../../domain/usecase/member_manager_usecases.dart';

part 'members_actions_event.dart';
part 'members_actions_state.dart';

class MembersActionsBloc
    extends Bloc<MembersActionsEvent, MembersActionsState> {
  final CreateMember _createMember;
  final UpdateMember _updateMember;
  final DeleteMember _deleteMember;
  final SuspendMember _suspendMember;
  final ReactivateMember _reactivateMember;
  final RenewMembership _renewMembership;
  final RevertLastRenewal _revertLastRenewal;
  MembersActionsBloc(
    CreateMember createMember,
    UpdateMember updateMember,
    DeleteMember deleteMember,
    SuspendMember suspendMember,
    ReactivateMember reactivateMember,
    RenewMembership renewMembership,
    RevertLastRenewal revertLastRenewal
  ) : _createMember = createMember,
      _updateMember = updateMember,
      _deleteMember = deleteMember,
      _suspendMember = suspendMember,
      _reactivateMember = reactivateMember,
      _renewMembership = renewMembership,
      _revertLastRenewal = revertLastRenewal,
      super(MembersActionsInitial()) {
    on<MembersActionsEvent>((event, emit) {});
    on<CreateMemberEvent>(_onCreateMember);
    on<UpdateMemberEvent>(_onUpdateMember);
    on<DeleteMemberEvent>(_onDeleteMember);
    on<SuspendMemberEvent>(_onSuspendMember);
    on<ReactivateMemberEvent>(_onReactivateMember);
    on<RenewMembershipEvent>(_onRenewMembership);
    on<RevertLastRenewalEvent>(_onRevertLastRenewal);
  }

  Future<void> _onCreateMember(
    CreateMemberEvent event,
    Emitter<MembersActionsState> emit,
  ) async {
    emit(CreateMemberLoadingState());
    final params = CreateMemberParams(
      dob: event.dob,
      email: event.email,
      name: event.name,
      phone: event.phone,
      plan: event.plan,
      trainer: event.trainer,
      startDate: event.startDate,
      userRole: event.userRole,
      offerCode: event.offerCode,
      offerId: event.offerId,
      profileImagePath: event.profileImagePath,
    );
    final result = await _createMember(params);
    result.fold(
      (member) => emit(CreateMemberSuccessState(member)),
      (failure) => emit(CreateMemberFailureState(failure)),
    );
  }

  Future<void> _onUpdateMember(
    UpdateMemberEvent event,
    Emitter<MembersActionsState> emit,
  ) async {
    emit(UpdateMemberLoadingState());
    final params = UpdateMemberParams(
      id: event.id,
      dob: event.dob,
      email: event.email,
      name: event.name,
      phone: event.phone,
      plan: event.plan,
      trainer: event.trainer,
      startDate: event.startDate,
      removeProfileImage: event.removeProfileImage,
      profileImagePath: event.profileImagePath,
    );
    final result = await _updateMember(params);
    result.fold(
      (member) => emit(UpdateMemberSuccessState(member)),
      (failure) => emit(UpdateMemberFailureState(failure)),
    );
  }

  Future<void> _onDeleteMember(
    DeleteMemberEvent event,
    Emitter<MembersActionsState> emit,
  ) async {
    emit(DeleteMemberLoadingState());
    final params = DeleteMemberParams(id: event.id, force: event.force);
    final result = await _deleteMember(params);
    result.fold(
      (message) =>
          emit(DeleteMemberSuccessState(id: event.id, message: message)),
      (failure) => emit(DeleteMemberFailureState(failure)),
    );
  }

  Future<void> _onSuspendMember(
    SuspendMemberEvent event,
    Emitter<MembersActionsState> emit,
  ) async {
    emit(SuspendMemberLoadingState());
    final result = await _suspendMember(event.id);
    result.fold(
      (member) => emit(SuspendMemberSuccessState(event.id, member)),
      (failure) => emit(SuspendMemberFailureState(failure)),
    );
  }

  Future<void> _onReactivateMember(
    ReactivateMemberEvent event,
    Emitter<MembersActionsState> emit,
  ) async {
    emit(ReactivateMemberLoadingState());
    final result = await _reactivateMember(event.id);
    result.fold(
      (member) => emit(ReactivateMemberSuccessState(event.id, member)),
      (failure) => emit(ReactivateMemberFailureState(failure)),
    );
  }

  Future<void> _onRenewMembership(
    RenewMembershipEvent event,
    Emitter<MembersActionsState> emit,
  ) async {
    emit(RenewMembershipLoadingState());
    final params = RenewMembershipParams(
      id: event.id,
      planId: event.planId,
      notes: event.notes,
      paidAmount: event.paidAmount,
      paymentMethod: event.paymentMethod,
      startOverride: event.startOverride,
      receiptPath: event.receiptPath,
      offerCode: event.offerCode,
      offerId: event.offerId,
      waiveRemaining: event.waiveRemaining,
    );
    final result = await _renewMembership(params);
    result.fold(
      (member) => emit(RenewMembershipSuccessState(member)),
      (failure) => emit(RenewMembershipFailureState(failure)),
    );
  }

  Future<void> _onRevertLastRenewal(
    RevertLastRenewalEvent event,
    Emitter<MembersActionsState> emit,
  ) async {
    emit(RevertLastRenewalLoadingState());
    final result = await _revertLastRenewal(event.id);
    result.fold(
      (member) => emit(RevertLastRenewalSuccessState(event.id, member)),
      (failure) => emit(RevertLastRenewalFailureState(failure)),
    );
  }
}
