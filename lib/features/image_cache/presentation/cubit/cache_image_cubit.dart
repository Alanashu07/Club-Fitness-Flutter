import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/features/image_cache/domain/usecases/get_images.dart';
import 'package:club_fitness/features/image_cache/domain/usecases/get_or_download_image.dart';

import '../../domain/entity/image_entity.dart';

class CacheImageCubit extends Cubit<List<ImageEntity>> {
  final GetImages _getImages;
  final GetOrDownloadImage _getOrDownloadImage;
  CacheImageCubit(GetImages getImages, GetOrDownloadImage getOrDownloadImage)
    : _getImages = getImages,
      _getOrDownloadImage = getOrDownloadImage,
      super([]);

  void getAllImages() async {
    final result = await _getImages(null);
    result.fold((l) => emit(l), (r) => emit([]));
  }

  Future<ImageEntity?> getOrDownloadImage(String? url) async {
    final existingImage = state.firstWhereOrNull(
      (element) => element.url == url,
    );
    if (existingImage?.filePath.orNull() != null) return existingImage;
    final result = await _getOrDownloadImage(url!);
    return result.fold((l) {
      emit({...state, l}.toList());
      return l;
    }, (r) => null);
  }
}
