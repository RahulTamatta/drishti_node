import 'package:srisridrishti/handler/responses/profile_details_response.dart';
import 'package:srisridrishti/handler/responses/onboard_response.dart';
import 'package:srisridrishti/models/user_details_model.dart';
import 'package:srisridrishti/screens/profile/screens/profile_details_screen.dart';

import 'package:srisridrishti/services/profile_services/profile_service.dart';
import 'profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService _profileService;

  ProfileRepositoryImpl({required ProfileService profileService})
      : _profileService = profileService;

  @override
  Future<OnboardResponse> addProfile(
      {required Map<String, dynamic> profileData}) async {
    final onboardResponse = await _profileService.addProfileDetails(
      userName: profileData['userName'] as String,  // Changed from username to userName to match service
      fullName: profileData['name'] as String,
      email: profileData['email'] as String,
      phoneNumber: profileData['mobileNo'] as String,
      teacherId: profileData['teacherId'] as String? ?? '',
      isArtOfLivingTeacher:
          profileData['role'] == 'teacher' ? YesNoOption.yes : YesNoOption.no,
    );

    if (onboardResponse == null) {
      // Handle the null case by throwing an exception.
      // This indicates an unexpected error in the service layer.
      throw Exception("Failed to add profile details: response was null.");
    }
    return onboardResponse; // Added null assertion operator
  }

  @override
  Future<ProfileDetailsResponse> getProfileDetails() async {
    return await _profileService.getProfileDetails();
  }

  @override
  Future<ProfileDetailsResponse> updateProfile(
      {required Map<String, dynamic> profileData, String? id}) async {
    // Convert profileData map to UserDetailsModel using jsonToUserDetails
    final UserDetailsModel userModel = UserDetailsModel.jsonToUserDetails({
      ...profileData,
      '_id':
          id ?? profileData['id'], // Use _id as that's what the model expects
    });

    return await _profileService.updateProfile(userModel);
  }

  @override
  Future<ProfileDetailsResponse> deleteProfile() async {
    return await _profileService.deleteProfile();
  }
}
