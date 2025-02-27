import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'token_interceptor.dart';

class ApiService {
  late Dio _dio;
  final SharedPreferences _prefs;

  ApiService(this._prefs) {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://drishtinode-production.up.railway.app',
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
    ));

    _dio.interceptors.add(TokenInterceptor(dio: _dio, prefs: _prefs));
  }

  Future<Response> get(String path) async {
    try {
      return await _dio.get(path);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(String path, dynamic data) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      rethrow;
    }
  }

  // Add other HTTP methods as needed
}
