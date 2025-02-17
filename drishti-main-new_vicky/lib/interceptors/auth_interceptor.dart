import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:srisridrishti/services/auth_services/token_service.dart';
import 'package:srisridrishti/utils/shared_preference_helper.dart';
import 'package:srisridrishti/services/auth_service.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  bool isRefreshing = false;
  final _queue = <QueueItem>[];

  AuthInterceptor(this.dio);

  bool isTokenExpired(String? token) {
    if (token == null || token.isEmpty) return true;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      // Decode payload
      String payload = parts[1];
      // Add padding if needed
      while (payload.length % 4 != 0) {
        payload += '=';
      }

      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> data = json.decode(decoded);

      if (!data.containsKey('exp')) return true;

      final exp = data['exp'];
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      // Add 5 seconds buffer to prevent edge cases
      return DateTime.now().add(const Duration(seconds: 5)).isAfter(expiryDate);
    } catch (e) {
      print('Error checking token expiration: $e');
      return true;
    }
  }

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      String? token = await SharedPreferencesHelper.getAccessToken();

      if (token != null && token.isNotEmpty) {
        if (isTokenExpired(token) && !isRefreshing) {
          print('Access token expired, attempting refresh...');
          final newToken = await _refreshToken();
          if (newToken != null) {
            token = newToken;
          } else {
            // Token refresh failed, clear tokens and throw error
            await TokenService.clearTokens();
            throw DioException(
              requestOptions: options,
              error: 'Token refresh failed',
              type: DioExceptionType.unknown,
            );
          }
        }
        options.headers['Authorization'] = 'Bearer $token';
      }

      return handler.next(options);
    } catch (e) {
      print('Error in request interceptor: $e');
      return handler.reject(
        DioException(
          requestOptions: options,
          error: e.toString(),
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  Future<String?> _refreshToken() async {
    if (isRefreshing) return null;

    isRefreshing = true;
    try {
      final refreshToken = await SharedPreferencesHelper.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      final response = await AuthService().refreshToken(refreshToken);
      if (response?.statusCode == 200 && response?.data != null) {
        final newAccessToken = response!.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];

        // Save new tokens
        await SharedPreferencesHelper.setAccessToken(newAccessToken);
        await SharedPreferencesHelper.setRefreshToken(newRefreshToken);

        return newAccessToken;
      }
      return null;
    } catch (e) {
      print('Error refreshing token: $e');
      return null;
    } finally {
      isRefreshing = false;
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final options = err.requestOptions;

      // Add to queue if already refreshing
      if (isRefreshing) {
        return await _enqueueRequest(options, handler);
      }

      try {
        final newToken = await _refreshToken();
        if (newToken != null) {
          // Update request authorization header
          options.headers['Authorization'] = 'Bearer $newToken';

          // Retry the request
          final response = await dio.fetch(options);
          return handler.resolve(response);
        }
      } catch (e) {
        print('Error handling 401: $e');
      }
    }
    return handler.next(err);
  }

  Future<void> _enqueueRequest(
    RequestOptions options,
    ErrorInterceptorHandler handler,
  ) async {
    _queue.add(QueueItem(options, handler));
  }

  Future<Response<dynamic>> _retry(QueueItem item) async {
    return await dio.fetch(item.options);
  }
}

class QueueItem {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;

  QueueItem(this.options, this.handler);
}
