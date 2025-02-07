import 'package:srisridrishti/handler/responses/profile_details_response.dart';
import 'package:srisridrishti/handler/responses/onboard_response.dart';

abstract class ProfileRepository {
  Future<OnboardResponse> addProfile(
      {required Map<String, dynamic> profileData});
  Future<ProfileDetailsResponse> getProfileDetails();
  Future<ProfileDetailsResponse> updateProfile(
      {required Map<String, dynamic> profileData});
  Future<ProfileDetailsResponse> deleteProfile();
}
