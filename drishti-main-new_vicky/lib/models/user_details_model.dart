class UserDetailsModel {
  String? id;
  String? mobileNo;
  List<String>? deviceTokens;
  String? countryCode;
  bool? isOnboarded;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? role;
  String? email;
  String? name;
  String? profileImage;
  String? teacherRoleApproved;
  String? userName;
  String? teacherId;
  String? teacherIdCard;

  UserDetailsModel(
      {this.id,
      this.countryCode,
      this.createdAt,
      this.deviceTokens,
      this.isOnboarded,
      this.mobileNo,
      this.role,
      this.updatedAt,
      this.email,
      this.name,
      this.profileImage,
      this.teacherRoleApproved,
      this.userName,
      this.teacherId,
      this.teacherIdCard});

  static UserDetailsModel jsonToUserDetails(dynamic data) {
    return UserDetailsModel(
        id: data['_id'],
        countryCode: data['countryCode'],
        createdAt: data['createdAt'] != null
            ? DateTime.parse(data['createdAt'])
            : null,
        deviceTokens: (data['deviceTokens'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        isOnboarded: data['isOnboarded'],
        mobileNo: data['mobileNo'],
        role: data['role'],
        updatedAt: data['updatedAt'] != null
            ? DateTime.parse(data['updatedAt'])
            : null,
        email: data['email'],
        name: data['name'],
        profileImage: data['profileImage'],
        teacherRoleApproved: data['teacherRoleApproved'],
        userName: data['userName'],
        teacherId: data['teacherId'],
        teacherIdCard: data['teacherIdCard']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'countryCode': countryCode,
      'createdAt': createdAt?.toIso8601String(),
      'deviceTokens': deviceTokens,
      'isOnboarded': isOnboarded,
      'mobileNo': mobileNo,
      'role': role,
      'updatedAt': updatedAt?.toIso8601String(),
      'email': email,
      'name': name,
      'profileImage': profileImage,
      'teacherRoleApproved': teacherRoleApproved,
      'userName': userName,
      'teacherId': teacherId,
      'teacherIdCard': teacherIdCard
    };
  }
}
