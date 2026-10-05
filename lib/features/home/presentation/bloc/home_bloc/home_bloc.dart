import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/features/home/domain/usecase/home_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/home_entities.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeData _getHomeData;
  HomeBloc(GetHomeData getHomeData)
    : _getHomeData = getHomeData,
      super(HomeInitial()) {
    on<HomeEvent>((event, emit) {});
    on<GetHomeEvent>(_onGetHome);
    on<RemoveAdminPendingApprovalEvent>(_onRemoveAdminPendingApproval);
  }

  Future<void> _onGetHome(GetHomeEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    final result = await _getHomeData(event.role);
    result.fold((r) => emit(HomeSuccess(r)), (l) => emit(HomeFailure(l)));
  }

  void _onRemoveAdminPendingApproval(
    RemoveAdminPendingApprovalEvent event,
    Emitter<HomeState> emit,
  ) {
    if (state is! HomeSuccess) return;
    final currentState = state as HomeSuccess;
    emit(HomeLoading());
    final pendingApproval = currentState.home.adminHome?.pendingPayments;
    if (pendingApproval == null || pendingApproval.isEmpty) return;
    emit(
      HomeSuccess(
        currentState.home.copyWith(
          adminHome: currentState.home.adminHome?.copyWith(
            pendingPayments: pendingApproval
                .where((element) => element.id != event.id)
                .toList(),
          ),
        ),
      ),
    );
  }
}
