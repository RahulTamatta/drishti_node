import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:srisridrishti/screens/notification/screens/storageKey.dart';
import 'dart:convert';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationData> notifications = [];
  bool isLoading = true;
  String? errorMessage;
  Future<void> fetchNotifications() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Debug: Print all keys in SharedPreferences
      print('All SharedPreferences keys: ${prefs.getKeys()}');

      final userID = prefs.getString(StorageKeys.userId);
      final accessToken = prefs.getString(StorageKeys.accessToken);

      print('Retrieved UserID: $userID');
      print(
          'Retrieved accessToken: ${accessToken?.substring(0, 10)}...'); // Show first 10 chars only

      if (userID == null || accessToken == null) {
        setState(() {
          errorMessage =
              'Authentication failed: UserID=${userID != null}, Token=${accessToken != null}';
          isLoading = false;
        });
        return;
      }

      print("Sending HTTP PATCH request...");
      final response = await http.get(
        Uri.parse(
            'http://drishtinode-production.up.railway.app/notifications/$userID'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] as List<dynamic>;
        print("Data received: $data");

        setState(() {
          notifications =
              data.map((item) => NotificationData.fromJson(item)).toList();
          isLoading = false;
        });
        print("Notifications parsed and state updated.");
      } else {
        print("Failed to load notifications. Response body: ${response.body}");
        setState(() {
          errorMessage = 'Failed to load notifications: ${response.body}';
          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error in fetchNotifications: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Widget buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return buildLoading();
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 20,
          ),
        ),
        centerTitle: false,
        title: Text(
          "Notifications",
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Icon(
                  Icons.notification_add_rounded,
                  color: Colors.black,
                ),
              )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 15),
        child: ListView.builder(
          itemCount: notifications.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Container(
              color: index == 0 ? Colors.purple.shade100 : Colors.white,
              padding: const EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  notification.profileImage != null
                      ? ClipOval(
                          child: Image(
                          image: NetworkImage(notification.profileImage!),
                          width: 60.0,
                          height: 60.0,
                          fit: BoxFit.cover,
                        ))
                      : ClipOval(
                          child: Image.asset(
                            "assets/images/user.png",
                            width: 60.0,
                            height: 60.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          notification.title,
                          style: GoogleFonts.manrope(
                            textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.description,
                          style: GoogleFonts.manrope(
                            textStyle: TextStyle(
                                color: Colors.black54,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getTimeAgo(notification.createdAt),
                          style: GoogleFonts.manrope(
                            textStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Notification data model
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
