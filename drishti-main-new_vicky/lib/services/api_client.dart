import 'package:dio/dio.dart';

import 'package:srisridrishti/interceptors/auth_interceptor.dart';
import 'package:srisridrishti/utils/api_constants.dart';

class ApiClient {
  static Dio? _dio;

  static Dio get dio {
    if (_dio == null) {
      _dio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ));

      _dio!.interceptors.add(AuthInterceptor(_dio!));
    }
    return _dio!;
  }
}
