// To parse this JSON data, do
//
//     final nearEvents = nearEventsFromJson(jsonString);

import 'dart:convert';

NearEvents nearEventsFromJson(dynamic str) => NearEvents.fromJson(str);

String nearEventsToJson(NearEvents data) => json.encode(data.toJson());

class NearEvents {
  String? message;
  List<NearByEvent>? nearByEvents;

  NearEvents({
    this.message,
    this.nearByEvents,
  });

  factory NearEvents.fromJson(Map<String, dynamic> json) => NearEvents(
        message: json["message"],
        nearByEvents: json["nearByEvents"] == null
            ? []
            : List<NearByEvent>.from(
                json["nearByEvents"]!.map((x) => NearByEvent.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "nearByEvents": nearByEvents == null
            ? []
            : List<dynamic>.from(nearByEvents!.map((x) => x.toJson())),
      };
}

class NearByEvent {
  Date? date;
  Location? location;
  String? id;
  List<String>? title;
  String? mode;
  List<String>? aol;
  String? userId;
  String? timeOffset;
  List<Duration>? duration;
  String? meetingLink;
  bool? recurring;
  String? description;
  List<String>? address;
 List<String>? phoneNumber;
  String? registrationLink;
  List<String>? teachers;
  List<String>? notifyTo;
  List<dynamic>? imagesAndCaptions;
  List<dynamic>? subscribers;
  List<dynamic>? participants;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  NearByEvent({
    this.date,
    this.location,
    this.id,
    this.title,
    this.mode,
    this.aol,
    this.userId,
    this.timeOffset,
    this.duration,
    this.meetingLink,
    this.recurring,
    this.description,
    this.address,
    this.phoneNumber,
    this.registrationLink,
    this.teachers,
    this.notifyTo,
    this.imagesAndCaptions,
    this.subscribers,
    this.participants,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory NearByEvent.fromJson(Map<String, dynamic> json) => NearByEvent(
        date: json["date"] == null ? null : Date.fromJson(json["date"]),
        location: json["location"] == null
            ? null
            : Location.fromJson(json["location"]),
        id: json["_id"],
        title: json["title"] == null
            ? []
            : List<String>.from(json["title"]!.map((x) => x)),
        mode: json["mode"],
        aol: json["aol"] == null
            ? []
            : List<String>.from(json["aol"]!.map((x) => x)),
        userId: json["userId"],
        timeOffset: json["timeOffset"],
        duration: json["duration"] == null
            ? []
            : List<Duration>.from(
                json["duration"]!.map((x) => Duration.fromJson(x))),
        meetingLink: json["meetingLink"],
        recurring: json["recurring"],
        description: json["description"],
        address: json["address"] == null
            ? []
            : List<String>.from(json["address"]!.map((x) => x)),
        phoneNumber: 
      
        json["phoneNumber"] == null
            ? []
            : List<String>.from(json["phoneNumber"]!.map((x) => x)),
        
    
        registrationLink: json["registrationLink"],
        teachers: json["teachers"] == null
            ? []
            : List<String>.from(json["teachers"]!.map((x) => x)),
        notifyTo: json["notifyTo"] == null
            ? []
            : List<String>.from(json["notifyTo"]!.map((x) => x)),
        imagesAndCaptions: json["imagesAndCaptions"] == null
            ? []
            : List<dynamic>.from(json["imagesAndCaptions"]!.map((x) => x)),
        subscribers: json["subscribers"] == null
            ? []
            : List<dynamic>.from(json["subscribers"]!.map((x) => x)),
        participants: json["participants"] == null
            ? []
            : List<dynamic>.from(json["participants"]!.map((x) => x)),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "date": date?.toJson(),
        "location": location?.toJson(),
        "_id": id,
        "title": title == null ? [] : List<dynamic>.from(title!.map((x) => x)),
        "mode": mode,
        "aol": aol == null ? [] : List<dynamic>.from(aol!.map((x) => x)),
        "userId": userId,
        "timeOffset": timeOffset,
        "duration": duration == null
            ? []
            : List<dynamic>.from(duration!.map((x) => x.toJson())),
        "meetingLink": meetingLink,
        "recurring": recurring,
        "description": description,
        "address":
            address == null ? [] : List<dynamic>.from(address!.map((x) => x)),
        "phoneNumber": phoneNumber,
        "registrationLink": registrationLink,
        "teachers":
            teachers == null ? [] : List<dynamic>.from(teachers!.map((x) => x)),
        "notifyTo":
            notifyTo == null ? [] : List<dynamic>.from(notifyTo!.map((x) => x)),
        "imagesAndCaptions": imagesAndCaptions == null
            ? []
            : List<dynamic>.from(imagesAndCaptions!.map((x) => x)),
        "subscribers": subscribers == null
            ? []
            : List<dynamic>.from(subscribers!.map((x) => x)),
        "participants": participants == null
            ? []
            : List<dynamic>.from(participants!.map((x) => x)),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

class Date {
  DateTime? from;
  String? to;

  Date({
    this.from,
    this.to,
  });

  factory Date.fromJson(Map<String, dynamic> json) => Date(
        from: json["from"] == null ? null : DateTime.parse(json["from"]),
        to: json["to"],
      );

  Map<String, dynamic> toJson() => {
        "from": from?.toIso8601String(),
        "to": to,
      };
}

class Duration {
  String? from;
  String? to;
  String? id;

  Duration({
    this.from,
    this.to,
    this.id,
  });

  factory Duration.fromJson(Map<String, dynamic> json) => Duration(
        from: json["from"],
        to: json["to"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "from": from,
        "to": to,
        "_id": id,
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
