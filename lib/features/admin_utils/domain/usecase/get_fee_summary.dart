import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/admin_utils_repo.dart';
import '../entities/admin_utils_entities.dart';

class GetFeeSummary implements UseCase<FeeSummaryEntity, void> {
  final AdminUtilsRepo repo;

  const GetFeeSummary(this.repo);

  @override
  Future<Either<FeeSummaryEntity, Failure>> call(void params) async {
    return await repo.getFeeSummary();
  }
}
