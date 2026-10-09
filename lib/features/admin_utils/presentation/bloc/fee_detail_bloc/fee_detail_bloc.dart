import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/admin_utils_entities.dart';
import '../../../domain/usecase/admin_utils_usecases.dart';

part 'fee_detail_event.dart';
part 'fee_detail_state.dart';

class FeeDetailBloc extends Bloc<FeeDetailEvent, FeeDetailState> {
  final GetFeeById _getFeeById;
  FeeDetailBloc(GetFeeById getFeeById)
    : _getFeeById = getFeeById,
      super(FeeDetailInitial()) {
    on<FeeDetailEvent>((event, emit) {});
    on<GetFeeDetailEvent>(_onGetFeeDetail);
  }

  Future<void> _onGetFeeDetail(
    GetFeeDetailEvent event,
    Emitter<FeeDetailState> emit,
  ) async {
    emit(FeeDetailLoadingState());
    final failureOrFee = await _getFeeById(event.id);
    failureOrFee.fold(
      (fee) => emit(FeeDetailSuccessState(fee)),
      (f) => emit(FeeDetailFailureState(f)),
    );
  }
}
