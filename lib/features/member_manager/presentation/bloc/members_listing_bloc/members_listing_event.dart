part of 'members_listing_bloc.dart';

sealed class MembersListingEvent extends Equatable {
  const MembersListingEvent();
}

final class GetMembersListingEvent extends MembersListingEvent {
  final String search;
  final String status;
  final String? plan;
  final String? trainer;
  final bool checkedInToday;
  final bool overdueOnly;
  final String sortBy;
  final String page;
  final String limit;
  const GetMembersListingEvent({
    this.search = '',
    this.status = '',
    this.plan,
    this.trainer,
    this.checkedInToday = false,
    this.overdueOnly = false,
    this.sortBy = '',
    this.page = '',
    this.limit = '',
  });

  @override
  List<Object?> get props => [
    search,
    status,
    plan,
    trainer,
    checkedInToday,
    overdueOnly,
    sortBy,
    page,
    limit,
  ];
}

final class GetMoreMembersListingEvent extends MembersListingEvent {
  const GetMoreMembersListingEvent();

  @override
  List<Object?> get props => [];
}
