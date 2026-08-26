import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';

import '../entities/home_entities.dart';

abstract interface class HomeRepo {
  Future<Either<HomeEntity, Failure>> getHomeData(String role);
}
