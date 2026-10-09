import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../entities/offers_entities.dart';
import '../repository/offers_repo.dart';

class CreateOffer implements UseCase<OfferEntity, OfferEntity> {
  final OffersRepo repo;

  const CreateOffer(this.repo);

  @override
  Future<Either<OfferEntity, Failure>> call(OfferEntity params) async {
    return await repo.createOffer(params);
  }
}
