import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/admin_utils_entities.dart';
import '../../../domain/usecase/admin_utils_usecases.dart';

part 'report_event.dart';
part 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final GetSalesReport _getSalesReport;
  ReportBloc(this._getSalesReport) : super(ReportInitial()) {
    on<ReportEvent>((event, emit) {});
    on<GetSalesReportEvent>(_onGetSalesReport);
  }

  Future<void> _onGetSalesReport(
    GetSalesReportEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    final failureOrSalesReport = await _getSalesReport(event.range);
    failureOrSalesReport.fold((salesReport) {
      emit(ReportLoaded(salesReport));
    }, (f) => emit(ReportFailure(f)));
  }
}
