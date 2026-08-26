part of 'fees_listing_bloc.dart';

sealed class FeesListingState extends Equatable {
  const FeesListingState();
}

final class FeesListingInitial extends FeesListingState {
  @override
  List<Object> get props => [];
}

// − removed: old no-arg `FeesListingLoading` (was the full-screen loader)
// + added: SummaryLoading is now the full-screen loader, shown only until
//   the summary has loaded for the first time.
final class SummaryLoading extends FeesListingState {
  @override
  List<Object> get props => [];
}

// + added: summary fetch failed (full-screen failure, nothing to show yet)
final class SummaryLoadFailure extends FeesListingState {
  final Failure failure;
  const SummaryLoadFailure(this.failure);
  @override
  List<Object> get props => [failure];
}

final class FeesSummaryLoaded extends FeesListingState {
  final FeeSummaryEntity summary;
  const FeesSummaryLoaded(this.summary);
  @override
  List<Object> get props => [summary];
}

// + added: fees list is (re)loading — summary stays attached so the
//   header/summary card never disappears while this is showing.
final class FeesListingLoading extends FeesSummaryLoaded {
  const FeesListingLoading(super.summary);
}

final class FeesListingLoaded extends FeesSummaryLoaded {
  final List<FeesEntity> fees;
  const FeesListingLoaded(super.summary, this.fees);
  @override
  List<Object> get props => [...super.props, fees];
}

final class FeesLoadingMore extends FeesListingLoaded {
  const FeesLoadingMore(super.summary, super.fees);
}

final class FeesListingLoadingMoreFailure extends FeesListingLoaded {
  final Failure failure;
  const FeesListingLoadingMoreFailure(super.summary, super.fees, this.failure);
  @override
  List<Object> get props => [...super.props, failure];
}

// − changed: now carries `summary` too, so a listing failure (e.g. bad
//   filter/search) doesn't blow away the header.
final class FeesListingFailure extends FeesSummaryLoaded {
  final Failure failure;
  const FeesListingFailure(super.summary, this.failure);
  @override
  List<Object> get props => [...super.props, failure];
}