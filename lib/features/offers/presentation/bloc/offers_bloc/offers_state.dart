part of 'offers_bloc.dart';

enum OfferAction { create, update, delete }

sealed class OffersState {
  final List<OfferEntity> offers;
  final OfferFilters filters;
  const OffersState({required this.offers, required this.filters});
}

final class OffersInitial extends OffersState {
  const OffersInitial({required super.offers, required super.filters});
}

final class OffersLoading extends OffersState {
  const OffersLoading({required super.offers, required super.filters});
}

final class OfferActionLoading extends OffersState {
  final OfferAction action;
  const OfferActionLoading({
    required super.offers,
    required super.filters,
    required this.action,
  });
}

final class OffersLoaded extends OffersState {
  const OffersLoaded({required super.offers, required super.filters});
}

final class OffersError extends OffersState {
  final Failure failure;
  const OffersError({
    required super.offers,
    required super.filters,
    required this.failure,
  });
}

final class OffersUpdated extends OffersState {
  final OfferEntity offer;
  const OffersUpdated({
    required super.offers,
    required super.filters,
    required this.offer,
  });
}

final class OfferCreated extends OffersState {
  final OfferEntity offer;
  const OfferCreated({
    required super.offers,
    required super.filters,
    required this.offer,
  });
}

final class OfferDeleted extends OffersState {
  final String offer;
  final String message;
  const OfferDeleted({
    required super.offers,
    required super.filters,
    required this.offer,
    required this.message,
  });
}
