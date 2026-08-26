import 'package:flutter/foundation.dart';

import 'app_exception.dart';

class Failure {
  final String title;
  final String message;
  final int code;
  final bool isMap;

  const Failure({
    required this.title,
    required this.message,
    required this.code,
    this.isMap = false,
  });

  factory Failure.fromJson(Map<String, dynamic> map) {
    return Failure(
      title: map['title'],
      message: map['message'],
      code: map['code'],
    );
  }

  factory Failure.fromException(Object e) {
    if (e is AppException) {
      if(e.code == 401) {
        return ForceLoginFailure(
          message: e.message,
          code: e.code,
          title: e.title,
          isMap: e.isMap,
        );
      }
      return Failure(
        message: e.message,
        code: e.code,
        title: e.title,
        isMap: e.isMap,
      );
    }
    if (kDebugMode) {
      return Failure(
        title: 'Unable to proceed',
        message: e.toString(),
        code: -999,
      );
    }
    return unknown;
  }

  static const Failure unknown = Failure(
    message: 'An Unexpected Error Occurred. Please Try again',
    code: -999,
    title: 'Unknown Error',
  );

  static const Failure endOfResult = Failure(
    title: '------- END OF RESULTS -------',
    message: 'The Result ends here. No more data found!',
    code: 300,
  );

  static const Failure allCaughtUp = Failure(
    title: 'You\'re all caught up',
    message: 'You\'ve reached the end of the results! No more data found!',
    code: 300,
  );
}

class ForceLoginFailure extends Failure {
  const ForceLoginFailure({
    required super.title,
    required super.message,
    required super.code,
    super.isMap,
  });
}
