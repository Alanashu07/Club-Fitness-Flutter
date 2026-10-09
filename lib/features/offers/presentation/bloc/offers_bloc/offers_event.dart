part of 'offers_bloc.dart';

sealed class OffersEvent {
  const OffersEvent();
}

final class GetOffersEvent extends OffersEvent {
  final OfferFilters filters;
  const GetOffersEvent({required this.filters});
}

final class CreateOfferEvent extends OffersEvent {
  final OfferEntity offer;
  const CreateOfferEvent(this.offer);
}

final class UpdateOfferEvent extends OffersEvent {
  final OfferEntity offer;
  const UpdateOfferEvent(this.offer);
}

final class DeleteOfferEvent extends OffersEvent {
  final String id;
  const DeleteOfferEvent(this.id);
}