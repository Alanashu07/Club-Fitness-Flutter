import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/member_manager_entities.dart';
import '../../../domain/usecase/member_manager_usecases.dart';

part 'members_listing_event.dart';
part 'members_listing_state.dart';

class MembersListingBloc
    extends Bloc<MembersListingEvent, MembersListingState> {
  final GetMemberList _getMemberList;
  MembersListingBloc(GetMemberList getMemberList)
    : _getMemberList = getMemberList,
      super(MembersListingInitial()) {
    on<MembersListingEvent>((event, emit) {});
    on<GetMembersListingEvent>(_onGetMembers);
    on<GetMoreMembersListingEvent>(_onGetMoreMembers);
  }

  GetMemberListParams? _lastParams;
  MemberPaginationEntity? _lastPagination;

  Future<void> _onGetMembers(
    GetMembersListingEvent event,
    Emitter<MembersListingState> emit,
  ) async {
    emit(MembersListingLoading());
    final params = GetMemberListParams(
      search: event.search,
      status: event.status,
      plan: event.plan,
      trainer: event.trainer,
      checkedInToday: event.checkedInToday,
      overdueOnly: event.overdueOnly,
      sortBy: event.sortBy,
      page: event.page,
      limit: event.limit,
    );
    final result = await _getMemberList(params);

    result.fold((memberPagination) {
      _lastPagination = memberPagination;
      _lastParams = params;
      emit(
        MembersListingSuccess(
          members: memberPagination.members,
          pagination: memberPagination.pagination,
          summary: memberPagination.summary,
        ),
      );
    }, (failure) => emit(MembersListingFailure(failure)));
  }

  Future<void> _onGetMoreMembers(
    GetMoreMembersListingEvent event,
    Emitter<MembersListingState> emit,
  ) async {
    bool skip = BlocLoadMoreSkipper.skipLoadMore(
      hasMore: _lastPagination?.pagination.hasNextPage ?? false,
      isFailureState: state is MembersListingLoadingMoreFailure,
      isAlreadyLoadingState: state is MembersListingLoadingMore,
      onResultEnded: () => emit(
        MembersListingLoadingMoreFailure(
          members: _lastPagination!.members,
          pagination: _lastPagination!.pagination,
          summary: _lastPagination!.summary,
          failure: Failure.endOfResult,
        ),
      ),
    );
    if (skip) return;

    emit(
      MembersListingLoadingMore(
        members: _lastPagination?.members ?? [],
        pagination: _lastPagination?.pagination ?? const Pagination(),
        summary: _lastPagination?.summary ?? const Summary(),
      ),
    );

    final params = GetMemberListParams(
      search: _lastParams?.search ?? '',
      status: _lastParams?.status ?? '',
      plan: _lastParams?.plan,
      trainer: _lastParams?.trainer,
      checkedInToday: _lastParams?.checkedInToday ?? false,
      overdueOnly: _lastParams?.overdueOnly ?? false,
      sortBy: _lastParams?.sortBy ?? '',
      page: _lastPagination!.pagination.nextPage.toString(),
      limit: _lastParams?.limit ?? '',
    );

    final result = await _getMemberList(params);

    result.fold(
      (memberPagination) {
        _lastPagination = memberPagination;
        _lastParams = params;
        emit(
          MembersListingSuccess(
            members: memberPagination.members,
            pagination: memberPagination.pagination,
            summary: memberPagination.summary,
          ),
        );
      },
      (failure) => emit(
        MembersListingLoadingMoreFailure(
          members: _lastPagination!.members,
          pagination: _lastPagination!.pagination,
          summary: _lastPagination!.summary,
          failure: failure,
        ),
      ),
    );
  }
}
