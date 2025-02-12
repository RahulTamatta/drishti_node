class VerifyOtpResponse {
  final bool success;
  final String? message;
  final TokenData? data;

  VerifyOtpResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? TokenData.fromJson(json['data']) : null,
    );
  }
}

class TokenData {
  final String? accessToken;
  final String? refreshToken;
  final String? accessTokenExpiresAt;
  final String? refreshTokenExpiresAt;
  final UserData? user;
  final bool? isNewUser;

  TokenData({
    this.accessToken,
    this.refreshToken,
    this.accessTokenExpiresAt,
    this.refreshTokenExpiresAt,
    this.user,
    this.isNewUser,
  });

  factory TokenData.fromJson(Map<String, dynamic> json) {
    return TokenData(
      accessToken: json['accessToken']?.toString(),
      refreshToken: json['refreshToken']?.toString(),
      accessTokenExpiresAt: json['accessTokenExpiresAt']?.toString(),
      refreshTokenExpiresAt: json['refreshTokenExpiresAt']?.toString(),
      user: json['user'] != null ? UserData.fromJson(json['user']) : null,
      isNewUser: json['isNewUser'] ?? false,
    );
  }
}

class UserData {
  final String? id;
  final String? mobileNo;
  final String? role;
  final bool? isOnboarded;
  final String? countryCode;
  final List<String>? deviceTokens;

  UserData({
    this.id,
    this.mobileNo,
    this.role,
    this.isOnboarded,
    this.countryCode,
    this.deviceTokens,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? json['_id']?.toString(),
      mobileNo: json['mobileNo']?.toString(),
      role: json['role']?.toString(),
      isOnboarded: json['isOnboarded'] ?? false,
      countryCode: json['countryCode']?.toString(),
      deviceTokens: json['deviceTokens'] != null
          ? List<String>.from(json['deviceTokens'])
          : null,
    );
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
