import 'package:srisridrishti/models/user_details_model.dart';

class ProfileDetailsResponse {
  final bool success;
  final String? message;
  final UserDetailsModel? data;

  ProfileDetailsResponse(
      {required this.success, this.message, required this.data});
}
