import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/member_manager_entities.dart';
import '../../../domain/usecase/get_member_details.dart';

part 'member_detail_event.dart';
part 'member_detail_state.dart';

class MemberDetailBloc extends Bloc<MemberDetailEvent, MemberDetailState> {
  final GetMemberDetails _getMemberDetails;
  MemberDetailBloc(GetMemberDetails getMemberDetails)
    : _getMemberDetails = getMemberDetails,
      super(MemberDetailInitial()) {
    on<MemberDetailEvent>((event, emit) {});
    on<GetMemberDetailsEvent>(_onGetMemberDetailsEvent);
  }

  Future<void> _onGetMemberDetailsEvent(
    GetMemberDetailsEvent event,
    Emitter<MemberDetailState> emit,
  ) async {
    emit(const MemberDetailLoading());
    final result = await _getMemberDetails(event.memberId);
    result.fold(
      (member) => emit(MemberDetailSuccess(member)),
      (failure) => emit(MemberDetailFailure(failure)),
    );
  }
}
