import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../member_manager.dart';

part 'members_config_event.dart';
part 'members_config_state.dart';

class MembersConfigBloc extends Bloc<MembersConfigEvent, MembersConfigState> {
  final GetPlans _getPlans;
  final GetTrainers _getTrainers;
  MembersConfigBloc(GetPlans getPlans, GetTrainers getTrainers)
    : _getPlans = getPlans,
      _getTrainers = getTrainers,
      super(const MembersConfigInitial(membershipPlans: [], trainers: [])) {
    on<MembersConfigEvent>((event, emit) {});
    on<GetMembershipPlansEvent>(_onGetMembershipPlans);
    on<GetTrainersEvent>(_onGetTrainers);
  }

  Future<void> _onGetMembershipPlans(
    GetMembershipPlansEvent event,
    Emitter<MembersConfigState> emit,
  ) async {
    emit(
      MembersConfigLoading(
        membershipPlans: state.membershipPlans,
        trainers: state.trainers,
      ),
    );
    final result = await _getPlans(event.includeInactive);
    result.fold(
      (plans) {
        emit(
          MembersConfigSuccess(
            membershipPlans: plans,
            trainers: state.trainers,
          ),
        );
        if (event.continueLoading) {
          add(const GetTrainersEvent());
        }
      },
      (failure) => emit(
        MembersConfigFailure(
          membershipPlans: state.membershipPlans,
          trainers: state.trainers,
          failure: failure,
        ),
      ),
    );
  }

  Future<void> _onGetTrainers(
    GetTrainersEvent event,
    Emitter<MembersConfigState> emit,
  ) async {
    emit(
      MembersConfigLoading(
        membershipPlans: state.membershipPlans,
        trainers: state.trainers,
      ),
    );
    final result = await _getTrainers(null);
    result.fold(
      (trainers) {
        emit(
          MembersConfigSuccess(
            trainers: trainers,
            membershipPlans: state.membershipPlans,
          ),
        );
        if (event.continueLoading) {
          add(const GetMembershipPlansEvent());
        }
      },
      (failure) => emit(
        MembersConfigFailure(
          trainers: state.trainers,
          membershipPlans: state.membershipPlans,
          failure: failure,
        ),
      ),
    );
  }
}
