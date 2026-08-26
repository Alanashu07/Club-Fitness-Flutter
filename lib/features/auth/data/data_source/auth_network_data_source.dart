import 'package:club_fitness/config/local/app_data.dart';
import 'package:club_fitness/config/local/db_helper.dart';
import 'package:club_fitness/config/network/api.dart';
import 'package:club_fitness/core/exceptions/app_exception.dart';
import 'package:club_fitness/core/models/user_model.dart';
import 'package:club_fitness/core/services/firebase_phone_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/auth_models.dart';

abstract interface class AuthNetworkDataSource {
  Future<LoginUserModel> login(String email, String password);
  Future<UserModel> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  });
  Future<UserModel> getMyProfile();
  Future<String> logout();
  Future<String> logoutAll();
  Future<UserModel> signInWithGoogle();
  Future<void> signInWithPhoneRequestOtp({
    required String phoneNumber,
    required void Function() onCodeSent,
    required void Function(UserModel user) onAutoVerified,
    required void Function(String message) onError,
  });
  Future<UserModel> signInWithPhoneVerifyOtp(String otp);

  Future<String> signInWithEmailRequestOtp(String email);
  Future<UserModel> signInWithEmailVerifyOtp({
    required String email,
    required String otp,
  });
}

class AuthNetworkDataSourceImpl implements AuthNetworkDataSource {
  final DioConfig _dio;

