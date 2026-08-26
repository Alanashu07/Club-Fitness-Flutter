part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();
}

final class GetHomeEvent extends HomeEvent {
  final String role;
  const GetHomeEvent(this.role);
  @override
  List<Object?> get props => [role];
}
