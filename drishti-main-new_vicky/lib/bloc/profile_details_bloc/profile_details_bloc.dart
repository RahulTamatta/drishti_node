import 'package:bloc/bloc.dart';
import 'package:srisridrishti/bloc/profile_details_bloc/profile_details_event.dart';
import 'package:srisridrishti/bloc/profile_details_bloc/profile_details_state.dart';
import 'package:srisridrishti/handler/responses/profile_details_response.dart';
import 'package:srisridrishti/models/user_details_model.dart';
import 'package:srisridrishti/utils/shared_preference_helper.dart';

import '../../repos/profile_repo/profile_repository.dart';

class ProfileDetailsBloc
    extends Bloc<ProfileDetailsEvent, ProfileDetailsState> {
  final ProfileRepository _profileRepository;
  ProfileDetailsBloc(this._profileRepository) : super(ProfileDetailsInitial()) {
    on<GetProfileDetails>(_getProfileDetails);
  }

  _getProfileDetails(
      GetProfileDetails event, Emitter<ProfileDetailsState> emit) async {
    try {
      emit(ProfileDetailsLoading());

      final ProfileDetailsResponse profileResponse =
          await _profileRepository.getProfileDetails();

      if (profileResponse.success) {
        return emit(
            ProfileDetailsLoadedSuccessfully(profileResponse: profileResponse));
      } else {
        return emit(
            FailedToFetchProfileDetails(profileResponse: profileResponse));
      }
    } catch (error) {
      return emit(
        FailedToFetchProfileDetails(
          profileResponse: ProfileDetailsResponse(
              success: false, data: null, message: error.toString()),
        ),
      );
    }
  }

  Future<UserDetailsModel?> getUserDetails() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final profileResponse = await _profileRepository.getProfileDetails();
      if (profileResponse.success && profileResponse.data != null) {
        return profileResponse.data;
      }
      return null;
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }
}
