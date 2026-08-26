part of 'report_bloc.dart';

sealed class ReportEvent extends Equatable {
  const ReportEvent();
}

final class GetSalesReportEvent extends ReportEvent {
  final String range;
  const GetSalesReportEvent(this.range);
  @override
  List<Object?> get props => [range];
}
