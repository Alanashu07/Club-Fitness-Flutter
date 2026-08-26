part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();
}

final class HomeInitial extends HomeState {
  @override
  List<Object> get props => [];
}

final class HomeLoading extends HomeState {
  @override
  List<Object> get props => [];
}

final class HomeSuccess extends HomeState {
  final HomeEntity home;
  const HomeSuccess(this.home);
  @override
  List<Object> get props => [home];
}

final class HomeFailure extends HomeState {
  final Failure failure;
  const HomeFailure(this.failure);
  @override
  List<Object> get props => [failure];
}
