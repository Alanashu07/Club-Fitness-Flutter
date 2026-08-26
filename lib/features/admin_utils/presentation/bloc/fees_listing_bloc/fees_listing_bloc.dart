import 'package:club_fitness/core/entities/pagination_entity.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../admin_utils.dart';

part 'fees_listing_event.dart';
part 'fees_listing_state.dart';

class FeesListingBloc extends Bloc<FeesListingEvent, FeesListingState> {
  final GetFees _getFees;
  final GetFeeSummary _getFeeSummary;
  FeesListingBloc(GetFees getFees, GetFeeSummary getFeeSummary)
    : _getFees = getFees,
      _getFeeSummary = getFeeSummary,
      super(FeesListingInitial()) {
    on<FeesListingEvent>((event, emit) {});
    on<GetFeesSummaryEvent>(_onGetSummary);
    on<GetFeesListingEvent>(_onGetFees);
    on<GetMoreFeesListingEvent>(_onGetMoreFees);
  }
  GetFeesParams _activeParams = const GetFeesParams();
  PaginationEntity _activePagination = const PaginationEntity();
  List<FeesEntity> _fees = [];
  FeeSummaryEntity? _summary;

  Future<void> _onGetSummary(
    GetFeesSummaryEvent event,
    Emitter<FeesListingState> emit,
  ) async {
    emit(SummaryLoading());
    final failureOrSummary = await _getFeeSummary(null);
    failureOrSummary.fold((s) {
      _summary = s;
      emit(FeesSummaryLoaded(s));
      add(const GetFeesListingEvent());
    }, (f) => emit(SummaryLoadFailure(f)));
  }

  Future<void> _onGetFees(
    GetFeesListingEvent event,
    Emitter<FeesListingState> emit,
  ) async {
    final summary = _summary;
    if (summary == null) return;
    emit(FeesListingLoading(summary));
    final params = GetFeesParams(
      limit: event.limit,
      memberId: event.memberId,
      page: event.page,
      planId: event.planId,
      search: event.search,
      sortBy: event.sortBy,
      status: event.status,
    );
    final failureOrFees = await _getFees(params);
    failureOrFees.fold((fees) {
      _activeParams = params;
      _activePagination = fees.pagination;
      _fees = fees.fees;
      emit(FeesListingLoaded(summary, fees.fees));
    }, (f) => emit(FeesListingFailure(summary, f)));
  }

  Future<void> _onGetMoreFees(
    GetMoreFeesListingEvent event,
    Emitter<FeesListingState> emit,
  ) async {
    final summary = _summary;
    if(summary == null) return;
    bool skip = BlocLoadMoreSkipper.skipLoadMore(
      hasMore: _activePagination.hasNextPage,
      isFailureState: state is FeesListingLoadingMoreFailure,
      isAlreadyLoadingState: state is FeesLoadingMore,
      onResultEnded: () => emit(
        FeesListingLoadingMoreFailure(summary, _fees, Failure.endOfResult),
      ),
    );
    if (skip) return;
    final params = GetFeesParams(
      limit: _activeParams.limit,
      page: _activePagination.nextPage.toString(),
      memberId: _activeParams.memberId,
      planId: _activeParams.planId,
      status: _activeParams.status,
      sortBy: _activeParams.sortBy,
      search: _activeParams.search,
    );
    final failureOrFees = await _getFees(_activeParams);
    failureOrFees.fold((fees) {
      _activePagination = fees.pagination;
      _activeParams = params;
      _fees.addAll(fees.fees);
      emit(FeesListingLoaded(summary, _fees));
    }, (f) async => emit(FeesListingFailure(summary, f)));
  }
}
