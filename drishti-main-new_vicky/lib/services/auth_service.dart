import 'package:dio/dio.dart';
import 'package:srisridrishti/utils/api_constants.dart';

class AuthService {
  final Dio _dio = Dio();

  Future<Response?> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      return response;
    } catch (e) {
      print('Error refreshing token: $e');
      return null;
    }
  }

  // ...existing auth methods...
}
