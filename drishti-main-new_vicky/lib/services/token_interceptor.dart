import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenInterceptor extends Interceptor {
  final Dio dio;
  final SharedPreferences prefs;

  TokenInterceptor({required this.dio, required this.prefs});

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      try {
        final refreshToken = prefs.getString('refreshToken');
        if (refreshToken != null) {
          final response = await dio.post(
            '/auth/refresh-token',
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200) {
            // Save new tokens
            final newAccessToken = response.data['accessToken'];
            await prefs.setString('accessToken', newAccessToken);

            // Retry the failed request
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await dio.fetch(options);
            return handler.resolve(retryResponse);
          }
        }
      } catch (e) {
        // If refresh fails, logout user
        await prefs.clear();
      }
    }
    return handler.next(err);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final accessToken = prefs.getString('accessToken');
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }
}
