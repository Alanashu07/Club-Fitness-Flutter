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

final class ReportExportLoading extends ReportLoaded {
  final bool isPdf;
  const ReportExportLoading(super.report, this.isPdf);

  @override
  List<Object> get props => [...super.props, isPdf];
}

final class ReportExportSuccess extends ReportLoaded {
  final String path;
  final bool isPdf;
  const ReportExportSuccess(super.report, this.path, this.isPdf);

  @override
  List<Object> get props => [...super.props, path, isPdf];
}

final class ReportExportFailure extends ReportLoaded {
  final Failure failure;
  final bool isPdf;
  const ReportExportFailure(super.report, this.failure, this.isPdf);

  @override
  List<Object> get props => [...super.props, failure, isPdf];
}

final class ReportFailure extends ReportState {
  final Failure failure;
  const ReportFailure(this.failure);
  @override
  List<Object> get props => [failure];
}
