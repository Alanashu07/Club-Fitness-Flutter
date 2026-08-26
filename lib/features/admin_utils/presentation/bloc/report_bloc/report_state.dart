part of 'report_bloc.dart';

sealed class ReportState extends Equatable {
  const ReportState();
}

final class ReportInitial extends ReportState {
  @override
  List<Object> get props => [];
}

final class ReportLoading extends ReportState {
  @override
  List<Object> get props => [];
}

final class ReportLoaded extends ReportState {
  final ReportDetailsEntity report;
  const ReportLoaded(this.report);
  @override
  List<Object> get props => [report];
}

final class ReportFailure extends ReportState {
  final Failure failure;
  const ReportFailure(this.failure);
  @override
  List<Object> get props => [failure];
}