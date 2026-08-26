part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  final UserEntity user;
  const AuthState(this.user);
  @override
  List<Object> get props => [user];
}

final class AuthInitial extends AuthState {
  const AuthInitial(super.user);
}

final class AuthLoading extends AuthState {
  const AuthLoading(super.user);
}

final class AuthSuccess extends AuthState {
  const AuthSuccess(super.user);
}

final class AuthOtpSent extends AuthState {
  final String message;
  const AuthOtpSent(super.user, this.message);

  @override
  List<Object> get props => [...super.props, message];
}

final class AuthFailure extends AuthState {
  final Failure failure;
  const AuthFailure(super.user, this.failure);
  @override
  List<Object> get props => [...super.props, failure];
}

final class AuthLogoutState extends AuthState {
  const AuthLogoutState(super.user);
}
