import 'package:club_fitness/core/exceptions/status_codes.dart';

class AppException {
  final String title;
  final String message;
  final int code;
  final bool isMap;

  const AppException({
    required this.title,
    required this.message,
    required this.code,
    this.isMap = false,
  });

  factory AppException.fromJson(Map<String, dynamic> map) {
    return AppException(
      title: map['title'],
      message: map['message'],
      code: map['code'],
    );
  }

  static const AppException badRequest = AppException(
    title: 'Something Went Wrong',
    message:
        "We couldn't process your request. Please check your input and try again.",
    code: StatusCodes.badRequest,
  );

  static const AppException unauthorized = AppException(
    title: 'Unauthorized',
    message: 'Unauthorized access. Please log in and try again.',
    code: StatusCodes.unauthorized,
  );

  static const AppException forbidden = AppException(
    title: 'Forbidden',
    message:
        'Access forbidden. You don\'t have permission to access this resource.',
    code: StatusCodes.forbidden,
  );

  static const AppException notFound = AppException(
    title: 'Not Found',
    message: 'The requested resource was not found.',
    code: StatusCodes.notFound,
  );

  static const AppException conflict = AppException(
    title: 'Conflict',
    message:
        'The request could not be completed due to a conflict. Please resolve and try again.',
    code: StatusCodes.conflict,
  );

  static const AppException invalidData = AppException(
    title: 'Invalid Data',
    message: 'Invalid data. Please check the data provided and try again.',
    code: StatusCodes.unprocessableEntity,
  );

  static const AppException noInternet = AppException(
    title: 'No Internet',
    message: 'Please check your internet connection',
    code: StatusCodes.noInternet,
  );

  static const AppException timeout = AppException(
    title: 'Timeout',
    message: 'Request Timeout',
    code: StatusCodes.timeout,
  );

  static const AppException serverError = AppException(
    title: 'Server Error',
    message: 'Internal server error. Please try again later.',
    code: StatusCodes.serverError,
  );

  static const AppException notImplemented = AppException(
    title: 'Not Implemented',
    message: 'This feature is not implemented yet.',
    code: StatusCodes.notImplemented,
  );

  static const AppException serviceUnavailable = AppException(
    title: 'Service Unavailable',
    message: 'Service unavailable. Please try again later.',
    code: StatusCodes.serviceUnavailable,
  );

  @override
  String toString() {
    return "The error is: \nTitle: $title \nMessage: $message \nCode: $code";
  }
}
