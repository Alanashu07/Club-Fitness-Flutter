part of 'cache_image_bloc.dart';

sealed class CacheImageState extends Equatable {
  const CacheImageState();
}

final class CacheImageInitial extends CacheImageState {
  @override
  List<Object> get props => [];
}

final class CacheImageLoading extends CacheImageState {
  @override
  List<Object?> get props => [];
}

final class CacheImageLoaded extends CacheImageState {
  final ImageEntity image;
  final int deleteCount;

  const CacheImageLoaded(this.image, this.deleteCount);

  @override
  List<Object?> get props => [image, deleteCount];
}

final class CacheImageError extends CacheImageState {
  final Failure failure;

  const CacheImageError(this.failure);

  @override
  List<Object?> get props => [failure];
}
