import 'package:srisridrishti/models/user_details_model.dart';

class OnboardResponse {
  final bool success;
  final String message;
  final UserDetailsModel? data; // Making UserData nullable

  OnboardResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory OnboardResponse.fromJson(Map<String, dynamic> json) {
    return OnboardResponse(
      success: json['success'],
      message: json['message'],
      data: json['success']
          ? UserDetailsModel.jsonToUserDetails(json['data'])
          : null,
    );
  }
}
