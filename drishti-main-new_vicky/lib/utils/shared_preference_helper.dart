import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _accessTokenKey = 'accessToken';
  static const String _onboardingCompleteKey = 'onboardingComplete';

  // Save access token
  static Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
  }

  static Future<void> clearRefreshToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('refreshToken');
  }

  // Retrieve access token
  static Future<String?> getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Clear access token
  static Future<void> clearAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
  }

  // Save onboarding status
  static Future<void> setOnboardingComplete(bool isComplete) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, isComplete);
  }

// Shared Preference Method for Device Token
  static Future<void> saveDeviceToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_token', token);
  }

  static Future<String?> getDeviceToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('device_token');
  }

  static const String _userDataKey = 'user_data';

  static Future<bool> isOnboardingComplete() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refreshToken', token);
  }

  static Future<void> saveAccessTokenExpiry(String expiry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessTokenExpiresAt', expiry);
  }

  static Future<void> saveRefreshTokenExpiry(String expiry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refreshTokenExpiresAt', expiry);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }
}
