class VerifyOtpResponse {
  final bool success;
  final String message;
  final VerifyOtpData? data;

  VerifyOtpResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? VerifyOtpData.fromJson(json['data']) : null,
    );
  }
}

class VerifyOtpData {
  final String role;
  final String accessToken;
  final String accessTokenExpiresAt;
  final String refreshToken;
  final String refreshTokenExpiresAt;
  final UserData user;

  VerifyOtpData({
    required this.role,
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
    required this.user,
  });

  factory VerifyOtpData.fromJson(Map<String, dynamic> json) {
    return VerifyOtpData(
      role: json['role'] ?? '',
      accessToken: json['accessToken'] ?? '',
      accessTokenExpiresAt: json['accessTokenExpiresAt'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      refreshTokenExpiresAt: json['refreshTokenExpiresAt'] ?? '',
      user: UserData.fromJson(json['user'] ?? {}),
    );
  }
}

class UserData {
  final String id;
  final String mobileNo;
  final String role;
  final String createdAt;
  final String updatedAt;

  UserData({
    required this.id,
    required this.mobileNo,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['_id']?.toString() ?? '',
      mobileNo: json['mobileNo']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}

class Data {
  final String? role;
  final String? accessToken;
  final String? accessTokenExpiresAt;
  final String? refreshToken;
  final String? refreshTokenExpiresAt;
  final User? user;

  Data({
    this.role,
    this.accessToken,
    this.accessTokenExpiresAt,
    this.refreshToken,
    this.refreshTokenExpiresAt,
    this.user,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      role: json['role'],
      accessToken: json['accessToken'],
      accessTokenExpiresAt: json['accessTokenExpiresAt'],
      refreshToken: json['refreshToken'],
      refreshTokenExpiresAt: json['refreshTokenExpiresAt'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['role'] = role;
    data['accessToken'] = accessToken;
    data['accessTokenExpiresAt'] = accessTokenExpiresAt;
    data['refreshToken'] = refreshToken;
    data['refreshTokenExpiresAt'] = refreshTokenExpiresAt;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  List<Null>? firebaseToken;
  String? countryCode;
  bool? isOnboarded;
  String? teacherRoleApproved;
  Latlong? latlong;
  String? role;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  User({
    this.firebaseToken,
    this.countryCode,
    this.isOnboarded,
    this.teacherRoleApproved,
    this.latlong,
    this.role,
    this.sId,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  User.fromJson(Map<String, dynamic> json) {
    // Remove parsing of firebaseToken
    countryCode = json['countryCode'];
    isOnboarded = json['isOnboarded'];
    teacherRoleApproved = json['teacherRoleApproved'];
    latlong =
        json['latlong'] != null ? Latlong.fromJson(json['latlong']) : null;
    role = json['role'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // Remove firebaseToken from serialization
    data['countryCode'] = countryCode;
    data['isOnboarded'] = isOnboarded;
    data['teacherRoleApproved'] = teacherRoleApproved;
    if (latlong != null) {
      data['latlong'] = latlong!.toJson();
    }
    data['role'] = role;
    data['_id'] = sId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class Latlong {
  String? type;

  Latlong({this.type});

  Latlong.fromJson(Map<String, dynamic> json) {
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    return data;
  }
}
