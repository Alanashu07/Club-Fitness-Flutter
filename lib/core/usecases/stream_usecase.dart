import 'package:dartz/dartz.dart';

import '../exceptions/failure.dart';

abstract interface class StreamUseCase<SuccessType, Params> {
  Stream<Either<SuccessType, Failure>> call(Params params);
}
