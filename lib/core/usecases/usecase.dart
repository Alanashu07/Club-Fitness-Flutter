import 'package:dartz/dartz.dart';

import '../exceptions/failure.dart';

abstract interface class UseCase<SuccessType, Params> {
  Future<Either<SuccessType, Failure>> call(Params params);
}
