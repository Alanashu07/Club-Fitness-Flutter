import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/features/image_cache/data/models/image_model.dart';

import '../../domain/entity/image_entity.dart';
import '../../domain/repository/cache_image_repository.dart';
import '../data_source/cache_image_data_source.dart';

class CacheImageRepositoryImpl implements CacheImageRepository {
  final CacheImageDataSource dataSource;

  const CacheImageRepositoryImpl(this.dataSource);
  @override
  Future<Either<int, Failure>> deleteAllImages() async {
    try {
      final result = await dataSource.deleteAllImages();
      return Left(result);
    } catch (e) {
      log(e.toString(), name: 'deleteAllImages; class: $this');
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<int, Failure>> deleteImage(String? url) async {
    try {
      final result = await dataSource.deleteImage(url);
      return Left(result);
    } catch (e) {
      log(e.toString(), name: 'deleteImage; class: $this');
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<ImageModel, Failure>> getImage(String? url) async {
    try {
      final result = await dataSource.getImage(url);
      return Left(result);
    } catch (e) {
      if (e is PathNotFoundException) {
        return Left(await dataSource.saveImage(url!));
      }
      log(e.toString(), name: 'getImage; class: $this');
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<List<ImageModel>, Failure>> getImages() async {
    try {
      final result = await dataSource.getImages();
      return Left(result);
    } catch (e) {
      log(e.toString(), name: 'getImages; class: $this');
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<ImageModel, Failure>> saveImage(String url) async {
    try {
      final result = await dataSource.saveImage(url);
      return Left(result);
    } catch (e) {
      log(e.toString(), name: 'saveImage; class: $this');
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<int, Failure>> updateImage(ImageEntity imageModel) async {
    try {
      final result = await dataSource.updateImage(
        ImageModel.fromEntity(imageModel),
      );
      return Left(result);
    } catch (e) {
      log(e.toString(), name: 'updateImage; class: $this');
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<int, Failure>> clearAllCache() async {
    try {
      final result = await dataSource.clearAllCache();
      return Left(result);
    } catch (e) {
      log(e.toString(), name: 'clearAllCache; class: $this');
      return Right(Failure.fromException(e));
    }
  }

  @override
  Future<Either<int, Failure>> clearOldCache() async {
    try {
      final result = await dataSource.clearOldCache();
      return Left(result);
    } catch (e) {
      log(e.toString(), name: 'clearOldCache; class: $this');
      return Right(Failure.fromException(e));
    }
  }
}
