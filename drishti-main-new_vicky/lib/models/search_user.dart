// To parse this JSON data, do
//
//     final searchUser = searchUserFromJson(jsonString);

import 'dart:convert';

SearchUser searchUserFromJson(dynamic str) => SearchUser.fromJson(str);

String searchUserToJson(SearchUser data) => json.encode(data.toJson());

class SearchUser {
  String message;
  SearchDataWrapper data;

  SearchUser({
    required this.message,
    required this.data,
  });

  factory SearchUser.fromJson(Map<String, dynamic> json) {
    return SearchUser(
      message: json["message"] ?? "",
      data: SearchDataWrapper.fromJson(json["data"] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data.toJson(),
      };
}

class SearchDataWrapper {
  String message;
  List<UserData> data;

  SearchDataWrapper({
    required this.message,
    required this.data,
  });

  factory SearchDataWrapper.fromJson(Map<String, dynamic> json) {
    var dataList = json["data"];
    if (dataList is List) {
      return SearchDataWrapper(
        message: json["message"] ?? "",
        data: List<UserData>.from(dataList.map((x) => UserData.fromJson(x))),
      );
    } else if (dataList is Map<String, dynamic> && dataList["data"] is List) {
      return SearchDataWrapper(
        message: json["message"] ?? "",
        data: List<UserData>.from(
            dataList["data"].map((x) => UserData.fromJson(x))),
      );
    }
    return SearchDataWrapper(
      message: json["message"] ?? "",
      data: [],
    );
  }

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class UserData {
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
  String email;
  String name;
  String profileImage;

  UserData({
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
    required this.email,
    required this.name,
    required this.profileImage,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        id: json["_id"] ?? "",
        userName: json["userName"] ?? "",
        mobileNo: json["mobileNo"] ?? "",
        deviceTokens: List<dynamic>.from(json["deviceTokens"] ?? []),
        countryCode: json["countryCode"] ?? "",
        isOnboarded: json["isOnboarded"] ?? false,
        teacherRoleApproved: json["teacherRoleApproved"] ?? "",
        role: json["role"] ?? "",
        nearByVisible: json["nearByVisible"] ?? false,
        locationSharing: json["locationSharing"] ?? false,
        createdAt: DateTime.parse(
            json["createdAt"] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(
            json["updatedAt"] ?? DateTime.now().toIso8601String()),
        email: json["email"] ?? "",
        name: json["name"] ?? "",
        profileImage: json["profileImage"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userName": userName,
        "mobileNo": mobileNo,
        "deviceTokens": deviceTokens,
        "countryCode": countryCode,
        "isOnboarded": isOnboarded,
        "teacherRoleApproved": teacherRoleApproved,
        "role": role,
        "nearByVisible": nearByVisible,
        "locationSharing": locationSharing,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
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
            : json["data"]["data"] == null
                ? []
                : List<TData>.from(json["data"]["data"].map((x) => TData.fromJson(x))),
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
        id: json["id"] ?? json["_id"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "userName": userName,
        "email": email,
        "teacherId": teacherId,
        "id": id,
      };
}
