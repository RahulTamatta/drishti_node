import 'package:dio/dio.dart';
import '../utils/shared_preference_helper.dart';

class TokenInterceptor extends Interceptor {
  final Dio dio;

  TokenInterceptor(this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await SharedPreferencesHelper.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = accessToken;
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired
      try {
        final refreshToken = await SharedPreferencesHelper.getRefreshToken();
        if (refreshToken != null) {
          final response = await dio.post(
            '/auth/refresh-token',
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['data']['accessToken'];
            final newRefreshToken = response.data['data']['refreshToken'];

            await SharedPreferencesHelper.saveAccessToken(newAccessToken);
            await SharedPreferencesHelper.saveRefreshToken(newRefreshToken);

            // Retry original request with new token
            final opts = err.requestOptions;
            opts.headers['Authorization'] = newAccessToken;
            
            final retryResponse = await dio.fetch(opts);
            return handler.resolve(retryResponse);
          }
        }
      } catch (e) {
        // Refresh failed - clear tokens and redirect to login
        await SharedPreferencesHelper.clearAccessToken();
        await SharedPreferencesHelper.clearRefreshToken();
      }
    }
    return handler.next(err);
  }
}