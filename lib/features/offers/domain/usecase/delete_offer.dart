import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/offers_repo.dart';

class DeleteOffer implements UseCase<String, String> {
  final OffersRepo repo;

  const DeleteOffer(this.repo);

  @override
  Future<Either<String, Failure>> call(String params) async {
    return await repo.deleteOffer(params);
  }
}
