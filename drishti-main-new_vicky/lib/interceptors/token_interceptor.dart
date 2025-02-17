import 'dart:async';

import 'package:dio/dio.dart';
import 'package:srisridrishti/utils/shared_preference_helper.dart';

class TokenInterceptor extends Interceptor {
  final Dio dio;

  TokenInterceptor(this.dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    print('REQUEST[${options.method}] => PATH: ${options.path}');

    // Skip token for refresh and login requests
    if (options.path.contains('refresh') || options.path.contains('login')) {
      return handler.next(options);
    }

    try {
      final token = await SharedPreferencesHelper.getActiveToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      }

      return handler.reject(
        DioException(
          requestOptions: options,
          error: 'No valid authentication token available',
          type: DioExceptionType.unknown,
        ),
      );
    } catch (e) {
      print('REQUEST ERROR: $e');
      return handler.reject(
        DioException(
          requestOptions: options,
          error: 'Error while getting authentication token: $e',
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final options = err.requestOptions;

      // Don't retry refresh token requests
      if (options.path.contains('refresh')) {
        print('Refresh token request failed - clearing tokens');
        await SharedPreferencesHelper.clearTokens();
        return handler.next(err);
      }

      try {
        // Get a fresh token
        final newToken = await SharedPreferencesHelper.getActiveToken();
        if (newToken == null) {
          print('No valid token available after refresh attempt');
          return handler.next(err);
        }

        // Create new request with updated token
        final opts = Options(
          method: options.method,
          headers: {
            ...options.headers,
            'Authorization': 'Bearer $newToken',
          },
        );

        // Retry the request
        final response = await dio.request(
          options.path,
          data: options.data,
          queryParameters: options.queryParameters,
          options: opts,
        );

        return handler.resolve(response);
      } catch (e) {
        print('Error during request retry: $e');
        return handler.next(err);
      }
    }

    return handler.next(err);
  }
}
