import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/admin_utils_repo.dart';

class DeleteFee implements UseCase<String, String> {
  final AdminUtilsRepo repo;

  const DeleteFee(this.repo);

  @override
  Future<Either<String, Failure>> call(String params) async {
    return await repo.deleteFee(params);
  }
}
