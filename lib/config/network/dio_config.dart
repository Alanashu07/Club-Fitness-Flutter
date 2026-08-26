import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:club_fitness/config/local/app_data.dart';
import 'package:club_fitness/core/services/connectivity_checker.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

import '../../core/exceptions/app_exception.dart';
import '../../core/exceptions/status_codes.dart';
import 'end_points.dart';

class DioConfig {
  static final DioConfig _dioConfig = DioConfig._();

  factory DioConfig() => _dioConfig;

  Dio? _dio;

  Dio? get getDio => _dio;

  String get bearer => AppData.accessTokenValue;

  String get refresh => AppData.refreshTokenValue;

  String get rotation => AppData.rotationTokenValue;

  void initDio() {
    _dio = Dio();
    _dio!.options.baseUrl = EndPoints.baseUrl;
    _dio!.interceptors.addAll([
      if (kDebugMode)
        TalkerDioLogger(
          settings: const TalkerDioLoggerSettings(
            printRequestHeaders: kDebugMode,
            printResponseHeaders: kDebugMode,
            printResponseMessage: kDebugMode,
          ),
        ),
      ConnectivityChecker(),
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = bearer;
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Skip interception for refresh endpoint to avoid recursion
          if (error.requestOptions.path.contains('/auth/') && !error.requestOptions.path.endsWith('me')) {
            return handler.next(error);
          }

          if (error.response?.statusCode == 401) {
            if (!_isRefreshing) {
              _isRefreshing = true;
              _refreshCompleter = Completer();

              // Try to refresh tokens
              final success = await _refreshToken();

              if (success) {
                _refreshCompleter!.complete(true);
                _isRefreshing = false;

                final newToken = bearer;
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newToken';
                final cloneReq = await _dio!.fetch(error.requestOptions);
                return handler.resolve(cloneReq);
              } else {
                // Refresh failed, try rotation token
                final rotateSuccess = await _rotateTokens();

                if (rotateSuccess) {
                  _refreshCompleter!.complete(true);
                  _isRefreshing = false;

                  final newToken = bearer;
                  error.requestOptions.headers['Authorization'] =
                      'Bearer $newToken';
                  final cloneReq = await _dio!.fetch(error.requestOptions);
                  return handler.resolve(cloneReq);
                } else {
                  // Both refresh and rotation failed, force logout
                  _refreshCompleter!.complete(false);
                  _isRefreshing = false;
                  await _handleLogout();
                  return handler.reject(error);
                }
              }
            } else {
              final success = await _refreshCompleter!.future;

              if (success) {
                final newToken = bearer;
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newToken';
                final cloneReq = await _dio!.fetch(error.requestOptions);
                return handler.resolve(cloneReq);
              } else {
                return handler.reject(error);
              }
            }
          }

          return handler.next(error);
        },
      ),
    ]);
  }

  Completer<bool>? _refreshCompleter;
  bool _isRefreshing = false;

  Future<bool> _refreshToken() async {
    if (refresh.isEmpty) return false;

    try {
      final formData = {"refreshToken": refresh};
      DioResponse response = await DioConfig().dioPostCall(
        EndPoints.refresh,
        formData,
      );

      if (response.hasError) {
        return false;
      }

      final data = response.response!.data;
      final accessToken = data['accessToken'].toString();
      final refreshToken = data['refreshToken'].toString();
      final rotationToken = data['rotationToken'].toString();

      await AppData().storeAccessToken(accessToken);
      await AppData().storeRefreshToken(refreshToken);
      await AppData().storeRotationToken(rotationToken);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Refresh token failed: $e');
      }
      return false;
    }
  }

  Future<bool> _rotateTokens() async {
    if (rotation.isEmpty) return false;

    try {
      final formData = {"rotationToken": rotation};
      DioResponse response = await DioConfig().dioPostCall(
        EndPoints.rotate,
        formData,
      );

      if (response.hasError) {
        final data = response.dioError.response?.data;

        // Check if rotation token is invalidated
        if (data != null && data['error'] != null) {
          final errorMsg = data['error'].toString();
          if (errorMsg.contains('invalidated') ||
              errorMsg.contains('Please login again')) {
            // Rotation token is blacklisted, force logout
            return false;
          }
        }
        return false;
      }

      final data = response.response!.data;
      final accessToken = data['accessToken'].toString();
      final refreshToken = data['refreshToken'].toString();
      final rotationToken = data['rotationToken'].toString();

      await AppData().storeAccessToken(accessToken);
      await AppData().storeRefreshToken(refreshToken);
      await AppData().storeRotationToken(rotationToken);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Rotation token failed: $e');
      }
      return false;
    }
  }

  Future<void> _handleLogout() async {
    // Clear all tokens
    // await AppData().clearAccessToken();
    // await AppData().clearRefreshToken();
    // await AppData().clearRotationToken();

    // You can add navigation logic here or emit an event
    // For example, navigate to login screen or emit a logout event
    if (kDebugMode) {
      print('All tokens expired or invalidated. User needs to login again.');
    }
  }

  DioConfig._() {
    initDio();
  }

  Future<DioResponse> dioPostCallNoBase(
    String url,
    formData, {
    Function(int received, int total)? sendProgress,
    Function(int received, int total)? onReceiveProgress,
  }) async {
    Response response;
    try {
      Dio noBaseDio = Dio();
      response = await noBaseDio.post(
        url,
        data: formData,
        onSendProgress: sendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (dioError) {
      return DioResponse.hasError(dioError);
    }
    return DioResponse.hasResponse(response);
  }

  Future<DioResponse> dioDownloadMedia(
    String url, {
    Function(int received, int total)? onReceiveProgress,
  }) async {
    Response response;
    try {
      response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (dioError) {
      return DioResponse.hasError(dioError);
    }
    return DioResponse.hasResponse(response);
  }

  Future<DioResponse> dioPutCallNoBase(
    String url, {
    formData,
    String? contentType,
    Function(int received, int total)? onReceiveProgress,
    Function(int received, int total)? onSendProgress,
  }) async {
    Response response;
    try {
      Dio noBaseDio = Dio();
      final headers = {if (contentType != null) 'Content-Type': contentType};
      response = await noBaseDio.put(
        url,
        data: formData,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        options: Options(headers: headers),
      );
    } on DioException catch (dioError) {
      return DioResponse.hasError(dioError);
    }
    return DioResponse.hasResponse(response);
  }

  Future<DioResponse> dioPostCall(
    String url,
    formData, {
    Function? sendProgress,
  }) async {
    Response response;
    try {
      response = await getDio!.post(
        url,
        data: formData,
        onSendProgress: sendProgress as void Function(int, int)?,
      );
    } on DioException catch (dioError) {
      return DioResponse.hasError(dioError);
    }
    return DioResponse.hasResponse(response);
  }

  Future<DioResponse> dioFormCall(
    String url,
    formData, {
    Function? sendProgress,
  }) async {
    Response response;
    try {
      response = await getDio!.post(
        url,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
        onSendProgress: sendProgress as void Function(int, int)?,
      );
    } on DioException catch (dioError) {
      return DioResponse.hasError(dioError);
    }
    return DioResponse.hasResponse(response);
  }

  Future<DioResponse> dioGetCall(String url) async {
    Response response;
    try {
      response = await getDio!.get(url);
    } on DioException catch (dioError) {
      return DioResponse.hasError(dioError);
    }
    return DioResponse.hasResponse(response);
  }

  Future<DioResponse> dioGetCallParams(String url, Map queryParams) async {
    Response response;
    try {
      response = await getDio!.get(
        url,
        queryParameters: queryParams as Map<String, dynamic>?,
      );
    } on DioException catch (dioError) {
      return DioResponse.hasError(dioError);
    }
    return DioResponse.hasResponse(response);
  }

  Future<DioResponse> dioGetMedia(
    String url, [
    void Function(int received, int total)? onReceiveProgress,
  ]) async {
    Response response;
    try {
      response = await getDio!.get(
        url,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (dioError) {
      return DioResponse.hasError(dioError);
    }
    return DioResponse.hasResponse(response);
  }

  Future<DioResponse> dioPostCallParams(String url, Map queryParams) async {
    Response response;
    try {
      response = await getDio!.post(
        url,
        data: queryParams as Map<String, dynamic>?,
      );
    } on DioException catch (dioError) {
      return DioResponse.hasError(dioError);
    }
    return DioResponse.hasResponse(response);
  }

  Future<DioResponse> dioDeleteCall(String url, [formData]) async {
    Response response;
    try {
      response = await getDio!.delete(url, data: formData);
    } on DioException catch (dioError) {
      return DioResponse.hasError(dioError);
    }
    return DioResponse.hasResponse(response);
  }

  Future<DioResponse> dioPutCall(String url, [formData]) async {
    Response response;
    try {
      response = await getDio!.put(url, data: formData);
    } on DioException catch (dioError) {
      return DioResponse.hasError(dioError);
    }
    return DioResponse.hasResponse(response);
  }

  Future<DioResponse> dioPatchCall(String url, [formData]) async {
    Response response;
    try {
      response = await getDio!.patch(url, data: formData);
    } on DioException catch (dioError) {
      return DioResponse.hasError(dioError);
    }
    return DioResponse.hasResponse(response);
  }
}

class DioResponse {
  Response? response;

  bool hasError = false;
  String errorMessage = '';
  late DioException dioError;

  Future<T> handleError<T>({
    Future<T> Function()? retryFunction,
    Future<void> Function()? refresh,
  }) async {
    final data = dioError.response?.data;

    if (data == null || data is! Map<String, dynamic>) {
      throw StatusCodes.errorFromCodeOrType(
        dioError.response?.statusCode,
        dioError.type,
      );
    }
    final failure = data['failure'];
    if(failure != null) {
      throw AppException.fromJson(failure);
    }

    final String? message = data['error'];
    final String? codeStr = data['code'];
    final int code = dioError.response?.statusCode ?? StatusCodes.unknownError;

    if (message != null && codeStr != null) {
      int? errorCode = dioError.response?.statusCode;
      if (errorCode == null) {
        throw StatusCodes.errorFromCodeOrType(
          dioError.response?.statusCode,
          dioError.type,
        );
      } else {
        throw StatusCodes.errorFromStatusCode(code);
      }
    }

    throw AppException(
      title: codeStr?.splitUnderscoreAndCapitalize ?? 'Unable to proceed',
      message: message ?? errorMessage,
      code: code,
    );
  }

  Map<String, String> normalizeErrors() {
    final errors = dioError.response?.data;
    final Map<String, String> normalized = {};

    if (errors == null || errors is! Map<String, dynamic>) {
      return normalized;
    }

    errors.forEach((key, value) {
      if (value is String) {
        // Direct string
        normalized[key] = value;
      } else if (value is List) {
        // Join list of strings
        normalized[key] = value.join(", ");
      } else if (value is Map) {
        // Recursively flatten nested map
        value.forEach((nestedKey, nestedValue) {
          if (nestedValue is String) {
            normalized[nestedKey] = nestedValue;
          } else if (nestedValue is List) {
            normalized[nestedKey] = nestedValue.join(", ");
          } else {
            normalized[nestedKey] = nestedValue.toString();
          }
        });
      } else {
        // Fallback to string conversion
        normalized[key] = value.toString();
      }
    });

    return normalized;
  }

  DioResponse.hasResponse(this.response) {
    hasError = false;
  }

  DioResponse.hasError(this.dioError) {
    hasError = true;

    switch (dioError.type) {
      case DioExceptionType.sendTimeout:
        errorMessage = 'Request Timeout';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Response Timeout';
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request Cancelled';
        break;
      case DioExceptionType.connectionTimeout:
        errorMessage = 'connection Timeout';
        break;
      case DioExceptionType.badCertificate:
        errorMessage = 'badCertificate';
        break;
      case DioExceptionType.badResponse:
        errorMessage = 'bad response';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'connection error';
        break;
      case DioExceptionType.unknown:
        errorMessage = 'Unknown error';
        break;
    }
  }
}
