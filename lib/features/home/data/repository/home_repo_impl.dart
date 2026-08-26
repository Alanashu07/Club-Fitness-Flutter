import 'dart:developer' as dev_log;
import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import '../data_source/home_network_data_source.dart';
import '../../domain/repository/home_repo.dart';
import '../models/home_models.dart';

class HomeRepoImpl implements HomeRepo {
  final HomeNetworkDataSource dataSource;
  const HomeRepoImpl(this.dataSource);

  @override
  Future<Either<HomeModel, Failure>> getHomeData(String role) async {
    try {
      final result = await dataSource.getHomeData(role);
      return Left(result);
    } catch (e, s) {
      dev_log.log(e.toString(), name: 'getHomeData in HomeRepoImpl', stackTrace: s, error: e);
      return Right(Failure.fromException(e));
    }
  }

}
