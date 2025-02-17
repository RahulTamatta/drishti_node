class UserDetailsModel {
  final String id;
  final String countryCode;
  final DateTime createdAt;
  final List<String> deviceTokens;
  final bool isOnboarded;
  final String mobileNo;
  final String role;
  final DateTime updatedAt;
  final String email;
  final String name;
  final String profileImage;
  final String teacherRoleApproved;
  final String userName;
  final String teacherId;
  final String teacherIdCard;

  UserDetailsModel({
    required this.id,
    required this.countryCode,
    required this.createdAt,
    required this.deviceTokens,
    required this.isOnboarded,
    required this.mobileNo,
    required this.role,
    required this.updatedAt,
    required this.email,
    required this.name,
    required this.profileImage,
    required this.teacherRoleApproved,
    required this.userName,
    required this.teacherId,
    required this.teacherIdCard,
  });

  static UserDetailsModel jsonToUserDetails(Map<String, dynamic>? json) {
    print('Raw JSON input: $json'); // Add this

    if (json == null || json.isEmpty) {
      print('Warning: Received null or empty JSON data');
      return _createDefaultModel();
    }

    print('Parsing JSON data: $json');

    try {
      // Handle both id and _id fields from backend
      final userId = json['id']?.toString() ?? json['_id']?.toString() ?? '';

      print('Extracted user ID: $userId');

      final model = UserDetailsModel(
          id: userId,
          countryCode: json['countryCode']?.toString() ?? '',
          createdAt: _parseDateTime(json['createdAt']),
          deviceTokens: _parseDeviceTokens(json['deviceTokens']),
          isOnboarded: json['isOnboarded'] ?? false,
          mobileNo: json['mobileNo']?.toString() ?? '',
          role: json['role']?.toString()?.toLowerCase() ?? 'user',
          updatedAt: _parseDateTime(json['updatedAt']),
          email: json['email']?.toString() ?? '',
          name: json['name']?.toString() ?? '',
          profileImage: json['profileImage']?.toString() ?? '',
          teacherRoleApproved:
              json['teacherRoleApproved']?.toString()?.toLowerCase() ??
                  'pending',
          userName: json['userName']?.toString() ?? '',
          teacherId: json['teacherId']?.toString() ?? '',
          teacherIdCard: json['teacherIdCard']?.toString() ?? '');

      print('Successfully parsed user details: ${model.toJson()}');
      return model;
    } catch (e, stackTrace) {
      print('Error parsing user details: $e');
      print('Stack trace: $stackTrace');
      print('Problematic JSON: $json');
      return _createDefaultModel();
    }
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      return value is String ? DateTime.parse(value) : DateTime.now();
    } catch (e) {
      print('Error parsing date: $e, value: $value');
      return DateTime.now();
    }
  }

  static List<String> _parseDeviceTokens(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  static UserDetailsModel _createDefaultModel() {
    return UserDetailsModel(
      id: '',
      countryCode: '',
      createdAt: DateTime.now(),
      deviceTokens: [],
      isOnboarded: false,
      mobileNo: '',
      role: 'user',
      updatedAt: DateTime.now(),
      email: '',
      name: '',
      profileImage: '',
      teacherRoleApproved: 'pending',
      userName: '',
      teacherId: '',
      teacherIdCard: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'countryCode': countryCode,
      'createdAt': createdAt.toIso8601String(),
      'deviceTokens': deviceTokens,
      'isOnboarded': isOnboarded,
      'mobileNo': mobileNo,
      'role': role,
      'updatedAt': updatedAt.toIso8601String(),
      'email': email,
      'name': name,
      'profileImage': profileImage,
      'teacherRoleApproved': teacherRoleApproved,
      'userName': userName,
      'teacherId': teacherId,
      'teacherIdCard': teacherIdCard,
    };
  }
}
