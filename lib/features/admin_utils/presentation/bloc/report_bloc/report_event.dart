part of 'report_bloc.dart';

sealed class ReportEvent extends Equatable {
  const ReportEvent();
}

class GetSalesReportEvent extends ReportEvent {
  final String range; // '1D' | '7D' | '30D' | '6M' | '1Y' | 'CUSTOM'
  final String? startDate; // yyyy-MM-dd
  final String? endDate; // yyyy-MM-dd
  const GetSalesReportEvent(this.range, {this.startDate, this.endDate});

  @override
  List<Object?> get props => [range, startDate, endDate];
}

final class ExportSalesReportPdfEvent extends ReportEvent {
  final String range; // '1D' | '7D' | '30D' | '6M' | '1Y' | 'CUSTOM'
  final String? startDate; // yyyy-MM-dd
  final String? endDate; // yyyy-MM-dd
  final num? txLimit;

  const ExportSalesReportPdfEvent(
    this.range, {
    this.startDate,
    this.endDate,
    this.txLimit,
  });

  @override
  List<Object?> get props => [range, startDate, endDate, txLimit];
}

final class ExportSalesReportExcelEvent extends ReportEvent {
  final String range; // '1D' | '7D' | '30D' | '6M' | '1Y' | 'CUSTOM'
  final String? startDate; // yyyy-MM-dd
  final String? endDate; // yyyy-MM-dd
  final num? txLimit;

  const ExportSalesReportExcelEvent(
    this.range, {
    this.startDate,
    this.endDate,
    this.txLimit,
  });

  @override
  List<Object?> get props => [range, startDate, endDate, txLimit];
}
