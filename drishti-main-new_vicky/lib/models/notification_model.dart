class NotificationResponse {
  final String status;
  final String message;
  final NotificationData data;

  NotificationResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      status: json['status'],
      message: json['message'],
      data: NotificationData.fromJson(json['data']),
    );
  }
}

class NotificationData {
  final String id;
  final String name;
  final List<String> notifyTo;
  final DateTime date;
  final String location;

  NotificationData({
    required this.id,
    required this.name,
    required this.notifyTo,
    required this.date,
    required this.location,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['_id'],
      name: json['name'],
      notifyTo: List<String>.from(json['notifyTo']),
      date: DateTime.parse(json['date']),
      location: json['location'],
    );
  }
}
