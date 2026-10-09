import 'dart:developer' as dev_log;
import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import '../../domain/entities/offers_entities.dart';
import '../data_source/offers_network_data_source.dart';
import '../../domain/repository/offers_repo.dart';
import '../models/offers_models.dart';

class OffersRepoImpl implements OffersRepo {
  final OffersNetworkDataSource dataSource;
  const OffersRepoImpl(this.dataSource);

  @override
  Future<Either<List<OfferModel>, Failure>> getOffers(OfferFilters? f) async {
    try {
      final result = await dataSource.getOffers(f);
      return Left(result);
    } catch (e, s) {
      dev_log.log(e.toString(), name: 'getOffers in OffersRepoImpl', stackTrace: s, error: e);
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<OfferModel, Failure>> createOffer(OfferEntity offer) async {
    try {
      final model = OfferModel.fromEntity(offer);
      final result = await dataSource.createOffer(model);
      return Left(result);
    } catch (e, s) {
      dev_log.log(e.toString(), name: 'createOffer in OffersRepoImpl', stackTrace: s, error: e);
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<OfferModel, Failure>> updateOffer(OfferEntity offer) async {
    try {
      final model = OfferModel.fromEntity(offer);
      final result = await dataSource.updateOffer(model);
      return Left(result);
    } catch (e, s) {
      dev_log.log(e.toString(), name: 'updateOffer in OffersRepoImpl', stackTrace: s, error: e);
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<String, Failure>> deleteOffer(String id) async {
    try {
      final result = await dataSource.deleteOffer(id);
      return Left(result);
    } catch (e, s) {
      dev_log.log(e.toString(), name: 'deleteOffer in OffersRepoImpl', stackTrace: s, error: e);
      return Right(Failure.fromException(e));
    }
  }

}
