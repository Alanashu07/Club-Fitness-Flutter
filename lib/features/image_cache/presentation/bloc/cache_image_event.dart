part of 'cache_image_bloc.dart';

sealed class CacheImageEvent extends Equatable {
  const CacheImageEvent();
}

final class GetImageEvent extends CacheImageEvent {
  final String? url;

  const GetImageEvent(this.url);
  @override
  List<Object?> get props => [url];
}

final class ClearAllCacheEvent extends CacheImageEvent {
  const ClearAllCacheEvent();
  @override
  List<Object?> get props => [];
}

final class ClearOldCacheEvent extends CacheImageEvent {
  const ClearOldCacheEvent();
  @override
  List<Object?> get props => [];
}
