import 'dart:async';

import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:srisridrishti/services/auth_services/token_service.dart';
import 'package:srisridrishti/utils/shared_preference_helper.dart';
import 'package:srisridrishti/services/auth_service.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  bool isRefreshing = false;
  List<Future Function(String?)> refreshQueue = [];

  AuthInterceptor(this.dio);

  Future<void> _enqueueRequest(RequestOptions options, ErrorInterceptorHandler handler) {
    final completer = Completer<void>();
    
    refreshQueue.add((String? token) async {
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        try {
          final response = await dio.fetch(options);
          handler.resolve(response);
        } catch (e) {
          handler.reject(
            DioException(
              requestOptions: options,
              error: e.toString(),
              type: DioExceptionType.unknown,
            ),
          );
        }
      }
    });
    
    return completer.future;
  }

  bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final normalizedBase64 = base64Url.normalize(parts[1]);
      final payload = jsonDecode(utf8.decode(base64Url.decode(normalizedBase64)));
      
      if (!payload.containsKey('exp')) return true;

      final exp = payload['exp'];
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().add(const Duration(minutes: 1)).isAfter(expiryDate);
    } catch (e) {
      print('Error checking token expiration: $e');
      return true;
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.path.contains('refresh') || options.path.contains('login')) {
      return handler.next(options);
    }

    try {
      String? token = await SharedPreferencesHelper.getAccessToken();

      if (token != null && token.isNotEmpty) {
        if (isTokenExpired(token) && !isRefreshing) {
          print('Access token expired, attempting refresh...');
          final newToken = await _refreshToken();
          if (newToken != null) {
            token = newToken;
          } else {
            return handler.reject(
              DioException(
                requestOptions: options,
                error: 'Token refresh failed',
                type: DioExceptionType.unknown,
              ),
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

      final response = await dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];

        await SharedPreferencesHelper.setAccessToken(newAccessToken);
        await SharedPreferencesHelper.setRefreshToken(newRefreshToken);

        // Process queued requests
        for (var callback in refreshQueue) {
          await callback(newAccessToken);
        }
        refreshQueue.clear();

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

      if (options.path.contains('refresh')) {
        // Clear tokens on refresh failure
        await TokenService.clearTokens();
        return handler.next(err);
      }

      if (isRefreshing) {
        return await _enqueueRequest(options, handler);
      }

      try {
        final newToken = await _refreshToken();
        if (newToken != null) {
          options.headers['Authorization'] = 'Bearer $newToken';
          final response = await dio.fetch(options);
          return handler.resolve(response);
        }
      } catch (e) {
        print('Error handling 401: $e');
        await TokenService.clearTokens();
      }
    }
    return handler.next(err);
  }
}
