import 'package:srisridrishti/models/user_details_model.dart';

class ProfileDetailsResponse {
  final bool success;
  final String? message;
  final UserDetailsModel? data;
  final int? statusCode;

  ProfileDetailsResponse({
    required this.success,
    this.message,
    required this.data,
    this.statusCode,
  });

  factory ProfileDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ProfileDetailsResponse(
      success: json['success'] ?? false,
      message: json['message'],
      statusCode: json['statusCode'],
      data:
          json['data'] != null ? UserDetailsModel.fromJson(json['data']) : null,
    );
  }
}
