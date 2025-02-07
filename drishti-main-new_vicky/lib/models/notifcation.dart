// To parse this JSON data, do
//
//     final notificationData = notificationDataFromJson(jsonString);

import 'dart:convert';

NotificationData notificationDataFromJson(dynamic str) =>
    NotificationData.fromJson(str);

String notificationDataToJson(NotificationData data) =>
    json.encode(data.toJson());

class NotificationData {
  String? message;
  List<Datum>? data;

  NotificationData({
    this.message,
    this.data,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      NotificationData(
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  Duration? eventDate;
  Duration? duration;
  String? id;
  String? userId;
  String? eventId;
  String? message;
  String? profileImage;
  String? meetingLink;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Datum({
    this.eventDate,
    this.duration,
    this.id,
    this.userId,
    this.eventId,
    this.message,
    this.profileImage,
    this.meetingLink,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        eventDate: json["eventDate"] == null
            ? null
            : Duration.fromJson(json["eventDate"]),
        duration: json["duration"] == null
            ? null
            : Duration.fromJson(json["duration"]),
        id: json["_id"],
        userId: json["userId"],
        eventId: json["eventId"],
        message: json["message"],
        profileImage: json["profileImage"],
        meetingLink: json["meetingLink"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "eventDate": eventDate?.toJson(),
        "duration": duration?.toJson(),
        "_id": id,
        "userId": userId,
        "eventId": eventId,
        "message": message,
        "profileImage": profileImage,
        "meetingLink": meetingLink,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

class Duration {
  String? from;
  String? to;

  Duration({
    this.from,
    this.to,
  });

  factory Duration.fromJson(Map<String, dynamic> json) => Duration(
        from: json["from"],
        to: json["to"],
      );

  Map<String, dynamic> toJson() => {
        "from": from,
        "to": to,
      };
}
