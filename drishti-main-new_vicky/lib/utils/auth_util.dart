import 'package:shared_preferences/shared_preferences.dart';

class AuthUtil {
  static Future<String?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString("UserID");
    return userID != null && userID.isNotEmpty ? userID : null;
  }

  static Future<bool> isAuthenticated() async {
    final userID = await getUserId();
    return userID != null;
  }

  static Future<void> storeUserId(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("UserID", userId);
  }
}