  AuthNetworkDataSourceImpl(this._dio);
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _initialized = false;
  Future<String?> _getGoogleIdToken() async {
    await _ensureInitialized();
    try {
      final GoogleSignInAccount account = await _googleSignIn.authenticate();
      return account.authentication.idToken; // synchronous getter in v7
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  @override
  Future<UserModel> getMyProfile() async {
    DioResponse response = await _dio.dioGetCall(EndPoints.myProfile);
    if (response.hasError) return response.handleError();
    final data = response.response!.data;

    return UserModel.fromJson(data['user']);
  }

  @override
  Future<LoginUserModel> login(String email, String password) async {
    DioResponse response = await _dio.dioPostCall(EndPoints.login, {
      'identifier': email,
      'password': password,
    });
    if (response.hasError) return response.handleError();
    final data = response.response!.data;
    String access = data['accessToken'] ?? '';
    String refresh = data['refreshToken'] ?? '';
    String rotation = data['rotationToken'] ?? '';
    final success = await AppData.storeTokens(access, refresh, rotation);
    if (!success.access) {
      throw const AppException(
        title: 'Access Failed',
        message: "Failed to store access data",
        code: 300,
      );
    } else if (!success.refresh) {
      throw const AppException(
        title: 'Refresh Failed',
        message: "Failed to store refresh data",
        code: 300,
      );
    } else if (!success.rotation) {
      throw const AppException(
        title: 'Rotation Failed',
        message: "Failed to store rotation data",
        code: 300,
      );
    }
    return LoginUserModel.fromJson(data);
  }

  @override
  Future<String> logout() async {
    await FirebasePhoneAuthService.signOut();
    await _googleSignIn.signOut();
    await AppData().clearValues();
    await DBHelper().deleteDatabaseFile();
    DioResponse response = await _dio.dioPostCall(EndPoints.logout, {});
    if (response.hasError) return response.handleError();
    final data = response.response!.data;
    return data['message'];
  }

  @override
  Future<String> logoutAll() async {
    await FirebasePhoneAuthService.signOut();
    await _googleSignIn.signOut();
    DioResponse response = await _dio.dioPostCall(EndPoints.logoutAll, {});
    if (response.hasError) return response.handleError();
    final data = response.response!.data;
    return data['message'];
  }

  @override
  Future<UserModel> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    DioResponse response = await _dio.dioPostCall(EndPoints.register, {
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
    });
    if (response.hasError) return response.handleError();
    final data = response.response!.data;
    String access = data['accessToken'] ?? '';
    String refresh = data['refreshToken'] ?? '';
    String rotation = data['rotationToken'] ?? '';
    final success = await AppData.storeTokens(access, refresh, rotation);
    if (!success.access) {
      throw const AppException(
        title: 'Access Failed',
        message: "Failed to store access data",
        code: 300,
      );
    } else if (!success.refresh) {
      throw const AppException(
        title: 'Refresh Failed',
        message: "Failed to store refresh data",
        code: 300,
      );
    } else if (!success.rotation) {
      throw const AppException(
        title: 'Rotation Failed',
        message: "Failed to store rotation data",
        code: 300,
      );
    }
    return UserModel.fromJson(data['user']);
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _googleSignIn.initialize(
      serverClientId:
          '1056452201526-kab68vb8vs4lrf605a8gke411evgsi24.apps.googleusercontent.com',
    );
    _initialized = true;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    final idToken = await _getGoogleIdToken();
    if (idToken == null) {
      throw const AppException(
        title: 'Login Failed',
        message: "Failed to login with google",
        code: 300,
      );
    }
    DioResponse response = await _dio.dioPostCall(EndPoints.googleLogin, {
      "idToken": idToken,
    });
    if (response.hasError) return response.handleError();
    final data = response.response!.data;
    String access = data['accessToken'] ?? '';
    String refresh = data['refreshToken'] ?? '';
    String rotation = data['rotationToken'] ?? '';
    final success = await AppData.storeTokens(access, refresh, rotation);
    if (!success.access) {
      throw const AppException(
        title: 'Access Failed',
        message: "Failed to store access data",
        code: 300,
      );
    } else if (!success.refresh) {
      throw const AppException(
        title: 'Refresh Failed',
        message: "Failed to store refresh data",
        code: 300,
      );
    } else if (!success.rotation) {
      throw const AppException(
        title: 'Rotation Failed',
        message: "Failed to store rotation data",
        code: 300,
      );
    }
    return UserModel.fromJson(data['user']);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Signs in to Firebase with the credential, grabs the ID token, and
  /// exchanges it with our backend for our own token set.
  Future<UserModel?> _signInAndExchange(PhoneAuthCredential credential) async {
    final userCredential = await _auth.signInWithCredential(credential);
    final idToken = await userCredential.user?.getIdToken();
    if (idToken == null) return null;

    return _exchangeWithBackend(idToken);
  }

  Future<UserModel> _exchangeWithBackend(String idToken) async {
    DioResponse response = await _dio.dioPostCall(
      EndPoints.firebasePhoneLogin,
      {"idToken": idToken},
    );
    if (response.hasError) return response.handleError();
    final data = response.response!.data;
    String access = data['accessToken'] ?? '';
    String refresh = data['refreshToken'] ?? '';
    String rotation = data['rotationToken'] ?? '';
    final success = await AppData.storeTokens(access, refresh, rotation);
    if (!success.access) {
      throw const AppException(
        title: 'Access Failed',
        message: "Failed to store access data",
        code: 300,
      );
    } else if (!success.refresh) {
      throw const AppException(
        title: 'Refresh Failed',
        message: "Failed to store refresh data",
        code: 300,
      );
    } else if (!success.rotation) {
      throw const AppException(
        title: 'Rotation Failed',
        message: "Failed to store rotation data",
        code: 300,
      );
    }
    return UserModel.fromJson(data['user']);
  }

  @override
  Future<void> signInWithPhoneRequestOtp({
    required String phoneNumber,
    required void Function() onCodeSent,
    required void Function(UserModel user) onAutoVerified,
    required void Function(String message) onError,
  }) async {
    await FirebasePhoneAuthService.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      signInAndExchange: _signInAndExchange,
      onAutoVerified: (result) => onAutoVerified(UserModel.fromEntity(result)),
      onError: onError,
    );
  }

  @override
  Future<UserModel> signInWithPhoneVerifyOtp(String otp) async {
    final entity = await FirebasePhoneAuthService.verifyOtp(
      otp,
      signInAndExchange: _signInAndExchange,
    );
    return UserModel.fromEntity(entity);
  }

  @override
  Future<String> signInWithEmailRequestOtp(String email) async {
    DioResponse response = await _dio.dioPostCall(EndPoints.emailRequestOtp, {
      "email": email,
    });
    if (response.hasError) return response.handleError();
    final data = response.response!.data;
    return data['message'] ?? '';
  }

  @override
  Future<UserModel> signInWithEmailVerifyOtp({
    required String email,
    required String otp,
  }) async {
    DioResponse response = await _dio.dioPostCall(EndPoints.emailVerifyOtp, {
      "email": email,
      "otp": otp,
    });
    if (response.hasError) return response.handleError();
    final data = response.response!.data;
    String access = data['accessToken'] ?? '';
    String refresh = data['refreshToken'] ?? '';
    String rotation = data['rotationToken'] ?? '';
    final success = await AppData.storeTokens(access, refresh, rotation);
    if (!success.access) {
      throw const AppException(
        title: 'Access Failed',
        message: "Failed to store access data",
        code: 300,
      );
    } else if (!success.refresh) {
      throw const AppException(
        title: 'Refresh Failed',
        message: "Failed to store refresh data",
        code: 300,
      );
    } else if (!success.rotation) {
      throw const AppException(
        title: 'Rotation Failed',
        message: "Failed to store rotation data",
        code: 300,
      );
    }
    return UserModel.fromJson(data['user']);
  }
}
