import '../handler/responses/verify_otp_response.dart';

class TeachersDetails {
  String? sId;
  String? mobileNo;
  List<dynamic>? deviceTokens;
  String? countryCode;
  bool? isOnboarded;
  String? teacherRoleApproved;
  Latlong? latlong;
  String? role;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? email;
  String? name;
  String? profileImage;
  String? teacherId;
  String? teacherIdCard;
  String? userName;

  TeachersDetails(
      {this.sId,
      this.mobileNo,
      this.deviceTokens,
      this.countryCode,
      this.isOnboarded,
      this.teacherRoleApproved,
      this.latlong,
      this.role,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.email,
      this.name,
      this.profileImage,
      this.teacherId,
      this.teacherIdCard,
      this.userName});

  TeachersDetails.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    mobileNo = json['mobileNo'];
    if (json['deviceTokens'] != null) {
      deviceTokens = json['deviceTokens'];
    }
    countryCode = json['countryCode'];
    isOnboarded = json['isOnboarded'];
    teacherRoleApproved = json['teacherRoleApproved'];
    latlong =
        json['latlong'] != null ? Latlong.fromJson(json['latlong']) : null;
    role = json['role'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    email = json['email'];
    name = json['name'];
    profileImage = json['profileImage'];
    teacherId = json['teacherId'];
    teacherIdCard = json['teacherIdCard'];
    userName = json['userName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['mobileNo'] = mobileNo;
    if (deviceTokens != null) {
      data['deviceTokens'] = deviceTokens!.map((v) => v.toJson()).toList();
    }
    data['countryCode'] = countryCode;
    data['isOnboarded'] = isOnboarded;
    data['teacherRoleApproved'] = teacherRoleApproved;
    if (latlong != null) {
      data['latlong'] = latlong!.toJson();
    }
    data['role'] = role;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['email'] = email;
    data['name'] = name;
    data['profileImage'] = profileImage;
    data['teacherId'] = teacherId;
    data['teacherIdCard'] = teacherIdCard;
    data['userName'] = userName;
    return data;
  }
}
