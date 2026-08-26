import 'package:dio/dio.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityChecker extends Interceptor {
  final _connectivity = InternetConnection();
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final hasConnection = await _connectivity.hasInternetAccess;
    if (!hasConnection) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'No internet connection',
        ),
      );
    }
    return handler.next(options);
  }
}
