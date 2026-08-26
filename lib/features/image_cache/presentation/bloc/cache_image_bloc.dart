import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/features/image_cache/domain/entity/image_entity.dart';
import 'package:club_fitness/features/image_cache/domain/usecases/get_images.dart';
import 'package:club_fitness/features/image_cache/domain/usecases/get_or_download_image.dart';
import 'package:club_fitness/features/image_cache/domain/usecases/save_image.dart';

part 'cache_image_event.dart';
part 'cache_image_state.dart';

class CacheImageBloc extends Bloc<CacheImageEvent, CacheImageState> {
  final GetOrDownloadImage _getOrDownloadImage;
  final GetImages _getImages;
  final SaveImage _saveImage;
  // final ClearAllCacheImage _clearAllCacheImage;
  // final ClearOldCacheImage _clearOldCacheImage;

  CacheImageBloc({
    required GetOrDownloadImage getOrDownloadImage,
    required GetImages getImages,
    required SaveImage saveImage,
    // required ClearAllCacheImage clearAllCacheImage,
    // required ClearOldCacheImage clearOldCacheImage,
  }) : _getOrDownloadImage = getOrDownloadImage,
       _getImages = getImages,
       _saveImage = saveImage,
       //  _clearAllCacheImage = clearAllCacheImage,
       //  _clearOldCacheImage = clearOldCacheImage,
       super(CacheImageInitial()) {
    on<CacheImageEvent>((event, emit) {});
    on<GetImageEvent>(_getImage);
    on<ClearAllCacheEvent>(_clearAllImages);
    on<ClearOldCacheEvent>(_clearOldImages);
  }

  Future<ImageEntity?> getOrDownloadImage(String? url) async {
    final result = await _getOrDownloadImage(url);
    return result.fold((l) => l, (r) => null);
  }

  Future<void> _getImage(
    GetImageEvent event,
    Emitter<CacheImageState> emit,
  ) async {
    emit(CacheImageLoading());
    final result = await _getOrDownloadImage(event.url);
    result.fold(
      (l) => emit(CacheImageLoaded(l, 0)),
      (r) => emit(CacheImageError(r)),
    );
  }

  Future<void> _clearAllImages(
    ClearAllCacheEvent event,
    Emitter<CacheImageState> emit,
  ) async {
    // emit(CacheImageLoading());
    // final result = await _clearAllCacheImage(NoParam());
    // result.fold(
    //   (l) => emit(
    //     CacheImageLoaded(
    //       const ImageModel(url: '', filePath: '', timeStamp: 0),
    //       l,
    //     ),
    //   ),
    //   (r) => emit(CacheImageError(r)),
    // );
  }

  Future<void> _clearOldImages(
    ClearOldCacheEvent event,
    Emitter<CacheImageState> emit,
  ) async {
    // emit(CacheImageLoading());
    // final result = await _clearOldCacheImage(NoParam());
    // result.fold(
    //   (l) => emit(
    //     CacheImageLoaded(
    //       const ImageModel(url: '', filePath: '', timeStamp: 0),
    //       l,
    //     ),
    //   ),
    //   (r) => emit(CacheImageError(r)),
    // );
  }
}
