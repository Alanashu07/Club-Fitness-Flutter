import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageCacheManager extends CacheManager {
  static final Map<String, ImageCacheManager> _instances = {};

  factory ImageCacheManager({
    required Duration maxAge,
    required int maxObjects,
  }) {
    final key = "cache_${maxAge.inDays}d_$maxObjects";

    if (_instances.containsKey(key)) {
      return _instances[key]!;
    }

    final instance = ImageCacheManager._(maxAge, maxObjects, key);
    _instances[key] = instance;
    return instance;
  }

  ImageCacheManager._(Duration maxAge, int maxObjects, String key)
      : super(
          Config(
            key,
            stalePeriod: maxAge,
            maxNrOfCacheObjects: maxObjects,
            repo: JsonCacheInfoRepository(databaseName: key),
            fileService: HttpFileService(),
          ),
        );
}
