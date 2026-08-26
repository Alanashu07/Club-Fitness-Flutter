part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
}

final class SignInWithGoogleEvent extends AuthEvent {
  const SignInWithGoogleEvent();

  @override
  List<Object?> get props => [];
}

final class SignInWithPhoneRequestEvent extends AuthEvent {
  final String phoneNumber;
  final void Function() onCodeSent;
  final void Function(UserEntity user) onAutoVerified;

  const SignInWithPhoneRequestEvent({
    required this.phoneNumber,
    required this.onCodeSent,
    required this.onAutoVerified,
  });

  @override
  List<Object?> get props => [phoneNumber, onCodeSent, onAutoVerified];
}

final class SignInWithPhoneVerifyEvent extends AuthEvent {
  final String otp;
  const SignInWithPhoneVerifyEvent(this.otp);

  @override
  List<Object?> get props => [otp];
}

final class GetMyProfileEvent extends AuthEvent {
  const GetMyProfileEvent();
  @override
  List<Object?> get props => [];
}

final class LogoutEvent extends AuthEvent {
  const LogoutEvent();
  @override
  List<Object?> get props => [];
}

final class SignInWithEmailRequestEvent extends AuthEvent {
  final String email;
  const SignInWithEmailRequestEvent({required this.email});
  @override
  List<Object?> get props => [email];
}

final class SignInWithEmailVerifyEvent extends AuthEvent {
  final String email;
  final String otp;
  const SignInWithEmailVerifyEvent({required this.email, required this.otp});
  @override
  List<Object?> get props => [email, otp];
}
