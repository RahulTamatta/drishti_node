import 'package:srisridrishti/models/all_events_model.dart';
import 'package:srisridrishti/models/teacher_details_model.dart';

import 'date_model.dart';

class DisplayCourseModel {
  String? message;
  List<Course>? data;

  DisplayCourseModel({this.message, this.data});

  DisplayCourseModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <Course>[];
      json['data'].forEach((v) {
        data!.add(Course.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Course {
  String? sId;
  String? title;
  String? mode;
  List<String>? aol;
  String? userId;
  Date? date;
  String? timeOffset;
  List<String>? duration;
  String? meetingLink;
  bool? recurring;
  List<String>? description;
  List<String>? address;
  String? phoneNumber;
  String? registrationLink;
  Location? location;
  List<String>? teachers;
  String? createdAt;
  String? updatedAt;
  int? iV;
  int? distance;
  List<TeachersDetails>? userDetails;
  List<TeachersDetails>? teachersDetails;

  Course(
      {this.sId,
      this.title,
      this.mode,
      this.aol,
      this.userId,
      this.date,
      this.timeOffset,
      this.duration,
      this.meetingLink,
      this.recurring,
      this.description,
      this.address,
      this.phoneNumber,
      this.registrationLink,
      this.location,
      this.teachers,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.distance,
      this.userDetails,
      this.teachersDetails});

  Course.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    mode = json['mode'];
    aol = json['aol'].cast<String>();
    userId = json['userId'];
    date = json['date'] != null ? Date.fromJson(json['date']) : null;
    timeOffset = json['timeOffset'];
    duration = json['duration'].cast<String>();
    meetingLink = json['meetingLink'];
    recurring = json['recurring'];
    description = json['description'].cast<String>();
    address = json['address'].cast<String>();
    phoneNumber = json['phoneNumber'];
    registrationLink = json['registrationLink'];
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;
    teachers = json['teachers'].cast<String>();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    distance = json['distance'];
    if (json['userDetails'] != null) {
      userDetails = <TeachersDetails>[];
      json['userDetails'].forEach((v) {
        userDetails!.add(TeachersDetails.fromJson(v));
      });
    }
    if (json['teachersDetails'] != null) {
      teachersDetails = <TeachersDetails>[];
      json['teachersDetails'].forEach((v) {
        teachersDetails!.add(TeachersDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['title'] = title;
    data['mode'] = mode;
    data['aol'] = aol;
    data['userId'] = userId;
    if (date != null) {
      data['date'] = date!.toJson();
    }
    data['timeOffset'] = timeOffset;
    data['duration'] = duration;
    data['meetingLink'] = meetingLink;
    data['recurring'] = recurring;
    data['description'] = description;
    data['address'] = address;
    data['phoneNumber'] = phoneNumber;
    data['registrationLink'] = registrationLink;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['teachers'] = teachers;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['distance'] = distance;
    if (userDetails != null) {
      data['userDetails'] = userDetails!.map((v) => Detail().toJson()).toList();
    }
    if (teachersDetails != null) {
      data['teachersDetails'] =
          teachersDetails!.map((v) => TeachersDetails().toJson()).toList();
    }
    return data;
  }
}
