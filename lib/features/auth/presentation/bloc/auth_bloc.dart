import 'package:club_fitness/config/local/app_data.dart';
import 'package:club_fitness/core/entities/user_entity.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecase/auth_usecases.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle _signInWithGoogle;
  final SignInWithPhoneRequestOtp _signInWithPhoneRequestOtp;
  final SignInWithPhoneVerifyOtp _signInWithPhoneVerifyOtp;
  final GetMyProfile _getMyProfile;
  final Logout _logout;
  final SignInWithEmailRequestOtp _signInWithEmailRequestOtp;
  final SignInWithEmailVerifyOtp _signInWithEmailVerifyOtp;
  AuthBloc(
    SignInWithGoogle signInWithGoogle,
    SignInWithPhoneRequestOtp signInWithPhoneRequestOtp,
    SignInWithPhoneVerifyOtp signInWithPhoneVerifyOtp,
    GetMyProfile getMyProfile,
    Logout logout,
    SignInWithEmailRequestOtp signInWithEmailRequestOtp,
    SignInWithEmailVerifyOtp signInWithEmailVerifyOtp,
  ) : _signInWithGoogle = signInWithGoogle,
      _signInWithPhoneRequestOtp = signInWithPhoneRequestOtp,
      _signInWithPhoneVerifyOtp = signInWithPhoneVerifyOtp,
      _getMyProfile = getMyProfile,
      _logout = logout,
      _signInWithEmailRequestOtp = signInWithEmailRequestOtp,
      _signInWithEmailVerifyOtp = signInWithEmailVerifyOtp,
      super(const AuthInitial(UserEntity())) {
    on<AuthEvent>((event, emit) {});
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignInWithPhoneRequestEvent>(_onSignInWithPhone);
    on<SignInWithPhoneVerifyEvent>(_onSignInWithPhoneVerify);
    on<GetMyProfileEvent>(_onGetMyProfile);
    on<LogoutEvent>(_onLogout);
    on<SignInWithEmailRequestEvent>(_onSignInWithEmailRequest);
    on<SignInWithEmailVerifyEvent>(_onSignInWithEmailVerify);
  }

  Future<void> _onGetMyProfile(
    GetMyProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (AppData.accessTokenValue.isEmpty) return;
    emit(AuthLoading(state.user));
    final result = await _getMyProfile(null);
    result.fold(
      (l) => emit(AuthSuccess(l)),
      (r) => emit(AuthFailure(state.user, r)),
    );
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(state.user));
    final result = await _signInWithGoogle(null);
    result.fold(
      (l) => emit(AuthSuccess(l)),
      (r) => emit(AuthFailure(state.user, r)),
    );
  }

  Future<void> _onSignInWithPhone(
    SignInWithPhoneRequestEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(state.user));
    final params = SignInWithPhoneRequestOtpParams(
      phoneNumber: event.phoneNumber,
      onCodeSent: event.onCodeSent,
      onAutoVerified: (user) {
        emit(AuthSuccess(user));
        event.onAutoVerified(user);
      },
    );
    final result = await _signInWithPhoneRequestOtp(params);
    result.fold((l) => null, (r) => emit(AuthFailure(state.user, r)));
  }

  Future<void> _onSignInWithPhoneVerify(
    SignInWithPhoneVerifyEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(state.user));
    final result = await _signInWithPhoneVerifyOtp(event.otp);
    result.fold(
      (l) => emit(AuthSuccess(l)),
      (r) => emit(AuthFailure(state.user, r)),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading(state.user));
    final result = await _logout(null);
    result.fold(
      (l) => emit(const AuthLogoutState(UserEntity())),
      (r) => emit(AuthFailure(state.user, r)),
    );
  }

  Future<void> _onSignInWithEmailRequest(
    SignInWithEmailRequestEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(state.user));
    final result = await _signInWithEmailRequestOtp(event.email);
    result.fold(
      (l) => emit(AuthOtpSent(state.user, l)),
      (r) => emit(AuthFailure(state.user, r)),
    );
  }

  Future<void> _onSignInWithEmailVerify(
    SignInWithEmailVerifyEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(state.user));
    final params = SignInWithEmailVerifyOtpParams(
      email: event.email,
      otp: event.otp,
    );
    final result = await _signInWithEmailVerifyOtp(params);
    result.fold(
      (l) => emit(AuthSuccess(l)),
      (r) => emit(AuthFailure(state.user, r)),
    );
  }
}
