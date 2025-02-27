import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:srisridrishti/utils/shared_preference_helper.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<Map<String, dynamic>> toggleNotification(String eventId) async {
    try {
      String? token = await SharedPreferencesHelper.getAccessToken() ??
          await SharedPreferencesHelper.getRefreshToken();

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/notifications/subscribe/$eventId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final bool isSubscribed =
            responseBody['data']['isOneHourReminder'] != null;

        return {
          'success': true,
          'isSubscribed': isSubscribed,
          'message': isSubscribed
              ? 'Subscribed to notifications'
              : 'Unsubscribed from notifications'
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to toggle notifications: ${response.body}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}
