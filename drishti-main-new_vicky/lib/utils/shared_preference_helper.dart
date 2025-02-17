import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:srisridrishti/utils/api_constants.dart';

class SharedPreferencesHelper {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _onboardingCompleteKey = 'onboardingComplete';
  static const String _accessTokenExpiryKey = 'accessTokenExpiresAt';
  static const String _refreshTokenExpiryKey = 'refreshTokenExpiresAt';

  // Save access token (keeping both old and new method names for compatibility)
  static Future<void> setAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  static Future<void> saveAccessToken(String token) async {
    await setAccessToken(token);
  }

  // Save refresh token (keeping both old and new method names for compatibility)
  static Future<void> setRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  static Future<void> saveRefreshToken(String token) async {
    await setRefreshToken(token);
  }

  // Token expiry methods
  static Future<void> saveAccessTokenExpiry(String expiry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenExpiryKey, expiry);
  }

  static Future<void> saveRefreshTokenExpiry(String expiry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenExpiryKey, expiry);
  }

  // Get tokens
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Clear tokens
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_accessTokenExpiryKey);
    await prefs.remove(_refreshTokenExpiryKey);
    print("Tokens cleared from storage");
  }

  static Future<void> clearAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
  }

  static Future<void> clearRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_refreshTokenKey);
  }

  // Onboarding methods
  static Future<void> setOnboardingComplete(bool isComplete) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, isComplete);
  }

  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  // Device token methods
  static Future<void> saveDeviceToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_token', token);
  }

  static Future<String?> getDeviceToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('device_token');
  }

  // Save user credentials
  static Future<void> saveUserCredentials(String userId, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('UserID', userId);
    await prefs.setString('accessToken', token);

    // Verify storage
    print('Stored UserID: ${prefs.getString('UserID')}');
    print('Stored accessToken: ${prefs.getString('accessToken')}');
  }

  // Add this new method
  static Future<String?> getActiveToken() async {
    try {
      print('TOKEN CHECK: Starting token validation');

      // Get both tokens
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();

      // Check access token first
      if (accessToken != null && accessToken.isNotEmpty) {
        if (!isTokenExpired(accessToken)) {
          print('TOKEN CHECK: Access token is valid');
          return accessToken;
        }
        print('TOKEN CHECK: Access token expired');
      }

      // Try refresh token if access token is invalid
      if (refreshToken != null && refreshToken.isNotEmpty) {
        if (!isTokenExpired(refreshToken)) {
          print('TOKEN CHECK: Attempting to get new access token');
          return await refreshAccessToken(refreshToken);
        }
        print('TOKEN CHECK: Refresh token expired');
      }

      // Clear tokens if both are invalid
      await clearTokens();
      return null;
    } catch (e) {
      print('TOKEN CHECK: Error during token validation: $e');
      await clearTokens();
      return null;
    }
  }

  static Future<String?> refreshAccessToken(String refreshToken) async {
    try {
      print("Attempting to refresh access token...");
      final dio = Dio();

      final response = await dio
          .post(
            ApiConstants.refreshToken,
            data: {'refreshToken': refreshToken},
            options: Options(
              headers: {'Content-Type': 'application/json'},
              validateStatus: (status) => status! < 500,
            ),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null &&
            data['accessToken'] is String &&
            data['refreshToken'] is String) {
          // Save new tokens
          await saveAccessToken(data['accessToken']);
          await saveRefreshToken(data['refreshToken']);

          // Save expiration times
          if (data['accessTokenExpiresAt'] != null) {
            await saveAccessTokenExpiry(data['accessTokenExpiresAt']);
          }
          if (data['refreshTokenExpiresAt'] != null) {
            await saveRefreshTokenExpiry(data['refreshTokenExpiresAt']);
          }

          print("Successfully refreshed access token");
          return data['accessToken'];
        } else {
          print("Invalid token data format");
          await clearTokens();
          return null;
        }
      } else {
        print("Failed to refresh token: ${response.statusCode}");
        await clearTokens();
        return null;
      }
    } catch (e) {
      print("Error refreshing token: $e");
      await clearTokens();
      return null;
    }
  }

  static bool isTokenExpired(String token) {
    try {
      if (token.isEmpty) return true;

      final parts = token.split('.');
      if (parts.length != 3) return true;

      final normalizedBase64 = base64Url.normalize(parts[1]);
      final decodedJson = utf8.decode(base64Url.decode(normalizedBase64));
      final payload = jsonDecode(decodedJson) as Map<String, dynamic>;

      if (!payload.containsKey('exp')) return true;

      final exp = payload['exp'] as int;
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      // Add 5 second buffer to prevent edge cases
      return now.isAfter(expiry.subtract(const Duration(seconds: 5)));
    } catch (e) {
      print("Error parsing token: $e");
      return true;
    }
  }
}
