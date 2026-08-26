import 'package:club_fitness/core/exceptions/failure.dart';
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
  }

  Future<void> _onGetHome(GetHomeEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    final result = await _getHomeData(event.role);
    result.fold((r) => emit(HomeSuccess(r)), (l) => emit(HomeFailure(l)));
  }
}
