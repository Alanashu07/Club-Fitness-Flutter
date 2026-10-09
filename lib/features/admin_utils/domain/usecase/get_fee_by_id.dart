import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/admin_utils_repo.dart';
import '../entities/admin_utils_entities.dart';

class GetFeeById implements UseCase<FeeDetailEntity, String> {
  final AdminUtilsRepo repo;

  const GetFeeById(this.repo);

  @override
  Future<Either<FeeDetailEntity, Failure>> call(String params) async {
    return await repo.getFeeById(params);
  }
}
