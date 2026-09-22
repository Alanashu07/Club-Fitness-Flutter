import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../member_manager.dart';

part 'members_config_event.dart';
part 'members_config_state.dart';

class MembersConfigBloc extends Bloc<MembersConfigEvent, MembersConfigState> {
  final GetPlans _getPlans;
  final GetTrainers _getTrainers;
  final CreateMembershipPlan _createMembershipPlan;
  final UpdateMembershipPlan _updateMembershipPlan;
  final DeleteMembershipPlan _deleteMembershipPlan;
  MembersConfigBloc(
    GetPlans getPlans,
    GetTrainers getTrainers,
    CreateMembershipPlan createMembershipPlan,
    UpdateMembershipPlan updateMembershipPlan,
    DeleteMembershipPlan deleteMembershipPlan,
  ) : _getPlans = getPlans,
      _getTrainers = getTrainers,
      _createMembershipPlan = createMembershipPlan,
      _updateMembershipPlan = updateMembershipPlan,
      _deleteMembershipPlan = deleteMembershipPlan,
      super(const MembersConfigInitial(membershipPlans: [], trainers: [])) {
    on<MembersConfigEvent>((event, emit) {});
    on<GetMembershipPlansEvent>(_onGetMembershipPlans);
    on<GetTrainersEvent>(_onGetTrainers);
    on<CreateMembershipPlanEvent>(_onCreateMembershipPlan);
    on<UpdateMembershipPlanEvent>(_onUpdateMembershipPlan);
    on<DeleteMembershipPlanEvent>(_onDeleteMembershipPlan);
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

  Future<void> _onCreateMembershipPlan(
    CreateMembershipPlanEvent event,
    Emitter<MembersConfigState> emit,
  ) async {
    emit(
      MembersConfigLoading(
        membershipPlans: state.membershipPlans,
        trainers: state.trainers,
      ),
    );
    final result = await _createMembershipPlan(event.plan);
    result.fold(
      (plan) {
        emit(
          MembersConfigSuccess(
            membershipPlans: [plan, ...state.membershipPlans],
            trainers: state.trainers,
          ),
        );
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

  Future<void> _onUpdateMembershipPlan(
    UpdateMembershipPlanEvent event,
    Emitter<MembersConfigState> emit,
  ) async {
    emit(
      MembersConfigLoading(
        membershipPlans: state.membershipPlans,
        trainers: state.trainers,
      ),
    );
    final result = await _updateMembershipPlan(event.plan);
    result.fold(
      (plan) {
        emit(
          MembersConfigSuccess(
            membershipPlans: state.membershipPlans.map((e) {
              if (plan.id == e.id) return plan;
              return e;
            }).toList(),
            trainers: state.trainers,
          ),
        );
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

  Future<void> _onDeleteMembershipPlan(
    DeleteMembershipPlanEvent event,
    Emitter<MembersConfigState> emit,
  ) async {
    emit(
      MembersConfigLoading(
        membershipPlans: state.membershipPlans,
        trainers: state.trainers,
      ),
    );
    final result = await _deleteMembershipPlan(event.id);
    result.fold(
      (plan) {
        emit(
          MembersConfigSuccess(
            membershipPlans: state.membershipPlans
                .where((element) => element.id != event.id)
                .toList(),
            trainers: state.trainers,
          ),
        );
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
}
