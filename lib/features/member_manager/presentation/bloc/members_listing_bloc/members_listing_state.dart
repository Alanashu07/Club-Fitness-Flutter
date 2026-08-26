part of 'members_listing_bloc.dart';

sealed class MembersListingState extends Equatable {
  const MembersListingState();
}

final class MembersListingInitial extends MembersListingState {
  @override
  List<Object> get props => [];
}

final class MembersListingLoading extends MembersListingState {
  @override
  List<Object> get props => [];
}

final class MembersListingSuccess extends MembersListingState {
  final List<MemberListEntity> members;
  final Pagination pagination;
  final Summary summary;

  const MembersListingSuccess({required this.members, required this.pagination, required this.summary});

  @override
  List<Object> get props => [members, pagination, summary];
}

final class MembersListingLoadingMore extends MembersListingSuccess {

  const MembersListingLoadingMore({required super.members, required super.pagination, required super.summary});
}

final class MembersListingLoadingMoreFailure extends MembersListingSuccess {
  final Failure failure;

  const MembersListingLoadingMoreFailure({required super.members, required super.pagination, required super.summary, required this.failure});

  @override
  List<Object> get props => [...super.props, failure];
}

final class MembersListingFailure extends MembersListingState {
  final Failure failure;

  const MembersListingFailure(this.failure);

  @override
  List<Object> get props => [failure];
}