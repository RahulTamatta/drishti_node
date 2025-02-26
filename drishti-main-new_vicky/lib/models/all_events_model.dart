// To parse this JSON data, do
//
//     final allEvents = allEventsFromJson(jsonString);

import 'dart:convert';

AllEvents allEventsFromJson(String str) => AllEvents.fromJson(json.decode(str));

String allEventsToJson(AllEvents data) => json.encode(data.toJson());

class AllEvents {
  String? message;
  List<EventData>? data;

  AllEvents({
    this.message,
    this.data,
  });

  factory AllEvents.fromJson(Map<String, dynamic> json) => AllEvents(
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<EventData>.from(
                json["data"]!.map((x) => EventData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class EventData {
  List<Event>? events;
  String? from;

  EventData({
    this.events,
    this.from,
  });

  factory EventData.fromJson(Map<String, dynamic> json) => EventData(
        events: json["events"] == null
            ? []
            : List<Event>.from(json["events"]!.map((x) => Event.fromJson(x))),
        from: json["from"],
      );

  Map<String, dynamic> toJson() => {
        "events": events == null
            ? []
            : List<dynamic>.from(events!.map((x) => x.toJson())),
        "from": from,
      };
}

class Event {
  String? id;
  List<String>? title;
  List<Detail>? participantsDetails;
  String? mode;
  List<String>? aol;
  String? userId;
  DateTime? dateFrom;
  DateTime? dateTo;
  List<Detail>? userDetails;
  List<Detail>? teachersDetails;
  String? durationFrom;
  String? durationTo;
  String? meetingLink;
  bool? recurring;
  String? description;
  List<String>? address;
  List<String>? phoneNumber;
  String? mapUrl;
  String? registrationLink;
  Location? location;
  List<String>? teachers;
  List<String>? notifyTo;
  dynamic distanceInKilometers;

  Event(
      {this.id,
      this.title,
      this.participantsDetails,
      this.mode,
      this.aol,
      this.userId,
      this.dateFrom,
      this.dateTo,
      this.userDetails,
      this.teachersDetails,
      this.durationFrom,
      this.durationTo,
      this.meetingLink,
      this.recurring,
      this.description,
      this.address,
      this.phoneNumber,
      this.registrationLink,
      this.location,
      this.teachers,
      this.notifyTo,
      this.distanceInKilometers,
      this.mapUrl});

  factory Event.fromJson(Map<String, dynamic> json) {
    try {
      return Event(
        id: json["_id"] as String?,
        title: json["title"] == null
            ? []
            : List<String>.from(json["title"]!.map((x) => x.toString())),
        participantsDetails: json["participantsDetails"] == null
            ? []
            : List<Detail>.from(
                json["participantsDetails"]!.map((x) => Detail.fromJson(x))),
        mode: json["mode"],
        aol: json["aol"] == null
            ? []
            : List<String>.from(json["aol"]!.map((x) => x)),
        userId: json["userId"],
        dateFrom:
            json["dateFrom"] == null ? null : DateTime.parse(json["dateFrom"]),
        dateTo: json["dateTo"] == null ? null : DateTime.parse(json["dateTo"]),
        userDetails: json["userDetails"] == null
            ? []
            : List<Detail>.from(
                json["userDetails"]!.map((x) => Detail.fromJson(x))),
        teachersDetails: json["teachersDetails"] == null
            ? []
            : List<Detail>.from(
                json["teachersDetails"]!.map((x) => Detail.fromJson(x))),
        durationFrom: json["durationFrom"],
        mapUrl: json["mapUrl"],
        durationTo: json["durationTo"],
        meetingLink: json["meetingLink"],
        recurring: json["recurring"],
        description: json["description"],
        address: json["address"] == null
            ? []
            : List<String>.from(json["address"]!.map((x) => x)),
        phoneNumber: json["phoneNumber"] == null
            ? []
            : List<String>.from(json["phoneNumber"]!.map((x) => x)),
        registrationLink: json["registrationLink"],
        location: json["location"] == null
            ? null
            : Location.fromJson(json["location"]),
        teachers: json["teachers"] == null
            ? []
            : List<String>.from(json["teachers"]!.map((x) => x)),
        notifyTo: json["notifyTo"] == null
            ? []
            : List<String>.from(json["notifyTo"]!.map((x) => x)),
        distanceInKilometers: json["distanceInKilometers"],
      );
    } catch (e) {
      // Log the error and return a safe default Event
      print('Error parsing Event: $e');
      return Event(
        title: ['Error loading event'],
        participantsDetails: [],
        teachers: [],
        address: [],
        phoneNumber: [],
      );
    }
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title == null ? [] : List<dynamic>.from(title!.map((x) => x)),
        "participantsDetails": participantsDetails == null
            ? []
            : List<dynamic>.from(participantsDetails!.map((x) => x.toJson())),
        "mode": mode,
        "aol": aol == null ? [] : List<dynamic>.from(aol!.map((x) => x)),
        "userId": userId,
        "dateFrom": dateFrom?.toIso8601String(),
        "dateTo": dateTo?.toIso8601String(),
        "mapUrl": mapUrl.toString(),
        "userDetails": userDetails == null
            ? []
            : List<dynamic>.from(userDetails!.map((x) => x.toJson())),
        "teachersDetails": teachersDetails == null
            ? []
            : List<dynamic>.from(teachersDetails!.map((x) => x.toJson())),
        "durationFrom": durationFrom,
        "durationTo": durationTo,
        "meetingLink": meetingLink,
        "recurring": recurring,
        "description": description,
        "address":
            address == null ? [] : List<dynamic>.from(address!.map((x) => x)),
        "phoneNumber":
            aol == null ? [] : List<dynamic>.from(aol!.map((x) => x)),
        "registrationLink": registrationLink,
        "location": location?.toJson(),
        "teachers":
            teachers == null ? [] : List<dynamic>.from(teachers!.map((x) => x)),
        "notifyTo":
            notifyTo == null ? [] : List<dynamic>.from(notifyTo!.map((x) => x)),
        "distanceInKilometers": distanceInKilometers,
      };
}

class Location {
  String? type;
  List<double>? coordinates;

  Location({
    this.type,
    this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        type: json["type"],
        coordinates: json["coordinates"] == null
            ? []
            : List<double>.from(json["coordinates"]!.map((x) => x?.toDouble())),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": coordinates == null
            ? []
            : List<dynamic>.from(coordinates!.map((x) => x)),
      };
}

class Detail {
  String? id;
  String? userName;
  String? mobileNo;
  List<dynamic>? deviceTokens;
  String? countryCode;
  bool? isOnboarded;
  String? teacherRoleApproved;
  String? role;
  bool? nearByVisible;
  bool? locationSharing;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? email;
  String? name;
  String? profileImage;
  String? teacherId;
  String? teacherIdCard;

  Detail({
    this.id,
    this.userName,
    this.mobileNo,
    this.deviceTokens,
    this.countryCode,
    this.isOnboarded,
    this.teacherRoleApproved,
    this.role,
    this.nearByVisible,
    this.locationSharing,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.email,
    this.name,
    this.profileImage,
    this.teacherId,
    this.teacherIdCard,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        id: json["_id"],
        userName: json["userName"],
        mobileNo: json["mobileNo"],
        deviceTokens: json["deviceTokens"] == null
            ? []
            : List<dynamic>.from(json["deviceTokens"]!.map((x) => x)),
        countryCode: json["countryCode"],
        isOnboarded: json["isOnboarded"],
        teacherRoleApproved: json["teacherRoleApproved"],
        role: json["role"],
        nearByVisible: json["nearByVisible"],
        locationSharing: json["locationSharing"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        email: json["email"],
        name: json["name"],
        profileImage: json["profileImage"],
        teacherId: json["teacherId"],
        teacherIdCard: json["teacherIdCard"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userName": userName,
        "mobileNo": mobileNo,
        "deviceTokens": deviceTokens == null
            ? []
            : List<dynamic>.from(deviceTokens!.map((x) => x)),
        "countryCode": countryCode,
        "isOnboarded": isOnboarded,
        "teacherRoleApproved": teacherRoleApproved,
        "role": role,
        "nearByVisible": nearByVisible,
        "locationSharing": locationSharing,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "email": email,
        "name": name,
        "profileImage": profileImage,
        "teacherId": teacherId,
        "teacherIdCard": teacherIdCard,
      };
}
