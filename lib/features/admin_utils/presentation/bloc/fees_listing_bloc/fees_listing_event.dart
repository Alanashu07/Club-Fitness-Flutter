part of 'fees_listing_bloc.dart';

sealed class FeesListingEvent extends Equatable {
  const FeesListingEvent();
}

final class GetFeesSummaryEvent extends FeesListingEvent {
  final bool silent;
  final bool continueLoading;
  const GetFeesSummaryEvent({this.silent = false, this.continueLoading = true});
  @override
  List<Object?> get props => [silent, continueLoading];
}

final class GetFeesListingEvent extends FeesListingEvent {
  final bool silent;
  final String search;
  final String status;
  final String? memberId;
  final String? planId;
  final String sortBy;
  final String page;
  final String limit;
  const GetFeesListingEvent({
    this.silent = false,
    this.search = '',
    this.status = '',
    this.memberId,
    this.planId,
    this.sortBy = '',
    this.page = '',
    this.limit = '',
  });
  @override
  List<Object?> get props => [
    silent,
    search,
    status,
    memberId,
    planId,
    sortBy,
    page,
    limit,
  ];
}

final class GetMoreFeesListingEvent extends FeesListingEvent {
  const GetMoreFeesListingEvent();
  @override
  List<Object?> get props => [];
}
