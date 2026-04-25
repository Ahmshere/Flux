import 'package:dio/dio.dart';

class ApiClient {
  static Dio create() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/json'},
      ),
    );

    // Логирование в debug-режиме
    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (obj) => debugPrintThrottled(obj.toString()),
      ),
    );

    // Retry при сетевых ошибках
    dio.interceptors.add(_RetryInterceptor(dio));

    return dio;
  }
}

class _RetryInterceptor extends Interceptor {
  final Dio dio;
  _RetryInterceptor(this.dio);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = (options.extra['attempt'] as int?) ?? 0;

    if (attempt < 2 && _isRetryable(err)) {
      await Future.delayed(Duration(seconds: attempt + 1));
      options.extra['attempt'] = attempt + 1;
      try {
        final response = await dio.fetch(options);
        handler.resolve(response);
        return;
      } catch (_) {}
    }
    handler.next(err);
  }

  bool _isRetryable(DioException e) =>
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.connectionError;
}

void debugPrintThrottled(String message) {
  // ignore: avoid_print
  print(message);
}
