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
  MembersActionsBloc(CreateMember createMember)
    : _createMember = createMember,
      super(MembersActionsInitial()) {
    on<MembersActionsEvent>((event, emit) {});
    on<CreateMemberEvent>(_onCreateMember);
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
    );
    final result = await _createMember(params);
    result.fold(
      (member) => emit(CreateMemberSuccessState(member)),
      (failure) => emit(CreateMemberFailureState(failure)),
    );
  }
}
