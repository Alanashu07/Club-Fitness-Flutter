import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/offers_repo.dart';
import '../entities/offers_entities.dart';

class GetOffers implements UseCase<List<OfferEntity>, OfferFilters?> {
  final OffersRepo repo;

  const GetOffers(this.repo);

  @override
  Future<Either<List<OfferEntity>, Failure>> call(OfferFilters? params) async {
    return await repo.getOffers(params);
  }
}
