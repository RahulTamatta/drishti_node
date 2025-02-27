import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  late final String baseUrl;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal() {
    baseUrl =
        'http://drishtinode-production.up.railway.app'; // Development URL, adjust for production
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // Request permissions
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configure local notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Handle notification tap
        if (response.payload != null) {
          final data = json.decode(response.payload!);
          // Handle navigation based on notification type
          _handleNotificationTap(data);
        }
      },
    );

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    // Update FCM token when it refreshes
    _firebaseMessaging.onTokenRefresh.listen(_updateFCMToken);

    // Get initial token
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _updateFCMToken(token);
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("accessToken");

    return {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
  }

  // Get user notifications
  Future<List<NotificationData>> getUserNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userID = prefs.getString("UserID");

      if (userID == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/notifications/$userID'),
        headers: await _getHeaders(),
      );

      print("Response status code: ${response.statusCode}");
      print("Raw Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] as List<dynamic>;

        return data
            .map((item) => NotificationData.fromJson(item))
            .where((notification) =>
                notification.status != 'archived' ||
                notification.isOneHourReminder)
            .toList();
      } else {
        throw HttpException('Failed to load notifications: ${response.body}');
      }
    } catch (e) {
      print("Error fetching notifications: $e");
      rethrow;
    }
  }

  // Subscribe to event notifications
  Future<void> subscribeToEventNotifications(String eventId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/subscribe/$eventId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw HttpException('Failed to subscribe to event notifications');
      }
    } catch (e) {
      print("Error subscribing to event: $e");
      rethrow;
    }
  }

  // Create a notification
  Future<NotificationData> createNotification({
    required String eventId,
    required String title,
    required String description,
    required String type,
    DateTime? scheduledTime,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("UserID");

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/notifications'),
        headers: await _getHeaders(),
        body: json.encode({
          'userId': userId,
          'eventId': eventId,
          'title': title,
          'description': description,
          'type': type,
          if (scheduledTime != null)
            'scheduledAt': scheduledTime.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return NotificationData.fromJson(responseData['data']);
      } else {
        throw HttpException('Failed to create notification');
      }
    } catch (e) {
      print("Error creating notification: $e");
      rethrow;
    }
  }

  // Update FCM token
  Future<void> _updateFCMToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("UserID");

      if (userId == null) return;

      final response = await http.post(
        Uri.parse('$baseUrl/users/$userId/update-fcm'),
        headers: await _getHeaders(),
        body: json.encode({'fcmToken': token}),
      );

      if (response.statusCode != 200) {
        print('Failed to update FCM token: ${response.body}');
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final androidChannel = AndroidNotificationChannel(
      'event_reminders',
      'Event Reminders',
      description: 'Notifications for event reminders',
      importance: Importance.high,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      message.notification?.title ?? '',
      message.notification?.body ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          androidChannel.id,
          androidChannel.name,
          channelDescription: androidChannel.description,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: json.encode(message.data),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    // Add navigation logic based on notification type
    // You can use GetX or your preferred navigation method
    print('Notification tapped with data: $data');
  }
}

// Your existing NotificationData model
class NotificationData {
  final String id;
  final String title;
  final String description;
  final String type;
  final String status;
  final Map<String, dynamic>? event;
  final Map<String, dynamic>? user;
  final DateTime? scheduledTime;
  final bool isOneHourReminder;
  final DateTime createdAt;

  NotificationData({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    this.event,
    this.user,
    this.scheduledTime,
    required this.isOneHourReminder,
    required this.createdAt,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'subscription',
      status: json['status'] ?? 'pending',
      event: json['event'] as Map<String, dynamic>?,
      user: json['user'] as Map<String, dynamic>?,
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.parse(json['scheduledTime'])
          : null,
      isOneHourReminder: json['isOneHourReminder'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  String? get profileImage => user?['profileImage'];
  String? get meetingLink => event?['meetingLink'];
}
