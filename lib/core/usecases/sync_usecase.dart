import 'package:dartz/dartz.dart';

import '../exceptions/failure.dart';

abstract interface class SyncUsecase<SuccessType, Params> {
  Either<SuccessType, Failure> call(Params params);
}
