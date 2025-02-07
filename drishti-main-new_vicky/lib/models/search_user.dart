// To parse this JSON data, do
//
//     final searchUser = searchUserFromJson(jsonString);

import 'dart:convert';

SearchUser searchUserFromJson(dynamic str) => SearchUser.fromJson(str);

String searchUserToJson(SearchUser data) => json.encode(data.toJson());

class SearchUser {
  String message;
  Data data;

  SearchUser({
    required this.message,
    required this.data,
  });

  factory SearchUser.fromJson(Map<String, dynamic> json) => SearchUser(
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data.toJson(),
      };
}

class Data {
  String message;
  List<Datum> data;

  Data({
    required this.message,
    required this.data,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  String id;
  String userName;
  String mobileNo;
  List<dynamic> deviceTokens;
  String countryCode;
  bool isOnboarded;
  String teacherRoleApproved;
  String role;
  bool nearByVisible;
  bool locationSharing;
  DateTime createdAt;
  DateTime updatedAt;
  int v;
  String email;
  String name;
  String profileImage;

  Datum({
    required this.id,
    required this.userName,
    required this.mobileNo,
    required this.deviceTokens,
    required this.countryCode,
    required this.isOnboarded,
    required this.teacherRoleApproved,
    required this.role,
    required this.nearByVisible,
    required this.locationSharing,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.email,
    required this.name,
    required this.profileImage,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        userName: json["userName"].toString(),
        mobileNo: json["mobileNo"].toString(),
        deviceTokens: List<dynamic>.from(json["deviceTokens"].map((x) => x)),
        countryCode: json["countryCode"],
        isOnboarded: json["isOnboarded"],
        teacherRoleApproved: json["teacherRoleApproved"],
        role: json["role"],
        nearByVisible: json["nearByVisible"],
        locationSharing: json["locationSharing"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        email: json["email"].toString(),
        name: json["name"].toString(),
        profileImage: json["profileImage"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userName": userName,
        "mobileNo": mobileNo,
        "deviceTokens": List<dynamic>.from(deviceTokens.map((x) => x)),
        "countryCode": countryCode,
        "isOnboarded": isOnboarded,
        "teacherRoleApproved": teacherRoleApproved,
        "role": role,
        "nearByVisible": nearByVisible,
        "locationSharing": locationSharing,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
        "email": email,
        "name": name,
        "profileImage": profileImage,
      };
}

SearchTeacher searchTeacherFromJson(dynamic str) => SearchTeacher.fromJson(str);

String searchTeacherToJson(SearchTeacher data) => json.encode(data.toJson());

class SearchTeacher {
  String? message;
  List<TData>? data;

  SearchTeacher({
    this.message,
    this.data,
  });

  factory SearchTeacher.fromJson(Map<String, dynamic> json) => SearchTeacher(
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<TData>.from(json["data"]!.map((x) => TData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class TData {
  String? userName;
  String? email;
  String? teacherId;
  String? id;

  TData({
    this.userName,
    this.email,
    this.teacherId,
    this.id,
  });

  factory TData.fromJson(Map<String, dynamic> json) => TData(
        userName: json["userName"],
        email: json["email"],
        teacherId: json["teacherId"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "userName": userName,
        "email": email,
        "teacherId": teacherId,
        "id": id,
      };
}
