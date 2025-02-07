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
    return await _profileService.addProfileDetails(
      username: profileData['userName'] as String,
      fullName: profileData['name'] as String,
      email: profileData['email'] as String,
      phoneNumber: profileData['mobileNo'] as String,
      teacherId: profileData['teacherId'] as String? ?? '',
      isArtOfLivingTeacher:
          profileData['role'] == 'teacher' ? YesNoOption.yes : YesNoOption.no,
    );
  }

  @override
  Future<ProfileDetailsResponse> getProfileDetails() async {
    return await _profileService.getProfileDetails();
  }

  @override
  Future<ProfileDetailsResponse> updateProfile(
      {required Map<String, dynamic> profileData, id}) async {
    return await _profileService
        .updateProfileDetails(profileData as UserDetailsModel);
  }

  @override
  Future<ProfileDetailsResponse> deleteProfile() async {
    return await _profileService.deleteProfile();
  }
}
