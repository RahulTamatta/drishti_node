import 'dart:convert';

class SearchUser {
  final String message;
  final SearchDataWrapper data;

  SearchUser({
    required this.message,
    required this.data,
  });

  factory SearchUser.fromJson(Map<String, dynamic> json) => SearchUser(
        message: json["message"] ?? "",
        data: SearchDataWrapper.fromJson(json["data"] ?? {}),
      );
}

class SearchDataWrapper {
  final String message;
  final SearchDataInner data;

  SearchDataWrapper({
    required this.message,
    required this.data,
  });

  factory SearchDataWrapper.fromJson(Map<String, dynamic> json) =>
      SearchDataWrapper(
        message: json["message"] ?? "",
        data: SearchDataInner.fromJson(json["data"] ?? {}),
      );
}

class SearchDataInner {
  final String message;
  final List<UserData> data;

  SearchDataInner({
    required this.message,
    required this.data,
  });

  factory SearchDataInner.fromJson(Map<String, dynamic> json) {
    var dataList =
        (json["data"] as List?)?.map((x) => UserData.fromJson(x)).toList() ??
            [];
    return SearchDataInner(
      message: json["message"] ?? "",
      data: dataList,
    );
  }
}

class UserData {
  final String id;
  final String name;
  final String userName;
  final String email;
  final String profileImage;
  final String mobileNo;

  UserData({
    required this.id,
    required this.name,
    required this.userName,
    required this.email,
    required this.profileImage,
    required this.mobileNo,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        id: json["_id"] ?? "",
        name: json["name"] ?? "",
        userName: json["userName"] ?? "",
        email: json["email"] ?? "",
        profileImage: json["profileImage"] ?? "",
        mobileNo: json["mobileNo"] ?? "",
      );
}

SearchUser searchUserFromJson(Map<String, dynamic> json) =>
    SearchUser.fromJson(json);

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
