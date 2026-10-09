import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';

import '../entities/offers_entities.dart';

abstract interface class OffersRepo {
  Future<Either<List<OfferEntity>, Failure>> getOffers(OfferFilters? f);
  Future<Either<OfferEntity, Failure>> createOffer(OfferEntity offer);
  Future<Either<OfferEntity, Failure>> updateOffer(OfferEntity offer);
  Future<Either<String, Failure>> deleteOffer(String id);
}
