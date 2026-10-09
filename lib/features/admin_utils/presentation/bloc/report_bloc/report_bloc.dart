import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/admin_utils_entities.dart';
import '../../../domain/usecase/admin_utils_usecases.dart';

part 'report_event.dart';
part 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final GetSalesReport _getSalesReport;
  final ExportSalesReportPdf _exportSalesReportPdf;
  final ExportSalesReportExcel _exportSalesReportExcel;
  ReportBloc(
    this._getSalesReport,
    this._exportSalesReportPdf,
    this._exportSalesReportExcel,
  ) : super(ReportInitial()) {
    on<ReportEvent>((event, emit) {});
    on<GetSalesReportEvent>(_onGetSalesReport);
    on<ExportSalesReportPdfEvent>(_onExportSalesReportPdf);
    on<ExportSalesReportExcelEvent>(_onExportSalesReportExcel);
  }

  Future<void> _onGetSalesReport(
    GetSalesReportEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    final params = GetSalesReportParams(
      event.range,
      startDate: event.startDate,
      endDate: event.endDate,
    );
    final failureOrSalesReport = await _getSalesReport(params);
    failureOrSalesReport.fold((salesReport) {
      emit(ReportLoaded(salesReport));
    }, (f) => emit(ReportFailure(f)));
  }

  Future<void> _onExportSalesReportPdf(
    ExportSalesReportPdfEvent event,
    Emitter<ReportState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ReportLoaded) return;
    emit(ReportExportLoading(currentState.report, true));
    final params = ExportSalesReportPdfParams(
      event.range,
      startDate: event.startDate,
      endDate: event.endDate,
      txLimit: event.txLimit,
    );
    final failureOrSalesReport = await _exportSalesReportPdf(params);
    failureOrSalesReport.fold((path) {
      emit(ReportExportSuccess(currentState.report, path, true));
    }, (f) => emit(ReportExportFailure(currentState.report, f, true)));
  }

  Future<void> _onExportSalesReportExcel(
    ExportSalesReportExcelEvent event,
    Emitter<ReportState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ReportLoaded) return;
    emit(ReportExportLoading(currentState.report, false));
    final params = ExportSalesReportExcelParams(
      event.range,
      startDate: event.startDate,
      endDate: event.endDate,
      txLimit: event.txLimit,
    );
    final failureOrSalesReport = await _exportSalesReportExcel(params);
    failureOrSalesReport.fold((path) {
      emit(ReportExportSuccess(currentState.report, path, false));
    }, (f) => emit(ReportExportFailure(currentState.report, f, false)));
  }
}
