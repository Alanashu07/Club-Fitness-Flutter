import 'package:dio/dio.dart';

import 'app_exception.dart';

class StatusCodes {
  // Success
  static const int success = 200;
  static const int created = 201;
  static const int noContent = 204;

  // Client Errors
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int unprocessableEntity = 422;

  // Server Errors
  static const int serverError = 500;
  static const int notImplemented = 501;
  static const int serviceUnavailable = 503;

  //Network Errors
  static const int noInternet = -1;
  static const int timeout = -2;

  // Unknown
  static const int unknownError = -999;

  static AppException errorFromCodeOrType(
    int? code,
    DioExceptionType type, {
    String? fallbackTitle,
    String? fallbackMessage,
  }) {
    if (code != null) {
      return errorFromStatusCode(
        code,
        fallbackMessage: fallbackMessage,
        fallbackTitle: fallbackTitle,
      );
    } else {
      return errorFromType(
        type,
        fallbackMessage: fallbackMessage,
        fallbackTitle: fallbackTitle,
      );
    }
  }

  static AppException errorFromType(
    DioExceptionType type, {
    String? fallbackTitle,
    String? fallbackMessage,
  }) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException.timeout;
      case DioExceptionType.badCertificate:
      case DioExceptionType.badResponse:
        return AppException.badRequest;
      case DioExceptionType.cancel:
        return AppException.conflict;
      case DioExceptionType.connectionError:
        return AppException.noInternet;
      case DioExceptionType.unknown:
        return AppException(
          title: fallbackTitle ?? 'Unknown Error',
          message: fallbackMessage ?? 'An unknown error occurred',
          code: unknownError,
        );
    }
  }

  static AppException errorFromStatusCode(
    int code, {
    String? fallbackTitle,
    String? fallbackMessage,
  }) {
    switch (code) {
      case badRequest:
        return AppException.badRequest;
      case unauthorized:
        return AppException.unauthorized;
      case forbidden:
        return AppException.forbidden;
      case notFound:
        return AppException.notFound;
      case conflict:
        return AppException.conflict;
      case unprocessableEntity:
        return AppException.invalidData;
      case serverError:
        return AppException.serverError;
      case notImplemented:
        return AppException.notImplemented;
      case serviceUnavailable:
        return AppException.serviceUnavailable;
      case noInternet:
        return AppException.noInternet;
      case timeout:
        return AppException.timeout;
      default:
        return AppException(
          title: fallbackTitle ?? 'Unknown Error',
          message: fallbackMessage ?? 'An unknown error occurred',
          code: unknownError,
        );
    }
  }
}
